import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/features/auth/otp_verification/otp_verification.view.dart';
import 'package:manager/features/stage/stage.view.dart';
import 'package:manager/resources/app_resources/app_maps.dart';
import 'package:manager/routes/routes.dart';
import 'package:manager/services/dialogs.service.dart';
import 'package:manager/widgets/dialogs/loader/loader_dialog.view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/utils/app_logger.dart';
import '../../../core/utils/type_def.dart';
import '../../../core/models/hive/user/user.dart';
import '../../../core/storage/storage.dart';
import '../../../services/auth.service.dart';
import '../../../services/account.service.dart';

class RegisterViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final authService = locator<AuthService>();
  final AccountManagerService _accountManager = AccountManagerService.instance;

  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Organization app only handles organization registration
  bool get isOrganization => true;

  // Organization type selection removed from UI; default handled on submit

  String? _language = "English";

  String? get language => _language;

  bool _isFormValid = false;

  bool get isFormValid => _isFormValid;

  bool _didAgree = true;

  bool get didAgree => _didAgree;

  bool _obscurePassword = true;

  bool get obscurePassword => _obscurePassword;

  String _fullPhoneNumber = '';

  String get fullPhoneNumber => _fullPhoneNumber;

  String _countryCode = '';

  String get countryCode => _countryCode;

  void init() {
    nameController.addListener(_updateFormValidity);
    emailController.addListener(_updateFormValidity);
    phoneController.addListener(_updateFormValidity);
    passwordController.addListener(_updateFormValidity);
  }

  // Removed setRegistrationType - organization app only handles organization registration

  // Removed unused _clearForm()

  void updatePhoneNumber(PhoneNumber phoneNumber) {
    _fullPhoneNumber = phoneNumber.number;
    _countryCode = phoneNumber.countryCode;
    _updateFormValidity();
  }

  void togglePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Removed updateOrganizationType - no organization type selection in UI

  void updateLanguage(String? value) {
    _language = value;
    _updateFormValidity();
    notifyListeners();
  }

  void toggleAgree(bool? didAgree) {
    _didAgree = !_didAgree;
    _updateFormValidity();
    notifyListeners();
  }

  void _updateFormValidity() {
    // Validation without organization type selection
    bool isValid =
        nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        _language != null;

    if (_isFormValid != isValid) {
      _isFormValid = isValid;
      notifyListeners();
    }
  }

  void onSubmitForm() async {
    if (formKey.currentState?.validate() == true && _isFormValid) {
      AppLogger.info("Form is valid! Sending OTP...");
      setBusy(true);

      final response = await _dialogService.showCustomDialog(
        variant: DialogType.loader,
        data: LoaderDialogAttributes(
          task: () async {
            try {
              final apiResponse = await authService.sendOtp(
                email: emailController.text,
                type: 'email',
              );

              return apiResponse.fold(
                (failure) => throw Exception(failure.message),
                (success) => success,
              );
            } catch (e) {
              throw Exception(e.toString());
            }
          },
          message: 'Sending OTP...',
        ),
      );

      if (response?.confirmed == true) {
        _navigationService.navigateTo(
          Routes.otpVerification,
          arguments: OtpVerificationViewAttributes(
            isOrganization: true,
            email: emailController.text,
            fullName: nameController.text,
            password: passwordController.text,
            phone: _fullPhoneNumber,
            countryCode: _countryCode,
            organizationType:
                "Machine Manufacturer", // Default organization type
            language: AppMaps.languageMap[_language] ?? "English",
          ),
        );
      } else {
        Fluttertoast.showToast(msg: response?.data ?? 'Failed to send OTP');
      }
    } else {
      AppLogger.error("Form is invalid!");
      Fluttertoast.showToast(msg: 'Form is invalid');
    }
    setBusy(false);
  }

  Future<void> _handleRegister() async {
    setBusy(true);

    final response = await register();
    response.fold(
      (failure) {
        Fluttertoast.showToast(msg: failure.message);
      },
      (user) async {
        await saveUser(user);
        await _accountManager.saveCurrentUser(user);
        navigateToStageView();
      },
    );
    setBusy(false);
  }

  ResultFuture<User> register() async {
    return await authService.register(
      fullName: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      phone: _fullPhoneNumber,
      countryCode: _countryCode,
      role: "organization",
      organizationType: "Machine Manufacturer", // Default organization type
      language: AppMaps.languageMap[_language] ?? "English",
    );
  }

  Future<void> navigateToStageView() async {
    await _navigationService.clearStackAndShow(
      Routes.stage,
      arguments: StageViewAttributes(selectedBottomNavIndex: 0),
    );
  }

  // Removed registerOrganization - now using sendOtp API instead
  // Removed registerEmployee - organization app only handles organization registration

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
