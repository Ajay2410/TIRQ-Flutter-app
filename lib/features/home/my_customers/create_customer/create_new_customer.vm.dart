import 'package:flutter/material.dart';
import 'package:phone_input/phone_input_package.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/machine_model.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/services/machine_storage.service.dart';
import 'package:manager/services/customer.service.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateNewCustomerViewModel extends ReactiveViewModel {
  final _machineStorageService = locator<MachineStorageService>();
  final _customerService = locator<CustomerService>();

  final formKey = GlobalKey<FormState>();

  final bool isEditMode;
  final Map<String, dynamic>? machineData;
  final VoidCallback? onCustomerCreated;
  final String? customerId;

  CreateNewCustomerViewModel({
    this.isEditMode = false,
    this.machineData,
    this.onCustomerCreated,
    this.customerId,
  });

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();

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

  String _warrantyStatus = 'In Warranty';
  String get warrantyStatus => _warrantyStatus;

  Color get warrantyStatusColor =>
      _warrantyStatus == 'In Warranty' ? AppColors.success : AppColors.redBack;

  String _invoiceContractNo = '';
  String get invoiceContractNo => _invoiceContractNo;

  List<Datum> get machines => _machineStorageService.machines;
  bool get isLoadingMachines => _machineStorageService.isLoading;

  String _fullPhoneNumber = '';
  String get fullPhoneNumber => _fullPhoneNumber;
  String _countryCode = '';
  String get countryCode => _countryCode;

  List<MachineElement>? _existingMachines;
  List<MachineElement>? get existingMachines => _existingMachines;

  String get displayPhoneNumber =>
      _fullPhoneNumber.isNotEmpty ? _fullPhoneNumber : '';

  String get formattedPurchaseDate =>
      _purchaseDate != null
          ? DateFormat('MMM dd, yyyy').format(_purchaseDate!)
          : LanguageService.get('not_available');

  String get formattedInstallationDate =>
      _installationDate != null
          ? DateFormat('MMM dd, yyyy').format(_installationDate!)
          : LanguageService.get('not_available');

  String get formattedWarrantyStartDate =>
      _warrantyStartDate != null
          ? DateFormat('MMM dd, yyyy').format(_warrantyStartDate!)
          : LanguageService.get('not_available');

  String get formattedWarrantyEndDate =>
      _warrantyEndDate != null
          ? DateFormat('MMM dd, yyyy').format(_warrantyEndDate!)
          : LanguageService.get('not_available');

  List<String> get designationItems {
    List<String> baseItems = [
      LanguageService.get('md'),
      LanguageService.get('ceo'),
      LanguageService.get('chairman'),
    ];

    if (isEditMode &&
        _selectedDesignation != null &&
        _selectedDesignation!.isNotEmpty) {
      if (!baseItems.contains(_selectedDesignation)) {
        baseItems.insert(0, _selectedDesignation!);
      }
    }

    return baseItems;
  }

  List<String> get machineItems {
    List<String> items =
        _machineStorageService.machines
            .map((machine) => machine.machineName ?? '')
            .where((name) => name.isNotEmpty)
            .toList();

    if (isEditMode &&
        _selectedMachine != null &&
        _selectedMachine!.isNotEmpty) {
      if (!items.contains(_selectedMachine)) {
        items.insert(0, _selectedMachine!);
      }
    }

    return items;
  }

  void init() async {
    await _machineStorageService.initializeMachines();

    if (isEditMode) {
      if (customerId != null) {
        await _loadCustomerData();
      } else if (machineData != null) {
        _loadMachineData();
      }
    } else {
      _purchaseDate = DateTime.now();
      _installationDate = DateTime.now();
      _warrantyStartDate = DateTime.now();
      notifyListeners();
    }
  }

  Future<void> _loadCustomerData() async {
    try {
      final result = await _customerService.getCustomerById(customerId!);
      result.fold(
        (failure) {
          AppLogger.error("Failed to load customer data: $failure");
        },
        (customer) {
          emailController.text = customer.email ?? '';
          contactPersonController.text = customer.contactPerson ?? '';
          _selectedDesignation = customer.designation ?? '';

          if (customer.phoneNumber != null) {
            String phone = customer.phoneNumber!;
            AppLogger.info("Processing phone number: $phone");

            if (phone.startsWith('+')) {
              if (phone.contains(' ')) {
                List<String> parts = phone.split(' ');
                if (parts.length >= 2) {
                  _countryCode = parts[0].substring(1);
                  _fullPhoneNumber = parts[1];
                  AppLogger.info(
                    "Parsed phone with space - Country: $_countryCode, Number: $_fullPhoneNumber",
                  );
                }
              } else {
                if (phone.length >= 3) {
                  _countryCode = phone.substring(1, 3);
                  _fullPhoneNumber = phone.substring(3);
                  AppLogger.info(
                    "Parsed phone without space - Country: $_countryCode, Number: $_fullPhoneNumber",
                  );
                }
              }
            } else {
              _fullPhoneNumber = phone;
              AppLogger.info(
                "Parsed phone without + - Number: $_fullPhoneNumber",
              );
            }

            AppLogger.info(
              "Final phone data - Country: $_countryCode, Number: $_fullPhoneNumber, Display: $displayPhoneNumber",
            );
          } else {
            AppLogger.warning("No phone number found in customer data");
          }

          if (customer.machines != null && customer.machines!.isNotEmpty) {
            _existingMachines = customer.machines;
            AppLogger.info(
              "Customer has ${customer.machines!.length} machines",
            );
            AppLogger.info("Existing machines data loaded for editing");
          } else {
            AppLogger.info("No existing machines found for customer");
          }

          AppLogger.info("All customer data loaded, notifying listeners");
          notifyListeners();
        },
      );
    } catch (e) {
      AppLogger.error("Exception while loading customer data: $e");
    }
  }

  void _loadMachineData() {
    if (machineData == null) return;

    AppLogger.error("Machine data in edit mode: $machineData");

    emailController.text = machineData!['email'] ?? '';
    contactPersonController.text = machineData!['contactPerson'] ?? '';
    _selectedDesignation = machineData!['designation'] ?? '';
    _selectedMachine = machineData!['machineType'] ?? '';

    if (machineData!['purchaseDate'] != null) {
      try {
        _purchaseDate = DateTime.parse(machineData!['purchaseDate']);
      } catch (e) {
        AppLogger.error(
          "Error parsing purchase date: ${machineData!['purchaseDate']}",
        );
      }
    }

    if (machineData!['installationDate'] != null) {
      try {
        _installationDate = DateTime.parse(machineData!['installationDate']);
      } catch (e) {
        AppLogger.error(
          "Error parsing installation date: ${machineData!['installationDate']}",
        );
      }
    }

    if (machineData!['warrantyStartDate'] != null) {
      try {
        _warrantyStartDate = DateTime.parse(machineData!['warrantyStartDate']);
      } catch (e) {
        AppLogger.error(
          "Error parsing warranty start date: ${machineData!['warrantyStartDate']}",
        );
      }
    }

    if (machineData!['warrantyEndDate'] != null) {
      try {
        _warrantyEndDate = DateTime.parse(machineData!['warrantyEndDate']);
      } catch (e) {
        AppLogger.error(
          "Error parsing warranty end date: ${machineData!['warrantyEndDate']}",
        );
      }
    }

    if (machineData!['warrantyStatus'] != null) {
      _warrantyStatus = machineData!['warrantyStatus'];
    }

    if (machineData!['invoiceContractNo'] != null) {
      _invoiceContractNo = machineData!['invoiceContractNo'];
    }

    AppLogger.error(
      "Populated values - Email: ${emailController.text}, Contact: ${contactPersonController.text}, Designation: $_selectedDesignation, Machine: $_selectedMachine",
    );

    if (machineData!['phone'] != null) {
      String phone = machineData!['phone'].toString();
      if (phone.startsWith('+')) {
        if (phone.length >= 3) {
          _countryCode = phone.substring(1, 3);
          _fullPhoneNumber = phone.substring(3);
        }
      } else {
        _fullPhoneNumber = phone;
      }
    }

    notifyListeners();
  }

  void updatePhoneNumber(PhoneNumber phoneNumber) {
    _fullPhoneNumber = phoneNumber.nsn;
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

  Datum? get selectedMachineObject {
    if (_selectedMachine == null) return null;
    return _machineStorageService.machines.firstWhere(
      (machine) => machine.machineName == _selectedMachine,
      orElse: () => Datum(),
    );
  }

  Future<void> selectPurchaseDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _purchaseDate) {
      _purchaseDate = picked;
      notifyListeners();
    }
  }

  Future<void> selectInstallationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _installationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _installationDate) {
      _installationDate = picked;
      notifyListeners();
    }
  }

  Future<void> selectWarrantyStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _warrantyStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _warrantyStartDate) {
      _warrantyStartDate = picked;
      notifyListeners();
    }
  }

  Future<void> selectWarrantyEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _warrantyEndDate ?? (_warrantyStartDate ?? DateTime.now()),
      firstDate: _warrantyStartDate ?? DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _warrantyEndDate) {
      _warrantyEndDate = picked;
      notifyListeners();
    }
  }

  void toggleWarrantyStatus() {
    _warrantyStatus =
        _warrantyStatus == 'In Warranty' ? 'Out of Warranty' : 'In Warranty';
    notifyListeners();
  }

  void updateInvoiceContractNo(String value) {
    _invoiceContractNo = value;
    notifyListeners();
  }

  Future<void> onSavePressed(BuildContext context) async {
    if (formKey.currentState?.validate() == true &&
        _validateMachineOwnership()) {
      if (isEditMode) {
        AppLogger.error("Form is valid! Updating customer...");
        await _updateCustomer(context);
      } else {
        AppLogger.error("Form is valid! Creating customer...");
        await _createCustomer(context);
      }
    } else {
      AppLogger.error("Form is invalid!");
    }
  }

  Future<void> _createCustomer(BuildContext context) async {
    try {
      setBusy(true);

      final List<Map<String, dynamic>> machines = [];

      if (_selectedMachine != null && _selectedMachine!.isNotEmpty) {
        final selectedMachineObj = selectedMachineObject;
        if (selectedMachineObj != null) {
          final String apiWarrantyStatus =
              _warrantyStatus == 'In Warranty' ? 'Active' : 'Inactive';

          machines.add({
            'machine': selectedMachineObj.id ?? '',
            'purchaseDate':
                _purchaseDate?.toIso8601String().split('T')[0] ?? '',
            'installationDate':
                _installationDate?.toIso8601String().split('T')[0] ?? '',
            'warrantyStart':
                _warrantyStartDate?.toIso8601String().split('T')[0] ?? '',
            'warrantyEnd':
                _warrantyEndDate?.toIso8601String().split('T')[0] ?? '',
            'warrantyStatus': apiWarrantyStatus,
            'invoiceContractNo': _invoiceContractNo,
          });
        }
      }

      final result = await _customerService.createCustomer(
        phoneNumber: '+$_countryCode $_fullPhoneNumber',
        email: emailController.text.trim(),
        customerName: contactPersonController.text.trim(),
        contactPerson: contactPersonController.text.trim(),
        designation: _selectedDesignation ?? '',
        machines: machines,
      );

      result.fold(
        (failure) {
          AppLogger.error("Failed to create customer: ${failure.message}");
          Fluttertoast.showToast(
            msg: failure.message,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_SHORT,
          );
        },
        (customer) {
          AppLogger.error("Customer created successfully: ${customer.id}");
          Fluttertoast.showToast(
            msg: LanguageService.get('customer_created_successfully'),
            backgroundColor: Colors.green,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_SHORT,
          );

          if (onCustomerCreated != null) {
            onCustomerCreated!();
          }
          Navigator.of(context).pop();
        },
      );
    } catch (e) {
      AppLogger.error("Exception while creating customer: $e");
      Fluttertoast.showToast(
        msg: 'Unexpected error occurred: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> _updateCustomer(BuildContext context) async {
    try {
      setBusy(true);

      final List<Map<String, dynamic>> machines = [];

      if (_existingMachines != null && _existingMachines!.isNotEmpty) {
        AppLogger.info(
          "Preserving ${_existingMachines!.length} existing machines for update",
        );
        for (var machineElement in _existingMachines!) {
          final machineData = {
            'machine': machineElement.machine?.id ?? '',
            'purchaseDate':
                machineElement.purchaseDate?.toIso8601String().split('T')[0] ??
                '',
            'installationDate':
                machineElement.installationDate?.toIso8601String().split(
                  'T',
                )[0] ??
                '',
            'warrantyStart':
                machineElement.warrantyStart?.toIso8601String().split('T')[0] ??
                '',
            'warrantyEnd':
                machineElement.warrantyEnd?.toIso8601String().split('T')[0] ??
                '',
            'warrantyStatus': machineElement.warrantyStatus ?? 'Active',
            'invoiceContractNo': machineElement.invoiceContractNo ?? '',
          };
          machines.add(machineData);
          AppLogger.info("Machine data: $machineData");
        }
      } else {
        AppLogger.warning("No existing machines found for update");
      }

      final result = await _customerService.updateCustomer(
        customerId: customerId!,
        phoneNumber: '+$_countryCode $_fullPhoneNumber',
        email: emailController.text.trim(),
        customerName: contactPersonController.text.trim(),
        contactPerson: contactPersonController.text.trim(),
        designation: _selectedDesignation ?? '',
        machines: machines,
      );

      result.fold(
        (failure) {
          AppLogger.error("Failed to update customer: ${failure.message}");
          Fluttertoast.showToast(
            msg: failure.message,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_SHORT,
          );
        },
        (customer) {
          AppLogger.error("Customer updated successfully: ${customer.id}");
          Fluttertoast.showToast(
            msg: LanguageService.get('customer_updated_successfully'),
            backgroundColor: Colors.green,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_SHORT,
          );

          Navigator.of(context).pop(customer);
        },
      );
    } catch (e) {
      AppLogger.error("Exception while updating customer: $e");
      Fluttertoast.showToast(
        msg: 'Unexpected error occurred: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
    } finally {
      setBusy(false);
    }
  }

  bool _validateMachineOwnership() {
    if (isEditMode) {
      return true;
    }

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
    phoneController.dispose();
    emailController.dispose();
    contactPersonController.dispose();
    super.dispose();
  }
}
