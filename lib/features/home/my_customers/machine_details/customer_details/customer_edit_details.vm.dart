import 'package:flutter/material.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class CustomerEditDetailsViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  final formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController organizationNameController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController designationController = TextEditingController();

  // Dropdown Values
  String? _selectedDesignation;
  String? get selectedDesignation => _selectedDesignation;

  String? _selectedMachine;
  String? get selectedMachine => _selectedMachine;

  // Phone Number
  String _fullPhoneNumber = '';
  String get fullPhoneNumber => _fullPhoneNumber;
  String _countryCode = '';
  String get countryCode => _countryCode;

  void init() {
    // Form validation is now handled by formKey.currentState?.validate()
  }

  void updatePhoneNumber(PhoneNumber phoneNumber) {
    _fullPhoneNumber = phoneNumber.number;
    _countryCode = phoneNumber.countryCode;
  }

  void updateDesignation(String? value) {
    _selectedDesignation = value;
    notifyListeners();
  }

  void updateMachine(String? value) {
    _selectedMachine = value;
    notifyListeners();
  }

  Future<void> onSavePressed() async {
    if (formKey.currentState?.validate() == true) {
      AppLogger.info("Form is valid! Saving customer...");
      // TODO: Implement customer creation logic here
    } else {
      AppLogger.error("Form is invalid!");
    }
  }

  @override
  void dispose() {
    organizationNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    contactPersonController.dispose();
    super.dispose();
  }
}
