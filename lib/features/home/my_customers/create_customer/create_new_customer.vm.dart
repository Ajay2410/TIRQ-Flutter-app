import 'package:flutter/material.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class CreateNewCustomerViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  final formKey = GlobalKey<FormState>();

  // Edit mode parameters
  final bool isEditMode;
  final Map<String, dynamic>? machineData;

  CreateNewCustomerViewModel({this.isEditMode = false, this.machineData});

  // Form Controllers
  final TextEditingController organizationNameController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();

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

  // Get display phone number for UI
  String get displayPhoneNumber =>
      _fullPhoneNumber.isNotEmpty ? _fullPhoneNumber : '';

  // Get designation items for dropdown (include existing value if in edit mode)
  List<String> get designationItems {
    List<String> baseItems = [
      LanguageService.get('md'),
      LanguageService.get('ceo'),
      LanguageService.get('chairman'),
    ];

    if (isEditMode &&
        _selectedDesignation != null &&
        _selectedDesignation!.isNotEmpty) {
      // Add the existing designation if it's not already in the list
      if (!baseItems.contains(_selectedDesignation)) {
        baseItems.insert(0, _selectedDesignation!);
      }
    }

    return baseItems;
  }

  // Get machine items for dropdown (include existing value if in edit mode)
  List<String> get machineItems {
    List<String> baseItems = [
      LanguageService.get('machine_name_format'),
      LanguageService.get('machine_production_line_a'),
      LanguageService.get('machine_assembly_unit_b'),
      LanguageService.get('machine_testing_station_c'),
    ];

    if (isEditMode &&
        _selectedMachine != null &&
        _selectedMachine!.isNotEmpty) {
      // Add the existing machine if it's not already in the list
      if (!baseItems.contains(_selectedMachine)) {
        baseItems.insert(0, _selectedMachine!);
      }
    }

    return baseItems;
  }

  void init() {
    if (isEditMode && machineData != null) {
      // Log available machine data for debugging
      AppLogger.info("Machine data in edit mode: $machineData");

      // Populate form fields with existing data
      organizationNameController.text = machineData!['customerName'] ?? '';
      emailController.text = machineData!['email'] ?? '';
      contactPersonController.text = machineData!['contactPerson'] ?? '';
      _selectedDesignation = machineData!['designation'] ?? '';
      _selectedMachine = machineData!['machineType'] ?? '';

      // Log populated values for debugging
      AppLogger.info(
        "Populated values - Organization: ${organizationNameController.text}, Email: ${emailController.text}, Contact: ${contactPersonController.text}, Designation: $_selectedDesignation, Machine: $_selectedMachine",
      );

      // Handle phone number for IntlPhoneField
      if (machineData!['phone'] != null) {
        String phone = machineData!['phone'].toString();
        if (phone.startsWith('+')) {
          // Handle international format - extract country code and phone number
          if (phone.length >= 3) {
            _countryCode = phone.substring(
              1,
              3,
            ); // Assuming 2-digit country code
            _fullPhoneNumber = phone.substring(3);
          }
        } else {
          _fullPhoneNumber = phone;
        }
      }

      // Notify listeners to update UI
      notifyListeners();
    }
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
      if (isEditMode) {
        AppLogger.info("Form is valid! Updating customer...");
        // TODO: Implement customer update logic here
      } else {
        AppLogger.info("Form is valid! Creating customer...");
        // TODO: Implement customer creation logic here
      }
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
