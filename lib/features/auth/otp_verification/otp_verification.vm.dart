import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/features/auth/otp_verification/otp_verification.view.dart';
import 'package:manager/features/stage/stage.view.dart';
import 'package:manager/services/auth.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../routes/routes.dart';

class OtpVerificationViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final authService = locator<AuthService>();

  late String email;
  late bool isOrganization;
  final TextEditingController otpController = TextEditingController();

  bool _isFormValid = false; // Initialize to false
  bool get isFormValid => _isFormValid;

  void init(OtpVerificationViewAttributes attributes) {
    email = attributes.email;
    isOrganization = attributes.isOrganization;
    otpController.addListener(_updateFormValidity);
  }

  resendOtp() {
    // Add resend OTP logic here
  }

  void _updateFormValidity() {
    // Check if OTP is 6 digits (assuming 6-digit OTP)
    final isValid = email.isNotEmpty &&
        otpController.text.isNotEmpty &&
        otpController.text.length == 6;

    if (_isFormValid != isValid) {
      _isFormValid = isValid;
    }
  }

  Future verifyEmail() async {

    AppLogger.info("cdftyhnjkl ${otpController.text}");

    if (!isFormValid) return;

    final otpValue = otpController.text;

    setBusy(true);
    final response = await authService.verifyEmail(
      email: email,
      otp: otpValue, // Use the stored value instead of reading from controller
    );

    response.fold(
          (exception) {
        Fluttertoast.showToast(msg: exception.message.toString());
      },
          (user) async {
        await saveUser(user);
        await _navigationService.clearStackAndShow(Routes.stage,arguments: StageViewAttributes(selectedBottomNavIndex: 2));
      },
    );
    setBusy(false);
  }

  @override
  void dispose() {
    otpController.removeListener(_updateFormValidity);
    otpController.dispose();
    super.dispose();
  }
}