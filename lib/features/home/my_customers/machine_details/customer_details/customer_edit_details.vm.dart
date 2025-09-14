import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/services/machine_storage.service.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/services/customer.service.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/widgets/common/custom_date_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomerEditDetailsViewModel extends ReactiveViewModel {
  final _machineStorageService = locator<MachineStorageService>();
  final _customerService = locator<CustomerService>();

  final Customer customer;
  final bool isFromSearchOrganization;

  CustomerEditDetailsViewModel({required this.customer, this.isFromSearchOrganization = false});

  final formKey = GlobalKey<FormState>();

  final TextEditingController organizationNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController invoiceContractNoController = TextEditingController();

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
    return DateFormat('MMM dd, yyyy').format(_purchaseDate!);
  }

  String get formattedInstallationDate {
    if (_installationDate == null) return LanguageService.get('not_available');
    return DateFormat('MMM dd, yyyy').format(_installationDate!);
  }

  String get formattedWarrantyStartDate {
    if (_warrantyStartDate == null) return LanguageService.get('not_available');
    return DateFormat('MMM dd, yyyy').format(_warrantyStartDate!);
  }

  String get formattedWarrantyEndDate {
    if (_warrantyEndDate == null) return LanguageService.get('not_available');
    return DateFormat('MMM dd, yyyy').format(_warrantyEndDate!);
  }

  Color get warrantyStatusColor {
    if (_warrantyStatus.isEmpty) return AppColors.redBack;
    if (_warrantyStatus == 'In warranty') return AppColors.success;
    if (_warrantyStatus == 'Out Of Warranty') return AppColors.redBack;
    return AppColors.textSecondary;
  }

  List<String> get machineItems {
    List<String> items = _machineStorageService.machines.map((machine) => machine.machineName ?? '').where((name) => name.isNotEmpty).toList();

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

  MachineElement? editMachineElement;

  void init({MachineElement? machineElement}) async {
    editMachineElement = machineElement;
    _populateCustomerData();
    await _machineStorageService.initializeMachines();
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
        _fullPhoneNumber = customer.phoneNumber ?? "";
      }

      if (_fullPhoneNumber.length > 10) {
        phoneController.text = _fullPhoneNumber.substring((customer.phoneNumber ?? "").length - 11);
      } else {
        phoneController.text = _fullPhoneNumber;
      }
    }

    if (customer.countryOrigin != null && customer.countryOrigin!.isNotEmpty) {
      _initialCountryCode = customer.countryOrigin!;
    }

    if (editMachineElement != null) {
      _selectedMachine = editMachineElement?.machine?.machineName;
      _purchaseDate = editMachineElement?.purchaseDate;
      _installationDate = editMachineElement?.installationDate;
      _warrantyStartDate = editMachineElement?.warrantyStart;
      _warrantyEndDate = editMachineElement?.warrantyEnd;
      _warrantyStatus = editMachineElement?.warrantyStatus ?? "In warranty";
      _invoiceContractNo = editMachineElement?.invoiceContractNo ?? "";
      invoiceContractNoController.text = _invoiceContractNo;
    } else {
      _purchaseDate = DateTime.now();
      _installationDate = DateTime.now();
      _warrantyStartDate = DateTime.now();
      _warrantyEndDate = null;
      _warrantyStatus = 'In warranty';
      _invoiceContractNo = '';
      invoiceContractNoController.text = _invoiceContractNo;
    }

    notifyListeners();
  }

  Future<void> selectPurchaseDate(BuildContext context) async {
    final DateTime? picked = await CustomDatePicker.show(
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
    final DateTime? picked = await CustomDatePicker.show(
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
    final DateTime? picked = await CustomDatePicker.show(
      context: context,
      initialDate: _warrantyStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 10, DateTime.now().month, DateTime.now().day),
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

    final DateTime firstDate = _warrantyStartDate!.add(const Duration(days: 1));
    DateTime initialDate;

    if (_warrantyEndDate != null) {
      initialDate = _warrantyEndDate!.isBefore(firstDate) ? firstDate : _warrantyEndDate!;
    } else {
      initialDate = firstDate;
    }

    final DateTime? picked = await CustomDatePicker.show(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      _warrantyEndDate = picked;
      notifyListeners();
    }
  }

  void toggleWarrantyStatus() {
    if (_warrantyStatus.isEmpty || _warrantyStatus == 'In warranty') {
      _warrantyStatus = 'Out Of Warranty';
    } else {
      _warrantyStatus = 'In warranty';
    }
    notifyListeners();
  }

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
    if (formKey.currentState?.validate() == true && _validateMachineOwnership()) {
      AppLogger.info("Form is valid! Updating customer...");

      try {
        setBusy(true);

        final machines = _buildMachinesData();

        final fullPhoneNumber = '+$_countryCode$_fullPhoneNumber';

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
            Fluttertoast.showToast(msg: failure.message, backgroundColor: Colors.red, textColor: Colors.white, toastLength: Toast.LENGTH_LONG);
            AppLogger.error("Failed to update customer: ${failure.message}");
          },
          (updatedCustomer) {
            Fluttertoast.showToast(
              msg: "Customer updated successfully!",
              backgroundColor: Colors.green,
              textColor: Colors.white,
              toastLength: Toast.LENGTH_LONG,
            );
            AppLogger.info("Customer updated successfully: ${updatedCustomer.id}");

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

  List<Map<String, dynamic>> _buildMachinesData() {
    final machines = <Map<String, dynamic>>[];
    final machine = _machineStorageService.findMachineByName(_selectedMachine!);

    // If coming from search_organization, only send the selected machine data
    if (isFromSearchOrganization) {
      if (machine != null) {
        machines.add({
          'machine': machine.id,
          'purchaseDate': _purchaseDate!.toIso8601String().split('T')[0],
          'installationDate': _installationDate!.toIso8601String().split('T')[0],
          'warrantyStart': _warrantyStartDate!.toIso8601String().split('T')[0],
          'warrantyEnd': _warrantyEndDate!.toIso8601String().split('T')[0],
          'warrantyStatus': _warrantyStatus,
          'invoiceContractNo': _invoiceContractNo,
        });
      }
      return machines;
    }

    // Original logic for when not coming from search_organization
    bool isAlreadyAssigned = false;

    if (customer.machines != null) {
      for (final existingMachine in customer.machines!) {
        if (existingMachine.machine?.id == machine?.id) {
          isAlreadyAssigned = true;
          machines.add({
            'machine': machine?.id,
            'purchaseDate': _purchaseDate!.toIso8601String().split('T')[0],
            'installationDate': _installationDate!.toIso8601String().split('T')[0],
            'warrantyStart': _warrantyStartDate!.toIso8601String().split('T')[0],
            'warrantyEnd': _warrantyEndDate!.toIso8601String().split('T')[0],
            'warrantyStatus': _warrantyStatus,
            'invoiceContractNo': _invoiceContractNo,
          });
        } else {
          machines.add({
            'machine': existingMachine.machine?.id,
            'purchaseDate': existingMachine.purchaseDate?.toIso8601String().split('T')[0] ?? '',
            'installationDate': existingMachine.installationDate?.toIso8601String().split('T')[0] ?? '',
            'warrantyStart': existingMachine.warrantyStart?.toIso8601String().split('T')[0] ?? '',
            'warrantyEnd': existingMachine.warrantyEnd?.toIso8601String().split('T')[0] ?? '',
            'warrantyStatus': existingMachine.warrantyStatus ?? '',
            'invoiceContractNo': existingMachine.invoiceContractNo ?? '',
          });
        }
      }
    }

    if (!isAlreadyAssigned && machine != null) {
      machines.add({
        'machine': machine.id,
        'purchaseDate': _purchaseDate!.toIso8601String().split('T')[0],
        'installationDate': _installationDate!.toIso8601String().split('T')[0],
        'warrantyStart': _warrantyStartDate!.toIso8601String().split('T')[0],
        'warrantyEnd': _warrantyEndDate!.toIso8601String().split('T')[0],
        'warrantyStatus': _warrantyStatus,
        'invoiceContractNo': _invoiceContractNo,
      });
    }

    return machines;
  }

  bool _validateMachineOwnership() {
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
