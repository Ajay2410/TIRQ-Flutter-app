import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/type_def.dart';
import '../../../routes/routes.dart';
import '../../../services/auth.service.dart';
import '../otp_verification/otp_verification.view.dart';

class RegisterEmployeeViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final authService = locator<AuthService>();

  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isFormValid = true;
  bool get isFormValid => _isFormValid;

  bool _didAgree = true;
  bool get didAgree => _didAgree;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  void init() {
    nameController.addListener(_updateFormValidity);
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
    _fullPhoneNumber = '${phoneNumber.countryCode}${phoneNumber.number}';
    _countryCode = phoneNumber.countryCode;
    _updateFormValidity();
  }



  void toggleAgree(bool? didAgree) {
    _didAgree = !_didAgree;
    _updateFormValidity();
    notifyListeners();
  }

  void togglePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void _updateFormValidity() {
    final isValid =
        nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        didAgree;

    if (_isFormValid != isValid) {
      _isFormValid = isValid;
      notifyListeners();
    }
  }

  void onSubmitForm() async {
    if (formKey.currentState?.validate() == true && _isFormValid) {
      AppLogger.info("Form is valid! Submitting...");
      setBusy(true);
      final response = await registerEmployee();
      response.fold(
        (exception) {
          Fluttertoast.showToast(msg: exception.message.toString());
        },
        (user) async {
          _navigationService.navigateTo(
            Routes.otpVerification,
            arguments: OtpVerificationViewAttributes(
              isOrganization: true,
              email: emailController.text,
            ),
          );
        },
      );
    } else {
      AppLogger.error("Form is invalid!");
      Fluttertoast.showToast(msg: 'Form is invalid');
    }
    setBusy(false);
  }

  ResultFuture<String> registerEmployee() async {
    return await authService.registerEmployee(
      name: nameController.text,
      phone: _fullPhoneNumber,
      email: emailController.text,
      password: passwordController.text,
    );
  }
}
