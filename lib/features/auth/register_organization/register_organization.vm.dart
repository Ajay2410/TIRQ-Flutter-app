import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:manager/features/auth/otp_verification/otp_verification.view.dart';
import 'package:manager/resources/app_resources/app_maps.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/routes/routes.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/utils/app_logger.dart';
import '../../../services/auth.service.dart';

class RegisterOrganizationViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final authService = locator<AuthService>();

  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController otherDescriptionController = TextEditingController(); // New controller for "Others" description
  String? _organizationType;
  String? get organizationType => _organizationType;

  String? _language = "English";
  String? get language => _language;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isFormValid = false;
  bool get isFormValid => _isFormValid;

  bool _didAgree = false;
  bool get didAgree => _didAgree;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  void init() {
    nameController.addListener(_updateFormValidity);
    otherDescriptionController.addListener(_updateFormValidity); // Add listener for other description
    emailController.addListener(_updateFormValidity);
    phoneController.addListener(_updateFormValidity);
    passwordController.addListener(_updateFormValidity);
  }

  String _fullPhoneNumber = '';
  String get fullPhoneNumber => _fullPhoneNumber;

  String _countryCode = '';
  String get countryCode => _countryCode;

  // Add this method to update the phone number when it changes
  void updatePhoneNumber(PhoneNumber phoneNumber) {
    _fullPhoneNumber = phoneNumber.number;
    _countryCode = phoneNumber.countryCode;
    _updateFormValidity();
  }

  void togglePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void updateOrganizationType(String? value) {
    _organizationType = value;
    if (value != "Others") {
      otherDescriptionController.clear();
    }
    _updateFormValidity();
    notifyListeners();
  }
  void updateLanguage(String? value) {
    _language = value;
    _updateFormValidity();
    notifyListeners();
  }

  void _updateFormValidity() {
    bool isOtherValid = _organizationType != "Others" ||
        (_organizationType == "Others" && otherDescriptionController.text.isNotEmpty);

    final isValid =
        nameController.text.isNotEmpty &&
            emailController.text.isNotEmpty &&
            phoneController.text.isNotEmpty &&
            passwordController.text.isNotEmpty &&
            _organizationType != null &&
            _language != null && // Add check for language selection
            isOtherValid;

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
      if (response.isRight()) {
        _navigationService.navigateTo(
          Routes.otpVerification,
          arguments: OtpVerificationViewAttributes(
            isOrganization: true,
            email: emailController.text,
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: response.fold(
                (exception) => exception.message.toString(),
                (message) => message,
          ),
        );
      }
    } else {
      AppLogger.error("Form is invalid!");
      Fluttertoast.showToast(msg: 'Form is invalid');
    }
    setBusy(false);
  }

  ResultFuture<String> registerOrganization() async {
    // Prepare organization type with description if "Others" is selected
    String finalOrgType = _organizationType!;
    if (_organizationType == "Others" && otherDescriptionController.text.isNotEmpty) {
      finalOrgType = "Others: ${otherDescriptionController.text}";
    }

    return await authService.registerOrganization(
      name: nameController.text,
      type: finalOrgType,
      phone: _fullPhoneNumber,
      countryCode: _countryCode, // Pass country code separately
      email: emailController.text,
      password: passwordController.text,
      language: AppMaps.languageMap[_language] ?? "English" , // Add language parameter
    );
  }
}