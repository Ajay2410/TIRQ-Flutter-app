import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:manager/core/models/organization.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/resources/app_resources/app_maps.dart';
import 'package:manager/services/organization.service.dart';
import 'package:manager/widgets/bottom_sheets/file_picker_options/file_picker_options_sheet.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/models/hive/user/user.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/type_def.dart';
import '../../../services/bottom_sheets.service.dart';
import '../../../services/dialogs.service.dart';
import '../../../services/file_picker.service.dart';
import '../../../services/file_upload.service.dart';
import '../../../widgets/dialogs/loader/loader_dialog.view.dart';

class UpdateOrganizationViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _organizationService = locator<OrganizationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _filePickerService = FilePickerService();
  final _fileUploadService = FileUploadService();

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Organization basic info controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController yourNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController phone2Controller = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController email2Controller = TextEditingController();

  // Corporate Address controllers
  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController addressLine2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  // Factory Address controllers
  final TextEditingController factoryAddressLine1Controller =
      TextEditingController();
  final TextEditingController factoryAddressLine2Controller =
      TextEditingController();
  final TextEditingController factoryCityController = TextEditingController();
  final TextEditingController factoryStateController = TextEditingController();
  final TextEditingController factoryCountryController =
      TextEditingController();
  final TextEditingController factoryPinCodeController =
      TextEditingController();

  // Additional info controllers
  final TextEditingController establishedYearController =
      TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController otherDesignationController =
      TextEditingController();
  final TextEditingController organizationType = TextEditingController();

  // Designation type
  final ReactiveValue<String> _designationType = ReactiveValue<String>('md');
  String get designationType => _designationType.value;
  void updateDesignationType(String? value) {
    if (value != null) {
      _designationType.value = value;
      _onFormChanged();
      notifyListeners();
    }
  }

  bool isDataChanged = false;

  void markDataChanged() {
    isDataChanged = true;
    notifyListeners();
  }

  String _language = 'English';

  String preferredLanguage() {
    return AppMaps.languageMap.entries
        .firstWhere(
          (e) => e.value == _language,
          orElse:
              () =>
                  AppMaps.languageMap.entries.first, // fallback to first entry
        )
        .key;
  }

  void updateLanguage(String value) {
    _language =
        AppMaps.languageMap.entries.firstWhere((e) => e.key == value).value;
    _onFormChanged();
    notifyListeners();
  }

  // Other designation flag
  final ReactiveValue<bool> _showOtherDesignation = ReactiveValue<bool>(false);
  bool get showOtherDesignation => _showOtherDesignation.value;
  set showOtherDesignation(bool value) {
    _showOtherDesignation.value = value;
    notifyListeners();
  }

  // Same as corporate address flag
  final ReactiveValue<bool> _sameAsCorpAddress = ReactiveValue<bool>(false);
  bool get sameAsCorpAddress => _sameAsCorpAddress.value;
  void toggleSameAsCorpAddress(bool value) {
    _sameAsCorpAddress.value = value;
    if (value) {
      // Copy corporate address to factory address
      factoryAddressLine1Controller.text = addressLine1Controller.text;
      factoryAddressLine2Controller.text = addressLine2Controller.text;
      factoryCityController.text = cityController.text;
      factoryStateController.text = stateController.text;
      factoryCountryController.text = countryController.text;
      factoryPinCodeController.text = pinCodeController.text;
      _factoryCountry.value = _country.value;
    }
    _onFormChanged();
    notifyListeners();
  }

  // Country dropdown
  final ReactiveValue<String> _country = ReactiveValue<String>('India');
  String get country => _country.value;
  void updateCountry(String? value) {
    if (value != null) {
      _country.value = value;
      countryController.text = value;
      _onFormChanged();
      notifyListeners();

      // Update factory country if same as corporate address is checked
      if (_sameAsCorpAddress.value) {
        _factoryCountry.value = value;
        factoryCountryController.text = value;
      }
    }
  }

  // Factory country dropdown
  final ReactiveValue<String> _factoryCountry = ReactiveValue<String>('India');
  String get factoryCountry => _factoryCountry.value;
  void updateFactoryCountry(String? value) {
    if (value != null) {
      _factoryCountry.value = value;
      factoryCountryController.text = value;
      _onFormChanged();
      notifyListeners();
    }
  }

  String _countrySearchQuery = '';
  String get countrySearchQuery => _countrySearchQuery;

  Country? _selectedCountry;
  Country? get selectedCountry => _selectedCountry;

  Country? _selectedCountryF;
  Country? get selectedCountryF => _selectedCountryF;

  bool? isPersonalInfoEditable = false;
  bool? isCorporateAddressEditable = false;
  bool? isFactoryAddressEditable = false;
  bool? isAdditionalInfoEditable = false;

  // Add these toggle methods
  void togglePersonalInfoEdit() {
    isPersonalInfoEditable = !(isPersonalInfoEditable ?? false);
    notifyListeners();
  }

  void toggleCorporateAddressEdit() {
    isCorporateAddressEditable = !(isCorporateAddressEditable ?? false);
    notifyListeners();
  }

  void toggleFactoryAddressEdit() {
    isFactoryAddressEditable = !(isFactoryAddressEditable ?? false);
    notifyListeners();
  }

  void toggleAdditionalInfoEdit() {
    isAdditionalInfoEditable = !(isAdditionalInfoEditable ?? false);
    notifyListeners();
  }

  // List<Country> get filteredCountries {
  //   if (_countrySearchQuery.isEmpty) {
  //     return countries.toList();
  //   }
  //   return countries.where((country) =>
  //       country.name.toLowerCase().contains(_countrySearchQuery.toLowerCase())
  //   ).toList();
  // }

  void updateCountrySearchQuery(String query) {
    _countrySearchQuery = query;
    notifyListeners();
  }

  void updateSelectedCountry(Country? country) {
    _selectedCountry = country;
    notifyListeners();
  }

  void updateSelectedCountryF(Country? country) {
    _selectedCountryF = country;
    notifyListeners();
  }

  // List of countries
  List<String> countries = [
    'India',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
    'France',
    'Japan',
    'China',
    'Brazil',
    'Other',
  ];

  final ReactiveValue<List<Units>> _units = ReactiveValue<List<Units>>([]);
  List<Units> get units => _units.value;

  Map<int, TextEditingController> unitNameControllers = {};
  Map<int, TextEditingController> unitLocalityControllers = {};
  Map<int, String?> unitCountries = {};

  // Logo management
  String logoUrl = '';
  File? _logoFile;
  File? get logoFile => _logoFile;

  String _email = '';
  String? get email => _email;

  String _name = '';
  String? get name => _name;

  // For file upload status
  final ReactiveValue<bool> _isUploading = ReactiveValue<bool>(false);
  bool get isUploading => _isUploading.value;

  final ReactiveValue<double> _uploadProgress = ReactiveValue<double>(0.0);
  double get uploadProgress => _uploadProgress.value;

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  bool _didChange = false;
  bool get didChange => _didChange;

  Organization? _organization;

  void init(Organization? organization) async {
    setBusy(true);

    if (organization == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final response = await _dialogService.showCustomDialog(
          variant: DialogType.loader,
          data: LoaderDialogAttributes(
            task: () => _organizationService.getProfile(),
          ),
        );

        if (response?.data != null) {
          ((response?.data) as EitherResult<Organization>).fold(
            (exception) {
              Fluttertoast.showToast(msg: exception.toString());
            },
            (org) {
              _organization = org;
              _populateFormWithOrgData(org);
              _isEditing = true;
            },
          );
        }
      });
    } else {
      _organization = organization;
      _populateFormWithOrgData(organization);
      _isEditing = true;
    }

    _addTextChangedListeners();
    setBusy(false);
  }

  void addUnit() {
    final newIndex = _units.value.length;
    _units.value = [..._units.value, Units()];

    // Initialize controllers for the new unit
    unitNameControllers[newIndex] = TextEditingController();
    unitLocalityControllers[newIndex] = TextEditingController();
    unitCountries[newIndex] = null;

    // Add listeners
    unitNameControllers[newIndex]?.addListener(_onFormChanged);
    unitLocalityControllers[newIndex]?.addListener(_onFormChanged);

    _onFormChanged();
    notifyListeners();
  }

  void removeUnit(int index) {
    if (index < _units.value.length) {
      // Dispose controllers
      unitNameControllers[index]?.dispose();
      unitLocalityControllers[index]?.dispose();

      // Remove from lists
      _units.value = List.from(_units.value)..removeAt(index);

      // Rebuild controller maps with updated indices
      _rebuildControllerMaps();

      _onFormChanged();
      notifyListeners();
    }
  }

  void updateUnitCountry(int index, String? country) {
    if (index < _units.value.length) {
      unitCountries[index] = country;
      _onFormChanged();
      notifyListeners();
    }
  }

  void _rebuildControllerMaps() {
    final newNameControllers = <int, TextEditingController>{};
    final newLocalityControllers = <int, TextEditingController>{};
    final newCountries = <int, String?>{};

    for (int i = 0; i < _units.value.length; i++) {
      if (unitNameControllers.containsKey(i)) {
        newNameControllers[i] = unitNameControllers[i]!;
        newLocalityControllers[i] = unitLocalityControllers[i]!;
        newCountries[i] = unitCountries[i];
      }
    }

    unitNameControllers = newNameControllers;
    unitLocalityControllers = newLocalityControllers;
    unitCountries = newCountries;
  }

  List<Map<String, dynamic>> _getUnitsData() {
    List<Map<String, dynamic>> unitsData = [];

    for (int i = 0; i < _units.value.length; i++) {
      final name = unitNameControllers[i]?.text ?? '';
      final locality = unitLocalityControllers[i]?.text ?? '';
      final country = unitCountries[i];

      if (name.isNotEmpty || locality.isNotEmpty || country != null) {
        unitsData.add({'name': name, 'country': country, 'locality': locality});
      }
    }

    return unitsData;
  }

  void _populateFormWithOrgData(Organization org) {
    AppLogger.info('Populating form with org data: ${org.toJson()}');

    // Set basic organization fields
    nameController.text = org.name ?? '';
    yourNameController.text = org.yourName ?? '';
    phoneController.text = org.phone ?? '';
    phone2Controller.text = org.phone2 ?? '';
    emailController.text = org.email ?? '';
    _email = org.email ?? "";
    _name = org.name ?? "";
    email2Controller.text = org.email2 ?? '';
    organizationType.text =
        getUser().organizationType == OrganizationType.manufacturer
            ? 'Manufacturer'
            : 'Processor';

    // Set designation
    if (org.designation != null) {
      if (['md', 'ceo', 'partner', 'chairman'].contains(org.designation)) {
        _designationType.value = org.designation!;
      } else {
        _designationType.value = 'others';
        otherDesignationController.text = org.designation ?? '';
        _showOtherDesignation.value = true;
      }
    }

    // Set logo URL
    logoUrl = org.logo ?? '';
    _language = org.preferredLanguage ?? 'English';

    // Set corporate address fields
    if (org.address != null) {
      addressLine1Controller.text = org.address!.addressLine1 ?? '';
      addressLine2Controller.text = org.address!.addressLine2 ?? '';
      cityController.text = org.address!.city ?? '';
      stateController.text = org.address!.state ?? '';
      countryController.text = org.address!.country ?? '';
      _country.value = org.address!.country ?? 'India';
      pinCodeController.text = org.address!.pinCode ?? '';
    }

    // Set factory address fields
    if (org.factoryAddress != null) {
      factoryAddressLine1Controller.text =
          org.factoryAddress!.addressLine1 ?? '';
      factoryAddressLine2Controller.text =
          org.factoryAddress!.addressLine2 ?? '';
      factoryCityController.text = org.factoryAddress!.city ?? '';
      factoryStateController.text = org.factoryAddress!.state ?? '';
      factoryCountryController.text = org.factoryAddress!.country ?? '';
      _factoryCountry.value = org.factoryAddress!.country ?? 'India';
      factoryPinCodeController.text = org.factoryAddress!.pinCode ?? '';

      // Check if addresses are the same
      _sameAsCorpAddress.value = _checkIfAddressesAreSame(org);
    }

    // Handle units - Fixed this part
    if (org.units != null && org.units!.isNotEmpty) {
      _units.value = List.from(org.units!);

      // Initialize controllers for existing units
      for (int i = 0; i < _units.value.length; i++) {
        final unit = _units.value[i];
        unitNameControllers[i] = TextEditingController(text: unit.name ?? '');
        unitLocalityControllers[i] = TextEditingController(
          text: unit.locality ?? '',
        );
        unitCountries[i] = unit.country;

        // Add listeners
        unitNameControllers[i]?.addListener(_onFormChanged);
        unitLocalityControllers[i]?.addListener(_onFormChanged);
      }
    }

    // Set additional fields
    establishedYearController.text = org.establishedYear?.toString() ?? '';
    descriptionController.text = org.description ?? '';
  }

  bool _checkIfAddressesAreSame(Organization org) {
    if (org.address == null || org.factoryAddress == null) return false;

    return org.address!.addressLine1 == org.factoryAddress!.addressLine1 &&
        org.address!.addressLine2 == org.factoryAddress!.addressLine2 &&
        org.address!.city == org.factoryAddress!.city &&
        org.address!.state == org.factoryAddress!.state &&
        org.address!.country == org.factoryAddress!.country &&
        org.address!.pinCode == org.factoryAddress!.pinCode;
  }

  void _addTextChangedListeners() {
    // Add listeners for all fields
    nameController.addListener(_onFormChanged);
    yourNameController.addListener(_onFormChanged);
    phoneController.addListener(_onFormChanged);
    phone2Controller.addListener(_onFormChanged);
    emailController.addListener(_onFormChanged);
    email2Controller.addListener(_onFormChanged);
    otherDesignationController.addListener(_onFormChanged);

    addressLine1Controller.addListener(_onFormChanged);
    addressLine2Controller.addListener(_onFormChanged);
    cityController.addListener(_onFormChanged);
    stateController.addListener(_onFormChanged);
    countryController.addListener(_onFormChanged);
    pinCodeController.addListener(_onFormChanged);

    factoryAddressLine1Controller.addListener(_onFormChanged);
    factoryAddressLine2Controller.addListener(_onFormChanged);
    factoryCityController.addListener(_onFormChanged);
    factoryStateController.addListener(_onFormChanged);
    factoryCountryController.addListener(_onFormChanged);
    factoryPinCodeController.addListener(_onFormChanged);

    establishedYearController.addListener(_onFormChanged);
    descriptionController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (!_didChange) {
      _didChange = true;
      notifyListeners();
    }
  }

  // Calculate profile completion percentage
  double calculateProfileCompletion() {
    int totalFields = 13; // Count of primary fields we're tracking
    int filledFields = 0;

    // Check basic info
    if (nameController.text.isNotEmpty) filledFields++;
    if (yourNameController.text.isNotEmpty) filledFields++;
    if (phoneController.text.isNotEmpty) filledFields++;
    if (emailController.text.isNotEmpty) filledFields++;

    // Check corporate address
    if (addressLine1Controller.text.isNotEmpty) filledFields++;
    if (cityController.text.isNotEmpty) filledFields++;
    if (stateController.text.isNotEmpty) filledFields++;
    if (countryController.text.isNotEmpty) filledFields++;
    if (pinCodeController.text.isNotEmpty) filledFields++;

    // Check additional info
    if (establishedYearController.text.isNotEmpty) filledFields++;
    if (descriptionController.text.isNotEmpty) filledFields++;

    // Check logo
    if (logoFile != null || logoUrl.isNotEmpty) filledFields++;

    // Check designation
    if (designationType != null) {
      if (designationType != 'others' ||
          otherDesignationController.text.isNotEmpty) {
        filledFields++;
      }
    }

    return (filledFields / totalFields) * 100;
  }

  // Logo handlers
  Future<void> onLogoUpload() async {
    await showImagePickerOptions();
  }

  Future<void> showImagePickerOptions() async {
    final result = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.filePickerOptions,
      data: FilePickerOptionsSheetAttributes(),
      title: 'Upload Logo',
      description: 'Choose an option',
      mainButtonTitle: 'Cancel',
    );

    if (result?.confirmed == true) {
      final option = result?.data;
      if (option == 'camera') {
        await takePhoto();
      } else if (option == 'gallery') {
        await pickGalleryImage();
      }
    }
  }

  Future<void> pickGalleryImage() async {
    final pickerResult = await _filePickerService.pickImageFromGallery(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );

    pickerResult.fold(
      (failure) {
        // Only show error if it's not "No image selected"
        if (failure.message != 'No image selected') {
          Fluttertoast.showToast(
            msg: failure.message,
            backgroundColor: Colors.red,
          );
        }
      },
      (file) {
        _logoFile = file;
        _onFormChanged();
        notifyListeners();
      },
    );
  }

  Future<void> takePhoto() async {
    final pickerResult = await _filePickerService.takePhoto(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );

    pickerResult.fold(
      (failure) {
        // Only show error if it's not "No photo taken"
        if (failure.message != 'No photo taken') {
          Fluttertoast.showToast(
            msg: failure.message,
            backgroundColor: Colors.red,
          );
        }
      },
      (file) {
        _logoFile = file;
        _onFormChanged();
        notifyListeners();
      },
    );
  }

  Future<String?> _uploadLogo() async {
    if (_logoFile == null) return logoUrl; // Return existing URL if no new file

    _isUploading.value = true;
    _uploadProgress.value = 0.0;
    notifyListeners();

    final result = await _fileUploadService.uploadFileWithProgress(_logoFile!, (
      progress,
    ) {
      _uploadProgress.value = progress;
      notifyListeners();
    });

    _isUploading.value = false;
    _uploadProgress.value = 1.0;
    notifyListeners();

    // Return the new URL if successful, otherwise return null
    return result.fold((failure) {
      AppLogger.error('Failed to upload logo: ${failure.message}');
      Fluttertoast.showToast(
        msg: 'Failed to upload logo: ${failure.message}',
        backgroundColor: Colors.red,
      );
      return null;
    }, (url) => url);
  }

  void onLogoRemove() {
    logoUrl = '';
    _logoFile = null;
    _onFormChanged();
    notifyListeners();
  }

  // Save organization data
  Future<void> onSave() async {
    // Allow saving with partial information
    if (formKey.currentState?.validate() ?? true) {
      setBusy(true);

      try {
        // Upload logo if we have a new one
        String? uploadedLogoUrl;
        if (_logoFile != null) {
          uploadedLogoUrl = await _uploadLogo();
          if (uploadedLogoUrl == null) {
            // Logo upload failed, but we'll continue with other changes
            Fluttertoast.showToast(
              msg: "Logo upload failed, continuing with other changes",
              backgroundColor: Colors.orange,
            );
          }
        }

        // Get designation value
        String designationValue = designationType;
        if (designationType == 'others' &&
            otherDesignationController.text.isNotEmpty) {
          designationValue = otherDesignationController.text;
        }

        final organizationData = {
          "name": nameController.text,
          "yourName": yourNameController.text,
          "designation": designationValue,
          "phone": phoneController.text,
          "phone2": phone2Controller.text,
          "email": emailController.text,
          "email2": email2Controller.text,
          "preferredLanguage": _language,
          "address": {
            "addressLine1": addressLine1Controller.text,
            "addressLine2": addressLine2Controller.text,
            "city": cityController.text,
            "state": stateController.text,
            "country": countryController.text,
            "pinCode": pinCodeController.text,
          },
          "factoryAddress":
              sameAsCorpAddress
                  ? {
                    // Copy corporate address if checkbox is checked
                    "addressLine1": addressLine1Controller.text,
                    "addressLine2": addressLine2Controller.text,
                    "city": cityController.text,
                    "state": stateController.text,
                    "country": countryController.text,
                    "pinCode": pinCodeController.text,
                  }
                  : {
                    // Use factory address fields
                    "addressLine1": factoryAddressLine1Controller.text,
                    "addressLine2": factoryAddressLine2Controller.text,
                    "city": factoryCityController.text,
                    "state": factoryStateController.text,
                    "country": factoryCountryController.text,
                    "pinCode": factoryPinCodeController.text,
                  },
          "logo":
              uploadedLogoUrl ??
              logoUrl, // Use newly uploaded URL or existing one
          "establishedYear": int.tryParse(establishedYearController.text),
          "description": descriptionController.text,
          "units": _getUnitsData(),
        };

        final response = await _dialogService.showCustomDialog(
          variant: DialogType.loader,
          data: LoaderDialogAttributes(
            task:
                () => _organizationService.updateOrganization(organizationData),
          ),
        );

        if (response?.data != null) {
          ((response?.data) as EitherResult<bool>).fold(
            (exception) {
              Fluttertoast.showToast(msg: exception.toString());
            },
            (success) {
              Fluttertoast.showToast(
                msg:
                    _isEditing
                        ? "Organization updated successfully!"
                        : "Organization created successfully!",
              );
              // _navigationService.back(result: true); // Return true to indicate success
            },
          );
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Error: $e");
      } finally {
        setBusy(false);
      }
    } else {
      Fluttertoast.showToast(msg: "Please check the form for errors");
    }
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    nameController.dispose();
    yourNameController.dispose();
    phoneController.dispose();
    phone2Controller.dispose();
    emailController.dispose();
    email2Controller.dispose();
    otherDesignationController.dispose();

    // Corporate address controllers
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    pinCodeController.dispose();

    // Factory address controllers
    factoryAddressLine1Controller.dispose();
    factoryAddressLine2Controller.dispose();
    factoryCityController.dispose();
    factoryStateController.dispose();
    factoryCountryController.dispose();
    factoryPinCodeController.dispose();

    // Additional info controllers
    establishedYearController.dispose();
    descriptionController.dispose();

    for (var controller in unitNameControllers.values) {
      controller.dispose();
    }
    for (var controller in unitLocalityControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  String _fullPhoneNumber = '';
  String get fullPhoneNumber => _fullPhoneNumber;

  void updatePhoneNumber(PhoneNumber phoneNumber) {
    _fullPhoneNumber = '${phoneNumber.countryCode}${phoneNumber.number}';
    _onFormChanged();
  }

  void updatePhoneNumberFromString(String phoneNumber) {
    _fullPhoneNumber = phoneNumber;
    _onFormChanged();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [];
}
