import 'package:flutter/material.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/services/machine_storage.service.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/services/customer.service.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:stacked/stacked.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomerEditDetailsViewModel extends ReactiveViewModel {
  final _machineStorageService = locator<MachineStorageService>();
  final _customerService = locator<CustomerService>();

  final Customer customer;

  CustomerEditDetailsViewModel({required this.customer});

  final formKey = GlobalKey<FormState>();

  final TextEditingController organizationNameController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController invoiceContractNoController =
      TextEditingController();

  String? _selectedDesignation;
  String? get selectedDesignation => _selectedDesignation;

  String? _selectedMachine;
  String? get selectedMachine => _selectedMachine;

  DateTime? _purchaseDate;
  DateTime? get purchaseDate => _purchaseDate;

  DateTime? _installationDate;
  DateTime? get installationDate => _installationDate;

  DateTime? _warrantyStartDate;
  DateTime? get warrantyStartDate => _warrantyStartDate;

  DateTime? _warrantyEndDate;
  DateTime? get warrantyEndDate => _warrantyEndDate;

  String _warrantyStatus = '';
  String get warrantyStatus => _warrantyStatus;

  String _invoiceContractNo = '';
  String get invoiceContractNo => _invoiceContractNo;

  String get formattedPurchaseDate {
    if (_purchaseDate == null) return LanguageService.get('not_available');
    return '${_purchaseDate!.day}/${_purchaseDate!.month}/${_purchaseDate!.year}';
  }

  String get formattedInstallationDate {
    if (_installationDate == null) return LanguageService.get('not_available');
    return '${_installationDate!.day}/${_installationDate!.month}/${_installationDate!.year}';
  }

  String get formattedWarrantyStartDate {
    if (_warrantyStartDate == null) return LanguageService.get('not_available');
    return '${_warrantyStartDate!.day}/${_warrantyStartDate!.month}/${_warrantyStartDate!.year}';
  }

  String get formattedWarrantyEndDate {
    if (_warrantyEndDate == null) return LanguageService.get('not_available');
    return '${_warrantyEndDate!.day}/${_warrantyEndDate!.month}/${_warrantyEndDate!.year}';
  }

  Color get warrantyStatusColor {
    if (_warrantyStatus.isEmpty) return AppColors.redBack;
    if (_warrantyStatus == 'Active') return AppColors.success;
    if (_warrantyStatus == 'Out of warranty') return AppColors.redBack;
    return AppColors.textSecondary;
  }

  List<String> get machineItems {
    List<String> items =
        _machineStorageService.machines
            .map((machine) => machine.machineName ?? '')
            .where((name) => name.isNotEmpty)
            .toList();

    if (_selectedMachine != null && _selectedMachine!.isNotEmpty) {
      if (!items.contains(_selectedMachine)) {
        items.insert(0, _selectedMachine!);
      }
    }

    return items;
  }

  bool get isLoadingMachines => _machineStorageService.isLoading;

  String _fullPhoneNumber = '';
  String get fullPhoneNumber => _fullPhoneNumber;
  String _countryCode = '';
  String get countryCode => _countryCode;
  String _initialCountryCode = 'IN';
  String get initialCountryCode => _initialCountryCode;

  void init() async {
    await _machineStorageService.initializeMachines();
    _populateCustomerData();
  }

  void _populateCustomerData() {
    organizationNameController.text = customer.customerName ?? '';
    contactPersonController.text = customer.contactPerson ?? '';
    emailController.text = customer.email ?? '';
    _selectedDesignation = customer.designation;
    designationController.text = customer.designation ?? '';

    if (customer.phoneNumber != null && customer.phoneNumber!.isNotEmpty) {
      if (customer.phoneNumber!.startsWith('+')) {
        final phoneParts = customer.phoneNumber!.substring(1).split(' ');
        if (phoneParts.length > 1) {
          _countryCode = phoneParts[0];
          _fullPhoneNumber = phoneParts.sublist(1).join('');
        } else {
          _fullPhoneNumber = customer.phoneNumber!.substring(1);
        }
      } else {
        _fullPhoneNumber = customer.phoneNumber!;
      }

      // Set the phone controller with the parsed phone number
      phoneController.text = _fullPhoneNumber;
    }

    // Set initial country code from API response
    if (customer.countryOrigin != null && customer.countryOrigin!.isNotEmpty) {
      _initialCountryCode = customer.countryOrigin!;
    }

    _purchaseDate = DateTime.now();
    _installationDate = DateTime.now();
    _warrantyStartDate = DateTime.now();
    _warrantyEndDate = null;
    _warrantyStatus = 'Active';
    _invoiceContractNo = '';
    invoiceContractNoController.text = _invoiceContractNo;

    notifyListeners();
  }

  // Date picker methods
  Future<void> selectPurchaseDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _purchaseDate = picked;
      notifyListeners();
    }
  }

  Future<void> selectInstallationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _installationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _installationDate = picked;
      notifyListeners();
    }
  }

  Future<void> selectWarrantyStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _warrantyStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _warrantyStartDate = picked;
      if (_warrantyEndDate != null && _warrantyEndDate!.isBefore(picked)) {
        _warrantyEndDate = null;
      }
      notifyListeners();
    }
  }

  Future<void> selectWarrantyEndDate(BuildContext context) async {
    if (_warrantyStartDate == null) {
      Fluttertoast.showToast(
        msg: LanguageService.get('please_select_warranty_start_date_first'),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _warrantyEndDate ?? _warrantyStartDate!.add(const Duration(days: 1)),
      firstDate: _warrantyStartDate!.add(
        const Duration(days: 1),
      ), // Must be after warranty start date
      lastDate: DateTime.now().add(
        const Duration(days: 365 * 10),
      ), // 10 years from now
    );
    if (picked != null) {
      _warrantyEndDate = picked;
      notifyListeners();
    }
  }

  // Warranty status toggle
  void toggleWarrantyStatus() {
    if (_warrantyStatus.isEmpty || _warrantyStatus == 'Active') {
      _warrantyStatus = 'Out of warranty';
    } else {
      _warrantyStatus = 'Active';
    }
    notifyListeners();
  }

  // Update invoice contract number
  void updateInvoiceContractNo(String value) {
    _invoiceContractNo = value;
    notifyListeners();
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

  Future<void> onSavePressed(BuildContext context) async {
    if (formKey.currentState?.validate() == true &&
        _validateMachineOwnership()) {
      AppLogger.info("Form is valid! Updating customer...");

      try {
        // Show loading indicator
        setBusy(true);

        // Build the machines data
        final machines = _buildMachinesData();

        // Prepare phone number with country code
        final fullPhoneNumber = '+$_countryCode$_fullPhoneNumber';

        // Call the update customer API
        final result = await _customerService.updateCustomer(
          customerId: customer.id!,
          phoneNumber: fullPhoneNumber,
          email: emailController.text.trim(),
          customerName: organizationNameController.text.trim(),
          contactPerson: contactPersonController.text.trim(),
          designation: _selectedDesignation ?? '',
          machines: machines,
        );

        result.fold(
          (failure) {
            // Handle failure
            Fluttertoast.showToast(
              msg: failure.message,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              toastLength: Toast.LENGTH_LONG,
            );
            AppLogger.error("Failed to update customer: ${failure.message}");
          },
          (updatedCustomer) {
            // Handle success
            Fluttertoast.showToast(
              msg: "Customer updated successfully!",
              backgroundColor: Colors.green,
              textColor: Colors.white,
              toastLength: Toast.LENGTH_LONG,
            );
            AppLogger.info(
              "Customer updated successfully: ${updatedCustomer.id}",
            );

            // Navigate back or refresh the page
            Navigator.of(context).pop(updatedCustomer);
          },
        );
      } catch (e) {
        AppLogger.error("Exception while updating customer: $e");
        Fluttertoast.showToast(
          msg: "An unexpected error occurred",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      } finally {
        setBusy(false);
      }
    } else {
      AppLogger.error("Form is invalid!");
    }
  }

  /// Build machines data for the API request
  List<Map<String, dynamic>> _buildMachinesData() {
    final machines = <Map<String, dynamic>>[];

    // First, add all existing machines from the customer
    if (customer.machines != null) {
      for (final existingMachine in customer.machines!) {
        machines.add({
          'machine': existingMachine.machine?.id,
          'purchaseDate':
              existingMachine.purchaseDate?.toIso8601String().split('T')[0] ??
              '',
          'installationDate':
              existingMachine.installationDate?.toIso8601String().split(
                'T',
              )[0] ??
              '',
          'warrantyStart':
              existingMachine.warrantyStart?.toIso8601String().split('T')[0] ??
              '',
          'warrantyEnd':
              existingMachine.warrantyEnd?.toIso8601String().split('T')[0] ??
              '',
          'warrantyStatus': existingMachine.warrantyStatus ?? '',
          'invoiceContractNo': existingMachine.invoiceContractNo ?? '',
        });
      }
    }

    // Then, add the newly selected machine if it's not already in the list
    if (_selectedMachine != null && _selectedMachine!.isNotEmpty) {
      final machine = _machineStorageService.findMachineByName(
        _selectedMachine!,
      );
      if (machine != null) {
        // Check if this machine is already assigned to avoid duplicates
        final isAlreadyAssigned =
            customer.machines?.any(
              (existingMachine) => existingMachine.machine?.id == machine.id,
            ) ??
            false;

        if (!isAlreadyAssigned) {
          machines.add({
            'machine': machine.id,
            'purchaseDate':
                _purchaseDate!.toIso8601String().split(
                  'T',
                )[0], // YYYY-MM-DD format
            'installationDate':
                _installationDate!.toIso8601String().split('T')[0],
            'warrantyStart':
                _warrantyStartDate!.toIso8601String().split('T')[0],
            'warrantyEnd': _warrantyEndDate!.toIso8601String().split('T')[0],
            'warrantyStatus': _warrantyStatus,
            'invoiceContractNo': _invoiceContractNo,
          });
        }
      }
    }

    return machines;
  }

  bool _validateMachineOwnership() {
    // Check if all required machine ownership fields are filled
    if (_purchaseDate == null) {
      Fluttertoast.showToast(
        msg: LanguageService.get('purchase_date_required'),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
      return false;
    }

    if (_installationDate == null) {
      Fluttertoast.showToast(
        msg: LanguageService.get('installation_date_required'),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
      return false;
    }

    if (_warrantyStartDate == null) {
      Fluttertoast.showToast(
        msg: LanguageService.get('warranty_start_date_required'),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
      return false;
    }

    if (_warrantyEndDate == null) {
      Fluttertoast.showToast(
        msg: LanguageService.get('warranty_end_date_required'),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
      return false;
    }

    if (_warrantyStatus.isEmpty) {
      Fluttertoast.showToast(
        msg: LanguageService.get('warranty_status_required'),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
      return false;
    }

    if (_invoiceContractNo.isEmpty) {
      Fluttertoast.showToast(
        msg: LanguageService.get('invoice_contract_no_required'),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    organizationNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    contactPersonController.dispose();
    designationController.dispose();
    invoiceContractNoController.dispose();
    super.dispose();
  }
}
