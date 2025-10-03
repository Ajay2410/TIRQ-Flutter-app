import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:manager/features/auth/otp_verification/otp_verification.view.dart';
import 'package:manager/resources/app_resources/app_maps.dart';
import 'package:manager/routes/routes.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/utils/app_logger.dart';
import '../../../services/auth.service.dart';

class RegisterViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final authService = locator<AuthService>();

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
      AppLogger.info("Form is valid! Submitting...");
      setBusy(true);

      final response = await registerOrganization();

      response.fold((exception) {}, (success) {
        _navigationService.navigateTo(
          Routes.otpVerification,
          arguments: OtpVerificationViewAttributes(
            isOrganization: true,
            email: emailController.text,
          ),
        );
      });
    } else {
      AppLogger.error("Form is invalid!");
      Fluttertoast.showToast(msg: 'Form is invalid');
    }
    setBusy(false);
  }

  ResultFuture<String> registerOrganization() async {
    // With no selection in UI, default to organization role and a fixed org type
    const String finalOrgType = "Machine Manufacturer";
    const String role = "organization";

    return await authService.register(
      fullName: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      phone: _fullPhoneNumber,
      countryCode: _countryCode,
      role: role,
      organizationType: finalOrgType,
      language: AppMaps.languageMap[_language] ?? "English",
    );
  }

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
