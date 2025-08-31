import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:manager/core/models/employee.dart';
import 'package:manager/core/utils/failures.dart';
import 'package:manager/features/employee/add_employee/add_employee.view.dart';
import 'package:manager/services/employee.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/models/hive/user/user.dart';
import '../../../core/models/machine.dart';
import '../../../core/models/organization.dart';
import '../../../core/models/relationships.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/type_def.dart';
import '../../../services/dialogs.service.dart';
import '../../../services/machine.service.dart';
import '../../../services/organization.service.dart';
import '../../../widgets/dialogs/loader/loader_dialog.view.dart';

class AddEmployeeViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _employeeService = locator<EmployeeService>();
  final _machineService = locator<MachineService>();
  final _organizationService = locator<OrganizationService>();

  final formKey = GlobalKey<FormState>();
  final TextEditingController relationshipTypeController =
      TextEditingController();
  final TextEditingController customRelationshipTypeController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController employeeIdController =
      TextEditingController(); // Added controller for Employee ID
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController teamController = TextEditingController();
  final TextEditingController employmentTypeController =
      TextEditingController();
  final TextEditingController shiftTimingController = TextEditingController();
  final TextEditingController factoryLocationController =
      TextEditingController();
  final TextEditingController customFactoryLocationController =
      TextEditingController();
  final TextEditingController startDateTimeController = TextEditingController();
  final TextEditingController endDateTimeController = TextEditingController();

  final ReactiveValue<String> _phoneNumber = ReactiveValue('');
  final ReactiveValue<String> _email = ReactiveValue('');
  final ReactiveValue<String> _employeeId = ReactiveValue('');
  final ReactiveValue<String> _name = ReactiveValue('');
  final ReactiveValue<String> _employmentStatus = ReactiveValue('');
  final ReactiveValue<String> _role = ReactiveValue('');
  final ReactiveValue<List<Units>> _factoryLocations = ReactiveValue([]);
  final ReactiveValue<Units?> _selectedFactoryLocation = ReactiveValue(null);
  final ReactiveValue<bool> _isLoadingFactoryLocations = ReactiveValue(false);
  final ReactiveValue<String?> _selectedEmploymentType = ReactiveValue(null);
  final ReactiveValue<String> _shiftTiming = ReactiveValue('');
  final ReactiveValue<List<Relationship>> _manufacturers = ReactiveValue([]);
  final ReactiveValue<List<Machine>> _machines = ReactiveValue([]);
  final ReactiveValue<Relationship?> _selectedManufacturer = ReactiveValue(
    null,
  );
  final ReactiveValue<Machine?> _selectedMachine = ReactiveValue(null);
  final ReactiveValue<bool> _isLoadingManufacturers = ReactiveValue(false);
  final ReactiveValue<bool> _isLoadingMachines = ReactiveValue(false);

  late Set<String> _selectedRelationshipTypes = {};
  String _countryCode = '';
  Country? _selectedCountry;
  String _countrySearchQuery = '';
  bool _isFormValid = false;
  bool _isEditing = false;
  DateTime? startDateTime;
  DateTime? endDateTime;
  bool canViewCalendar = false;
  bool canAssignTasks = false;
  bool canViewPerformance = false;
  bool canApproveExpenses = false;
  bool canApproveTimeOff = false;
  UserRole? selectedRole;

  late AddEmployeeViewAttributes _attributes;
  Employee? _employee;

  // Getters
  String get phoneNumber => _phoneNumber.value;
  String get email => _email.value;
  String get name => _name.value;
  String get employeeId => _employeeId.value;
  String get shiftTiming => _shiftTiming.value;
  String get employmentStatus => _employmentStatus.value;
  String get role => _role.value;
  String get countryCode => _countryCode;
  Set<String> get selectedRelationshipTypes => _selectedRelationshipTypes;
  bool get isFormValid => _isFormValid;
  bool get isEditing => _isEditing;
  String? get selectedEmploymentType => _selectedEmploymentType.value;
  List<Units> get factoryLocations => _factoryLocations.value;
  Units? get selectedFactoryLocation => _selectedFactoryLocation.value;
  bool get isLoadingFactoryLocations => _isLoadingFactoryLocations.value;
  Employee? get employee => _employee;
  String get countrySearchQuery => _countrySearchQuery;
  Country? get selectedCountry => _selectedCountry;
  List<Relationship> get manufacturers => _manufacturers.value;
  List<Machine> get machines => _machines.value;
  Relationship? get selectedManufacturer => _selectedManufacturer.value;
  Machine? get selectedMachine => _selectedMachine.value;
  bool get isLoadingManufacturers => _isLoadingManufacturers.value;
  bool get isLoadingMachines => _isLoadingMachines.value;

  final List<String> employmentTypes = [
    'Full time',
    'Part time',
    'Contract',
    'Intern',
    'Consultant',
  ];

  final List<String> shiftOptions = ['Morning', 'Evening', 'Night'];

  List<Country> get filteredCountries {
    if (_countrySearchQuery.isEmpty) {
      return countries.toList();
    }
    return countries
        .where(
          (country) => country.name.toLowerCase().contains(
            _countrySearchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  // Setters
  set selectedRelationshipTypes(Set<String> types) {
    _selectedRelationshipTypes = types;
    notifyListeners();
  }

  set isEditing(bool value) {
    _isEditing = value;
    notifyListeners();
  }

  void init(AddEmployeeViewAttributes attributes) async {
    _attributes = attributes;
    await loadManufacturers();
    await loadFactoryLocations();

    if (attributes.id?.isNotEmpty == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        setBusy(true);
        final response = await _dialogService.showCustomDialog(
          variant: DialogType.loader,
          data: LoaderDialogAttributes(
            task: () => _employeeService.getPendingEmployeeById(attributes.id!),
          ),
        );
        if (response?.data != null) {
          ((response?.data) as EitherResult<Employee>).fold(
            (exception) {
              Fluttertoast.showToast(msg: exception.message.toString());
              _navigationService.back();
            },
            (employee) async {
              _employee = employee;
              _phoneNumber.value = employee.phone ?? '';
              _email.value = employee.email ?? '';
              _name.value = employee.name ?? '';
              _employeeId.value =
                  employee.employeeId ?? ''; // Fixed: Set employee ID
              _employmentStatus.value = employee.employmentStatus ?? '';
              _role.value = employee.role ?? '';

              // Update controllers with loaded data
              nameController.text = employee.name ?? '';
              emailController.text = employee.email ?? '';
              phoneController.text = employee.phone ?? '';
              employeeIdController.text = employee.employeeId ?? '';

              if (employee.role != null) {
                try {
                  final position = UserRole.values.firstWhere(
                    (pos) =>
                        pos.displayName.toLowerCase() ==
                        employee.role?.toLowerCase(),
                  );
                  selectedRole = position;
                } catch (e) {
                  // Default to employee if role not found
                }
              }

              // Handle multiple relationship types
              if (employee.employeeType != null) {
                List<String> types = employee.employeeType!.split(',');
                List<String> standardTypes = getRelationshipTypesForRole(
                  selectedRole,
                );

                for (String type in types) {
                  type = type.trim();
                  if (standardTypes.contains(type)) {
                    _selectedRelationshipTypes.add(type);
                  } else if (type.isNotEmpty) {
                    _selectedRelationshipTypes.add('Other');
                    customRelationshipTypeController.text = type;
                  }
                }
              }

              notifyListeners();
            },
          );
        }
        setBusy(false);
      });
    }
  }

  List<String> getRelationshipTypesForRole(UserRole? role) {
    List<String> relationshipTypes = [];
    if (role == UserRole.plantHead) {
      relationshipTypes = ["Director / Factory Owner"];
    } else if (role == UserRole.lineInCharge) {
      relationshipTypes = ["Director / Factory Owner", "Plant Head"];
    } else if (role == UserRole.maintenanceHead) {
      relationshipTypes = [
        "Director / Factory Owner",
        "Plant Head",
        "Line InCharge",
      ];
    } else if (role == UserRole.maintenanceEngineer) {
      relationshipTypes = [
        "Director / Factory Owner",
        "Plant Head",
        "Line InCharge",
        "Maintenance Head",
      ];
    } else if (role == UserRole.machineOperator) {
      relationshipTypes = [
        "Director / Factory Owner",
        "Plant Head",
        "Line InCharge",
        "Maintenance Head",
        "Maintenance Engineer",
      ];
    } else if (role == UserRole.labour) {
      relationshipTypes = [
        "Director / Factory Owner",
        "Plant Head",
        "Line InCharge",
        "Maintenance Head",
        "Maintenance Engineer",
        "Machine Operator",
      ];
    } else if (role == UserRole.headOfGlobalService) {
      relationshipTypes = ["Director / Factory Owner"];
    } else if (role == UserRole.countryServiceManager) {
      relationshipTypes = [
        "Director / Factory Owner",
        "Head of Global Service",
      ];
    } else if (role == UserRole.localServiceEngineers) {
      relationshipTypes = [
        "Director / Factory Owner",
        "Head of Global Service",
        "Country Service Manager",
      ];
    } else if (role == UserRole.installationEngineers) {
      relationshipTypes = [
        "Director / Factory Owner",
        "Head of Global Service",
        "Country Service Manager",
        "Local Service Engineers",
      ];
    }

    return relationshipTypes;
  }

  void updateCountrySearchQuery(String query) {
    _countrySearchQuery = query;
    notifyListeners();
  }

  void updateSelectedEmploymentType(String? type) {
    _selectedEmploymentType.value = type;
    employmentTypeController.text = type ?? '';
    notifyListeners();
  }

  void updateShiftTiming(String timing) {
    _shiftTiming.value = timing;
    notifyListeners();
  }

  void updateSelectedCountry(Country? country) {
    _selectedCountry = country;
    notifyListeners();
  }

  void updateSelectedShift(String? shift) {
    _shiftTiming.value = shift ?? '';
    notifyListeners();
  }

  void toggleRelationshipType(String type, bool? selected) {
    if (selected == true) {
      _selectedRelationshipTypes.add(type);
      if (type == 'Other') {
        customRelationshipTypeController.text = '';
      }
    } else {
      _selectedRelationshipTypes.remove(type);
    }
    notifyListeners();
    _updateFormValidity();
  }

  List<String> getActualRelationshipTypes() {
    List<String> types = [];

    for (String type in _selectedRelationshipTypes) {
      if (type == 'Other' && customRelationshipTypeController.text.isNotEmpty) {
        types.add(customRelationshipTypeController.text.trim());
      } else if (type != 'Other') {
        types.add(type.trim());
      }
    }

    return types;
  }

  void _updateFormValidity() {
    final isValid = formKey.currentState?.validate() ?? false;
    final hasRequiredFields =
        _selectedRelationshipTypes.isNotEmpty &&
        (!_selectedRelationshipTypes.contains('Other') ||
            (_selectedRelationshipTypes.contains('Other') &&
                customRelationshipTypeController.text.isNotEmpty)) &&
        startDateTime != null;

    if (_isFormValid != (isValid && hasRequiredFields)) {
      _isFormValid = isValid && hasRequiredFields;
      notifyListeners();
    }
  }

  void updatePhoneNumber(PhoneNumber phoneNumber) {
    _countryCode = phoneNumber.countryCode;
    _updateFormValidity();
  }

  void onSave() async {
    formKey.currentState?.validate();
    _updateFormValidity();

    if (_isFormValid) {
      await submitDetails();
    } else {
      if (relationshipTypeController.text.isEmpty) {
        Fluttertoast.showToast(msg: 'Please select a type');
      } else if (relationshipTypeController.text == 'Other' &&
          customRelationshipTypeController.text.isEmpty) {
        Fluttertoast.showToast(msg: 'Please specify a type');
      } else if (startDateTime == null) {
        Fluttertoast.showToast(msg: 'Please select a start date');
      } else {
        Fluttertoast.showToast(msg: 'Please fill in all required fields');
      }
    }
  }

  void toggleCanViewCalendar(bool? val) {
    canViewCalendar = val ?? false;
    notifyListeners();
  }

  void toggleCanAssignTasks(bool? val) {
    canAssignTasks = val ?? false;
    notifyListeners();
  }

  void toggleCanViewPerformance(bool? val) {
    canViewPerformance = val ?? false;
    notifyListeners();
  }

  void toggleCanApproveExpenses(bool? val) {
    canApproveExpenses = val ?? false;
    notifyListeners();
  }

  void toggleCanApproveTimeOff(bool? val) {
    canApproveTimeOff = val ?? false;
    notifyListeners();
  }

  Future<void> selectStartDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      startDateTimeController.text = date.toLocal().toIso8601String().substring(
        0,
        10,
      );
      startDateTime = date;
      notifyListeners();
      _updateFormValidity();
    }
  }

  Future<void> selectEndDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      endDateTimeController.text = date.toLocal().toIso8601String().substring(
        0,
        10,
      );
      endDateTime = date;
      notifyListeners();
      _updateFormValidity();
    }
  }

  void updateSelectedRole(UserRole? role) {
    selectedRole = role;

    if (role == UserRole.plantHead || role == UserRole.maintenanceHead) {
      canViewCalendar = true;
      canAssignTasks = true;
      canViewPerformance = true;
      canApproveExpenses = role == UserRole.plantHead;
      canApproveTimeOff = role == UserRole.plantHead;
    } else if (role == UserRole.maintenanceEngineer) {
      canViewCalendar = true;
      canAssignTasks = false;
      canViewPerformance = false;
      canApproveExpenses = false;
      canApproveTimeOff = false;
    } else {
      canViewCalendar = false;
      canAssignTasks = false;
      canViewPerformance = false;
      canApproveExpenses = false;
      canApproveTimeOff = false;
    }

    notifyListeners();
    _updateFormValidity();
  }

  String getActualRelationshipType() {
    if (relationshipTypeController.text == 'Other' &&
        customRelationshipTypeController.text.isNotEmpty) {
      return customRelationshipTypeController.text.trim();
    }
    return relationshipTypeController.text.trim();
  }

  Future<void> loadFactoryLocations() async {
    _isLoadingFactoryLocations.value = true;
    notifyListeners();

    try {
      final result = await _organizationService.getProfile();

      result.fold(
        (failure) {
          AppLogger.error(
            "Failed to load factory locations: ${failure.message}",
          );
          Fluttertoast.showToast(
            msg: "Failed to load factory locations: ${failure.message}",
            backgroundColor: Colors.red,
          );
        },
        (organization) {
          if (organization.units != null && organization.units!.isNotEmpty) {
            _factoryLocations.value = organization.units!;
          } else {
            _factoryLocations.value = [];
          }
          notifyListeners();
        },
      );
    } catch (e) {
      AppLogger.error("Error loading factory locations: $e");
      Fluttertoast.showToast(
        msg: "Error loading factory locations",
        backgroundColor: Colors.red,
      );
    }

    _isLoadingFactoryLocations.value = false;
    notifyListeners();
  }

  Future<void> loadManufacturers() async {
    _isLoadingManufacturers.value = true;
    notifyListeners();

    final result = await _organizationService.getPartners(status: 'active');

    result.fold(
      (failure) {
        AppLogger.error("Failed to load manufacturers: ${failure.message}");
        Fluttertoast.showToast(
          msg: "Failed to load manufacturers: ${failure.message}",
          backgroundColor: Colors.red,
        );
      },
      (relationships) {
        _manufacturers.value = relationships;
        notifyListeners();
      },
    );

    _isLoadingManufacturers.value = false;
    notifyListeners();
  }

  Future<void> loadMachines(String? manufacturerId) async {
    if (manufacturerId == null) {
      _machines.value = [];
      _selectedMachine.value = null;
      notifyListeners();
      return;
    }

    _isLoadingMachines.value = true;
    notifyListeners();

    final manufacturer = _manufacturers.value.firstWhere(
      (m) => m.partnerId == manufacturerId,
      orElse: () => throw Exception('Manufacturer not found'),
    );

    final result = await _machineService.getMachines(
      status: '',
      department: '',
      manufacturerId: manufacturer.requesterId!,
      processorId: manufacturer.partnerId!,
    );

    result.fold(
      (failure) {
        AppLogger.error("Failed to load machines: ${failure.message}");
        Fluttertoast.showToast(
          msg: "Failed to load machines: ${failure.message}",
          backgroundColor: Colors.red,
        );
      },
      (machinesListInfo) {
        _machines.value = machinesListInfo.machines;
        notifyListeners();
      },
    );

    _isLoadingMachines.value = false;
    notifyListeners();
  }

  void selectManufacturer(Relationship? manufacturer) {
    _selectedManufacturer.value = manufacturer;
    _selectedMachine.value = null;

    if (manufacturer != null) {
      loadMachines(manufacturer.partnerId);
    } else {
      _machines.value = [];
    }

    notifyListeners();
  }

  void selectMachine(Machine? machine) {
    _selectedMachine.value = machine;
    notifyListeners();
  }

  void updateSelectedFactoryLocation(Units? location) {
    _selectedFactoryLocation.value = location;
    if (location != null) {
      factoryLocationController.text = location.name ?? '';
    } else {
      factoryLocationController.text = '';
    }
    notifyListeners();
  }

  void updateCustomFactoryLocation(String value) {
    customFactoryLocationController.text = value;
    notifyListeners();
  }

  void resetSelections() {
    _selectedManufacturer.value = null;
    _selectedMachine.value = null;
    _machines.value = [];
    notifyListeners();
  }

  bool get isSelectionValid => _selectedMachine.value != null;

  void onManufacturerSelected(Relationship? manufacturer) =>
      selectManufacturer(manufacturer);
  void onMachineSelected(Machine? machine) => selectMachine(machine);

  Future submitDetails() async {
    // Get the actual relationship types
    final relationshipTypes = getActualRelationshipTypes();

    setBusy(true);
    Either<Failure, bool>? response;

    try {
      if (_attributes.hasPasswordField) {
        response = await _employeeService.addNewEmployee(
          fullName: nameController.text,
          email: emailController.text,
          phone: phoneController.text,
          password: passwordController.text,
          relationshipType: relationshipTypes.join(','),
          team: teamController.text.trim(),
          startDateTime: startDateTime!,
          country: selectedCountry?.name ?? '',
          endDateTime: endDateTime,
          canViewCalendar: canViewCalendar,
          canAssignTasks: canAssignTasks,
          canViewPerformance: canViewPerformance,
          canApproveExpenses: canApproveExpenses,
          canApproveTimeOff: canApproveTimeOff,
          role: selectedRole!.displayName,
          countryCode: _countryCode,
          reportingTo: relationshipTypes.join(','),
          assignMachine: selectedMachine?.id,
          factoryUnitId: selectedFactoryLocation?.id,
          employeeId: employeeIdController.text, // Fixed: Use controller text
          employmentType: selectedEmploymentType,
          shiftTiming: shiftTimingController.text,
        );
      } else {
        response = await _employeeService.createEmployee(
          id: _employee?.id ?? '',
          relationshipType: relationshipTypes.join(','),
          team: teamController.text.trim(),
          startDateTime: startDateTime!,
          endDateTime: endDateTime,
          country: selectedCountry?.name ?? '',
          countryCode: _countryCode,
          canViewCalendar: canViewCalendar,
          canAssignTasks: canAssignTasks,
          canViewPerformance: canViewPerformance,
          canApproveExpenses: canApproveExpenses,
          canApproveTimeOff: canApproveTimeOff,
          role: selectedRole!.displayName,
          reportingTo: relationshipTypes.join(','),
          assignMachine: selectedMachine?.id,
          factoryUnitId: selectedFactoryLocation?.id,
          employeeId: employeeIdController.text,
          employmentType: selectedEmploymentType,
          shiftTiming: shiftTimingController.text,
        );
      }

      response.fold(
        (exception) {
          Fluttertoast.showToast(msg: exception.message.toString());
        },
        (success) async {
          Fluttertoast.showToast(msg: 'Employee added successfully!');
          _navigationService.back();
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    } finally {
      setBusy(false);
    }
  }
}
