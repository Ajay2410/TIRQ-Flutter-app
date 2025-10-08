import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/features/auth/otp_verification/otp_verification.view.dart';
import 'package:manager/features/stage/stage.view.dart';
import 'package:manager/services/auth.service.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/services/dialogs.service.dart';
import 'package:manager/services/account.service.dart';
import 'package:manager/widgets/dialogs/loader/loader_dialog.view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/storage/storage.dart';
import '../../../routes/routes.dart';

class OtpVerificationViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _apiService = locator<ApiService>();
  final authService = locator<AuthService>();
  final AccountManagerService _accountManager = AccountManagerService.instance;

  late String email;
  late bool isOrganization;
  late String fullName;
  late String password;
  late String phone;
  late String countryCode;
  late String? organizationType;
  late String? language;
  final TextEditingController otpController = TextEditingController();

  bool _isFormValid = false; // Initialize to false
  bool get isFormValid => _isFormValid;

  // Resend OTP timer properties
  Timer? _resendTimer;
  int _resendCountdown = 0;
  bool _canResend = false;
  final ValueNotifier<int> _timerNotifier = ValueNotifier<int>(0);

  int get resendCountdown => _resendCountdown;

  bool get canResend => _canResend;

  ValueNotifier<int> get timerNotifier => _timerNotifier;

  void init(OtpVerificationViewAttributes attributes) {
    email = attributes.email;
    isOrganization = attributes.isOrganization;
    fullName = attributes.fullName;
    password = attributes.password;
    phone = attributes.phone;
    countryCode = attributes.countryCode;
    organizationType = attributes.organizationType;
    language = attributes.language;
    otpController.addListener(_updateFormValidity);
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _canResend = false;
    _timerNotifier.value = _resendCountdown;
    notifyListeners(); // Only notify once at the start

    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _resendCountdown--;
      _timerNotifier.value = _resendCountdown; // Update ValueNotifier without rebuilding entire widget

      if (_resendCountdown <= 0) {
        _canResend = true;
        timer.cancel();
        _resendTimer = null;
        notifyListeners(); // Only notify when timer completes to update button state
      }
    });
  }

  Future<void> resendOtp() async {
    if (!_canResend) return;

    setBusy(true);

    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        task: () async {
          try {
            final apiResponse = await _apiService.post(url: ApiEndpoints.sendOtp, data: {'email': email, 'type': 'email'});

            if (apiResponse.statusCode == 200) {
              return 'OTP sent successfully';
            } else {
              throw Exception(apiResponse.data['message'] ?? 'Failed to send OTP');
            }
          } catch (e) {
            throw Exception(e.toString());
          }
        },
      ),
    );

    if (response?.confirmed == true) {
      Fluttertoast.showToast(msg: 'OTP sent successfully');
      _startResendTimer(); // Restart the timer
    } else {
      Fluttertoast.showToast(msg: response?.data ?? 'Failed to send OTP');
    }
    setBusy(false);
  }

  void _updateFormValidity() {
    // Check if OTP is 6 digits (assuming 6-digit OTP)
    final isValid = email.isNotEmpty && otpController.text.isNotEmpty && otpController.text.length == 6;

    if (_isFormValid != isValid) {
      _isFormValid = isValid;
    }
  }

  Future verifyEmail() async {
    AppLogger.info("Verifying OTP: ${otpController.text}");

    if (!isFormValid) return;

    final otpValue = otpController.text;

    setBusy(true);

    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        task: () async {
          try {
            final apiResponse = await _apiService.post(url: ApiEndpoints.verifyEmail, data: {'email': email, 'code': otpValue, "type": "email"});

            if (apiResponse.statusCode == 200) {
              // After OTP verification, complete the registration
              final registerResponse = await authService.register(
                fullName: fullName,
                email: email,
                password: password,
                phone: phone,
                countryCode: countryCode,
                role: isOrganization ? 'organization' : 'processor',
                organizationType: organizationType,
                language: language,
              );

              return registerResponse.fold((failure) => throw Exception(failure.message), (user) async {
                await saveUser(user);
                await _accountManager.saveCurrentUser(user);
                return 'Registration completed successfully';
              });
            } else {
              throw Exception(apiResponse.data['message'] ?? 'OTP verification failed');
            }
          } catch (e) {
            throw Exception(e.toString());
          }
        },
      ),
    );

    if (response?.confirmed == true) {
      // Registration completed successfully, navigate to main app
      await _navigationService.clearStackAndShow(Routes.stage, arguments: StageViewAttributes(selectedBottomNavIndex: 0));
    }
    setBusy(false);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _timerNotifier.dispose();
    otpController.removeListener(_updateFormValidity);
    otpController.dispose();
    super.dispose();
  }
}
