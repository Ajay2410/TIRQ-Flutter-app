import 'package:flutter/material.dart';
import 'package:phone_input/phone_input_package.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/machine_model.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/widgets/common/custom_date_picker.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/services/machine_storage.service.dart';
import 'package:manager/services/customer.service.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/widgets/country_flag/country_helper.dart';
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

  Datum? _selectedMachine;

  Datum? get selectedMachine => _selectedMachine;

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

  Color get warrantyStatusColor {
    if (_warrantyStatus.isEmpty) return AppColors.textSecondary;
    return _warrantyStatus == 'In Warranty'
        ? AppColors.success
        : AppColors.redBack;
  }

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

  String get displayPhoneNumber {
    AppLogger.info(
      "displayPhoneNumber getter called - _fullPhoneNumber: '$_fullPhoneNumber'",
    );
    return _fullPhoneNumber.isNotEmpty ? _fullPhoneNumber : '';
  }

  bool get hasPhoneNumber =>
      _fullPhoneNumber.isNotEmpty && _countryCode.isNotEmpty;

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
    List<String> baseItems = ['MD', 'CEO', 'Chairman', 'Other'];

    if (isEditMode &&
        _selectedDesignation != null &&
        _selectedDesignation!.isNotEmpty) {
      if (!baseItems.contains(_selectedDesignation)) {
        baseItems.insert(0, _selectedDesignation!);
      }
    }

    return baseItems;
  }

  List<Datum> get machineItems => _machineStorageService.machines;

  void init() async {
    await _machineStorageService.initializeMachines();
    // Notify listeners after machines are loaded to update UI
    notifyListeners();

    if (isEditMode) {
      if (customerId != null) {
        await _loadCustomerData();
      } else if (machineData != null) {
        _loadMachineData();
      }
    } else {
      // Initialize all machine overview data as N/A for new customers
      _purchaseDate = null;
      _installationDate = null;
      _warrantyStartDate = null;
      _warrantyEndDate = null;
      _warrantyStatus = '';
      _invoiceContractNo = '';
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

          _validateWarrantyDates();
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
    AppLogger.error(
      "Available machine data keys: ${machineData!.keys.toList()}",
    );

    emailController.text = machineData!['email'] ?? '';
    contactPersonController.text = machineData!['contactPerson'] ?? '';
    _selectedDesignation = machineData!['designation'] ?? '';
    final String? machineName = machineData!['machineType'];
    if (machineName != null && machineName.isNotEmpty) {
      try {
        _selectedMachine = _machineStorageService.machines.firstWhere(
          (m) => m.machineName == machineName,
        );
      } catch (_) {
        _selectedMachine = null;
      }
    }

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

    // Validate warranty dates and update warranty status
    _validateWarrantyDates();
    _updateWarrantyStatus();

    if (machineData!['invoiceContractNo'] != null) {
      _invoiceContractNo = machineData!['invoiceContractNo'];
    }

    AppLogger.error(
      "Populated values - Email: ${emailController.text}, Contact: ${contactPersonController.text}, Designation: $_selectedDesignation, Machine: $_selectedMachine",
    );

    String? phoneNumber;
    if (machineData!['phone'] != null) {
      phoneNumber = machineData!['phone'].toString();
      AppLogger.info("Found phone number in 'phone' field: $phoneNumber");
    } else if (machineData!['phoneNumber'] != null) {
      phoneNumber = machineData!['phoneNumber'].toString();
      AppLogger.info("Found phone number in 'phoneNumber' field: $phoneNumber");
    } else if (machineData!['phone_number'] != null) {
      phoneNumber = machineData!['phone_number'].toString();
      AppLogger.info(
        "Found phone number in 'phone_number' field: $phoneNumber",
      );
    } else if (machineData!['contactPhone'] != null) {
      phoneNumber = machineData!['contactPhone'].toString();
      AppLogger.info(
        "Found phone number in 'contactPhone' field: $phoneNumber",
      );
    } else if (machineData!['contact_phone'] != null) {
      phoneNumber = machineData!['contact_phone'].toString();
      AppLogger.info(
        "Found phone number in 'contact_phone' field: $phoneNumber",
      );
    }

    if (phoneNumber != null) {
      AppLogger.info("Processing machine data phone number: $phoneNumber");

      if (phoneNumber.startsWith('+')) {
        if (phoneNumber.contains(' ')) {
          List<String> parts = phoneNumber.split(' ');
          if (parts.length >= 2) {
            _countryCode = parts[0].substring(1);
            _fullPhoneNumber = parts[1];
            AppLogger.info(
              "Parsed machine phone with space - Country: $_countryCode, Number: $_fullPhoneNumber",
            );
          }
        } else {
          if (phoneNumber.length >= 3) {
            _countryCode = phoneNumber.substring(1, 3);
            _fullPhoneNumber = phoneNumber.substring(3);
            AppLogger.info(
              "Parsed machine phone without space - Country: $_countryCode, Number: $_fullPhoneNumber",
            );
          }
        }
      } else {
        _fullPhoneNumber = phoneNumber;
        AppLogger.info(
          "Parsed machine phone without + - Number: $_fullPhoneNumber",
        );
      }

      AppLogger.info(
        "Final machine phone data - Country: $_countryCode, Number: $_fullPhoneNumber, Display: $displayPhoneNumber",
      );
    } else {
      AppLogger.warning(
        "No phone number found in machine data with any known field name",
      );
    }

    notifyListeners();
  }

  void updatePhoneNumber(PhoneNumber phoneNumber) {
    if (phoneNumber.countryCode.isNotEmpty) {
      _countryCode = phoneNumber.countryCode;
      AppLogger.info("Country code updated to: $_countryCode");
    }

    if (phoneNumber.nsn.isNotEmpty) {
        _fullPhoneNumber = phoneNumber.nsn;
      AppLogger.info("Phone number updated to: $_fullPhoneNumber");
    }

    AppLogger.info(
      "Phone/Country updated - Country: $_countryCode, Number: $_fullPhoneNumber",
    );
  }

  void updateCountryCode(String countryCode) {
    if (countryCode.isNotEmpty && countryCode != _countryCode) {
      _countryCode = countryCode;
      AppLogger.info("Country code updated to: $_countryCode");
    }
  }

  void updateDesignation(String? value) {
    AppLogger.info(
      "Designation updating - Before: $_selectedDesignation, After: $value, Current country code: $_countryCode",
    );
    _selectedDesignation = value;
    notifyListeners();
    AppLogger.info(
      "Designation updated - Country code after notifyListeners: $_countryCode",
    );
  }

  void updateMachine(Datum? value) {
    AppLogger.info(
      "Machine updating - Before: ${_selectedMachine?.machineName}, After: ${value?.machineName}, Current country code: $_countryCode",
    );
    _selectedMachine = value;
    notifyListeners();
    AppLogger.info(
      "Machine updated - Country code after notifyListeners: $_countryCode",
    );
  }

  Future<void> selectPurchaseDate(BuildContext context) async {
    final DateTime? picked = await CustomDatePicker.show(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _purchaseDate) {
      _purchaseDate = picked;
      notifyListeners();
    }
  }

  Future<void> selectInstallationDate(BuildContext context) async {
    final DateTime? picked = await CustomDatePicker.show(
      context: context,
      initialDate: _installationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _installationDate) {
      _installationDate = picked;
      notifyListeners();
    }
  }

  Future<void> selectWarrantyStartDate(BuildContext context) async {
    final DateTime? picked = await CustomDatePicker.show(
      context: context,
      initialDate: _warrantyStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _warrantyStartDate) {
      _warrantyStartDate = picked;
      _validateWarrantyDates();
      _updateWarrantyStatus();
      notifyListeners();
    }
  }

  Future<void> selectWarrantyEndDate(BuildContext context) async {
    final DateTime firstDate = _warrantyStartDate ?? DateTime(2000);
    DateTime initialDate;

    if (_warrantyEndDate != null) {
      initialDate =
          _warrantyEndDate!.isBefore(firstDate) ? firstDate : _warrantyEndDate!;
    } else {
      initialDate =
          firstDate.isAfter(DateTime.now()) ? firstDate : DateTime.now();
    }

    final DateTime? picked = await CustomDatePicker.show(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _warrantyEndDate) {
      _warrantyEndDate = picked;
      _validateWarrantyDates();
      _updateWarrantyStatus();
      notifyListeners();
    }
  }

  void updateInvoiceContractNo(String value) {
    _invoiceContractNo = value;
    notifyListeners();
  }

  void _validateWarrantyDates() {
    if (_warrantyStartDate != null && _warrantyEndDate != null) {
      // If warranty end date is before warranty start date, set it to null (N/A)
      // Allow same date (isAtSameMomentAs) as valid
      if (_warrantyEndDate!.isBefore(_warrantyStartDate!)) {
        _warrantyEndDate = null;
      }
    }
  }

  void _updateWarrantyStatus() {
    if (_warrantyEndDate == null) {
      _warrantyStatus = '';
      return;
    }

    final DateTime today = DateTime.now();
    final DateTime todayOnly = DateTime(today.year, today.month, today.day);
    final DateTime warrantyEndOnly = DateTime(
      _warrantyEndDate!.year,
      _warrantyEndDate!.month,
      _warrantyEndDate!.day,
    );

    // Check if warranty end date is after or same as today
    if (warrantyEndOnly.isAfter(todayOnly) ||
        warrantyEndOnly.isAtSameMomentAs(todayOnly)) {
      _warrantyStatus = 'In Warranty';
    } else {
      _warrantyStatus = 'Out of Warranty';
    }
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

      if (_selectedMachine != null) {
        final selectedMachineObj = _selectedMachine!;
        {
          final String apiWarrantyStatus =
              _warrantyStatus == 'In Warranty'
                  ? 'In warranty'
                  : 'Out Of Warranty';

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

  IsoCode getIsoCodeFromCountryCode(String countryCode) {
    final country = CountryHelper.getCountryByDialCode(countryCode);

    if (country != null) {
      return _convertCountryCodeToIsoCode(country.code);
    }

    final normalizedCode =
        countryCode.startsWith('+') ? countryCode.substring(1) : countryCode;

    final matchingCountries = CountryHelper.getCountriesByDialCode(
      normalizedCode,
    );
    if (matchingCountries.isNotEmpty) {
      return _convertCountryCodeToIsoCode(matchingCountries.first.code);
    }

    AppLogger.warning("Unknown country code: $countryCode, falling back to IN");
    return IsoCode.IN;
  }

  IsoCode _convertCountryCodeToIsoCode(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'US':
        return IsoCode.US;
      case 'IN':
        return IsoCode.IN;
      case 'GB':
        return IsoCode.GB;
      case 'CA':
        return IsoCode.CA;
      case 'AU':
        return IsoCode.AU;
      case 'DE':
        return IsoCode.DE;
      case 'FR':
        return IsoCode.FR;
      case 'JP':
        return IsoCode.JP;
      case 'CN':
        return IsoCode.CN;
      case 'BR':
        return IsoCode.BR;
      case 'MX':
        return IsoCode.MX;
      case 'PK':
        return IsoCode.PK;
      case 'AF':
        return IsoCode.AF;
      case 'LK':
        return IsoCode.LK;
      case 'MM':
        return IsoCode.MM;
      case 'IR':
        return IsoCode.IR;
      case 'AE':
        return IsoCode.AE;
      case 'IL':
        return IsoCode.IL;
      case 'BH':
        return IsoCode.BH;
      case 'QA':
        return IsoCode.QA;
      case 'BT':
        return IsoCode.BT;
      case 'MN':
        return IsoCode.MN;
      case 'NP':
        return IsoCode.NP;
      case 'AD':
        return IsoCode.AD;
      case 'AZ':
        return IsoCode.AZ;
      case 'GE':
        return IsoCode.GE;
      case 'KG':
        return IsoCode.KG;
      case 'UZ':
        return IsoCode.UZ;
      case 'IO':
        return IsoCode.IO;
      case 'AC':
        return IsoCode.AC;
      case 'SH':
        return IsoCode.SH;
      case 'FK':
        return IsoCode.FK;
      case 'BZ':
        return IsoCode.BZ;
      case 'GT':
        return IsoCode.GT;
      case 'SV':
        return IsoCode.SV;
      case 'HN':
        return IsoCode.HN;
      case 'NI':
        return IsoCode.NI;
      case 'CR':
        return IsoCode.CR;
      case 'PA':
        return IsoCode.PA;
      case 'PM':
        return IsoCode.PM;
      case 'HT':
        return IsoCode.HT;
      case 'GP':
        return IsoCode.GP;
      case 'GY':
        return IsoCode.GY;
      case 'GF':
        return IsoCode.GF;
      case 'MQ':
        return IsoCode.MQ;
      case 'CW':
        return IsoCode.CW;
      case 'TL':
        return IsoCode.TL;
      case 'BN':
        return IsoCode.BN;
      case 'NR':
        return IsoCode.NR;
      case 'MV':
        return IsoCode.MV;
      case 'LB':
        return IsoCode.LB;
      case 'JO':
        return IsoCode.JO;
      case 'SY':
        return IsoCode.SY;
      case 'IQ':
        return IsoCode.IQ;
      case 'KW':
        return IsoCode.KW;
      case 'SA':
        return IsoCode.SA;
      case 'YE':
        return IsoCode.YE;
      case 'OM':
        return IsoCode.OM;
      case 'PS':
        return IsoCode.PS;
      case 'MY':
        return IsoCode.MY;
      case 'ID':
        return IsoCode.ID;
      case 'PH':
        return IsoCode.PH;
      case 'NZ':
        return IsoCode.NZ;
      case 'SG':
        return IsoCode.SG;
      case 'TH':
        return IsoCode.TH;
      case 'KR':
        return IsoCode.KR;
      case 'VN':
        return IsoCode.VN;
      case 'TR':
        return IsoCode.TR;
      case 'BD':
        return IsoCode.BD;
      case 'TW':
        return IsoCode.TW;
      case 'KH':
        return IsoCode.KH;
      case 'LA':
        return IsoCode.LA;
      case 'PG':
        return IsoCode.PG;
      case 'TO':
        return IsoCode.TO;
      case 'SB':
        return IsoCode.SB;
      case 'VU':
        return IsoCode.VU;
      case 'FJ':
        return IsoCode.FJ;
      case 'PW':
        return IsoCode.PW;
      case 'WF':
        return IsoCode.WF;
      case 'CK':
        return IsoCode.CK;
      case 'NU':
        return IsoCode.NU;
      case 'WS':
        return IsoCode.WS;
      case 'KI':
        return IsoCode.KI;
      case 'NC':
        return IsoCode.NC;
      case 'TV':
        return IsoCode.TV;
      case 'PF':
        return IsoCode.PF;
      case 'TK':
        return IsoCode.TK;
      case 'FM':
        return IsoCode.FM;
      case 'MH':
        return IsoCode.MH;
      case 'KP':
        return IsoCode.KP;
      case 'HK':
        return IsoCode.HK;
      case 'MO':
        return IsoCode.MO;
      case 'AR':
        return IsoCode.AR;
      case 'CL':
        return IsoCode.CL;
      case 'CO':
        return IsoCode.CO;
      case 'VE':
        return IsoCode.VE;
      case 'BO':
        return IsoCode.BO;
      case 'EC':
        return IsoCode.EC;
      case 'PY':
        return IsoCode.PY;
      case 'SR':
        return IsoCode.SR;
      case 'UY':
        return IsoCode.UY;
      case 'EG':
        return IsoCode.EG;
      case 'SS':
        return IsoCode.SS;
      case 'MA':
        return IsoCode.MA;
      case 'DZ':
        return IsoCode.DZ;
      case 'TN':
        return IsoCode.TN;
      case 'LY':
        return IsoCode.LY;
      case 'GM':
        return IsoCode.GM;
      case 'SN':
        return IsoCode.SN;
      case 'MR':
        return IsoCode.MR;
      case 'ML':
        return IsoCode.ML;
      case 'GN':
        return IsoCode.GN;
      case 'CI':
        return IsoCode.CI;
      case 'BF':
        return IsoCode.BF;
      case 'NE':
        return IsoCode.NE;
      case 'TG':
        return IsoCode.TG;
      case 'BJ':
        return IsoCode.BJ;
      case 'MU':
        return IsoCode.MU;
      case 'LR':
        return IsoCode.LR;
      case 'SL':
        return IsoCode.SL;
      case 'GH':
        return IsoCode.GH;
      case 'NG':
        return IsoCode.NG;
      case 'TD':
        return IsoCode.TD;
      case 'CF':
        return IsoCode.CF;
      case 'CM':
        return IsoCode.CM;
      case 'CV':
        return IsoCode.CV;
      case 'ST':
        return IsoCode.ST;
      case 'GQ':
        return IsoCode.GQ;
      case 'GA':
        return IsoCode.GA;
      case 'CG':
        return IsoCode.CG;
      case 'CD':
        return IsoCode.CD;
      case 'AO':
        return IsoCode.AO;
      case 'GW':
        return IsoCode.GW;
      case 'RE':
        return IsoCode.RE;
      case 'ZW':
        return IsoCode.ZW;
      case 'NA':
        return IsoCode.NA;
      case 'MW':
        return IsoCode.MW;
      case 'LS':
        return IsoCode.LS;
      case 'BW':
        return IsoCode.BW;
      case 'SZ':
        return IsoCode.SZ;
      case 'KM':
        return IsoCode.KM;
      case 'ZA':
        return IsoCode.ZA;
      case 'ER':
        return IsoCode.ER;
      case 'AW':
        return IsoCode.AW;
      case 'FO':
        return IsoCode.FO;
      case 'GL':
        return IsoCode.GL;
      case 'BS':
        return IsoCode.BS;
      case 'BB':
        return IsoCode.BB;
      case 'AI':
        return IsoCode.AI;
      case 'AG':
        return IsoCode.AG;
      case 'VG':
        return IsoCode.VG;
      case 'VI':
        return IsoCode.VI;
      case 'KY':
        return IsoCode.KY;
      case 'BM':
        return IsoCode.BM;
      case 'GD':
        return IsoCode.GD;
      case 'TC':
        return IsoCode.TC;
      case 'MS':
        return IsoCode.MS;
      case 'AS':
        return IsoCode.AS;
      case 'LC':
        return IsoCode.LC;
      case 'DM':
        return IsoCode.DM;
      case 'VC':
        return IsoCode.VC;
      case 'PR':
        return IsoCode.PR;
      case 'DO':
        return IsoCode.DO;
      case 'TT':
        return IsoCode.TT;
      case 'KN':
        return IsoCode.KN;
      case 'JM':
        return IsoCode.JM;
      case 'GR':
        return IsoCode.GR;
      case 'NL':
        return IsoCode.NL;
      case 'BE':
        return IsoCode.BE;
      case 'ES':
        return IsoCode.ES;
      case 'PT':
        return IsoCode.PT;
      case 'HU':
        return IsoCode.HU;
      case 'RO':
        return IsoCode.RO;
      case 'RS':
        return IsoCode.RS;
      case 'IT':
        return IsoCode.IT;
      case 'CH':
        return IsoCode.CH;
      case 'DK':
        return IsoCode.DK;
      case 'SE':
        return IsoCode.SE;
      case 'NO':
        return IsoCode.NO;
      case 'PL':
        return IsoCode.PL;
      case 'GI':
        return IsoCode.GI;
      case 'LU':
        return IsoCode.LU;
      case 'IE':
        return IsoCode.IT;
      case 'IS':
        return IsoCode.IS;
      case 'AL':
        return IsoCode.AL;
      case 'MT':
        return IsoCode.MT;
      case 'CY':
        return IsoCode.CY;
      case 'FI':
        return IsoCode.FI;
      case 'BG':
        return IsoCode.BG;
      case 'LT':
        return IsoCode.LT;
      case 'LV':
        return IsoCode.LV;
      case 'EE':
        return IsoCode.EE;
      case 'MD':
        return IsoCode.MD;
      case 'AM':
        return IsoCode.AM;
      case 'BY':
        return IsoCode.BY;
      case 'MC':
        return IsoCode.MC;
      case 'SM':
        return IsoCode.SM;
      case 'VA':
        return IsoCode.VA;
      case 'UA':
        return IsoCode.UA;
      case 'ME':
        return IsoCode.ME;
      case 'XK':
        return IsoCode.XK;
      case 'HR':
        return IsoCode.HR;
      case 'SI':
        return IsoCode.SI;
      case 'BA':
        return IsoCode.BA;
      case 'MK':
        return IsoCode.MK;
      default:
        AppLogger.warning(
          "Unknown country code: $countryCode, falling back to IN",
        );
        return IsoCode.IN;
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    emailController.dispose();
    contactPersonController.dispose();
    super.dispose();
  }
}
