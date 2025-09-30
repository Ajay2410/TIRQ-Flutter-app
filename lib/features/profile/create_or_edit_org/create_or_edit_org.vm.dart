import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/countries.dart' as intl;
import 'package:intl_phone_field/phone_number.dart' as intl;
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/models/organization.dart';
import 'package:manager/core/models/profile_model.dart';
import 'package:manager/resources/app_resources/app_maps.dart';
import 'package:manager/widgets/bottom_sheets/file_picker_options/file_picker_options_sheet.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/utils/app_logger.dart';
import '../../../services/api.service.dart';
import '../../../services/bottom_sheets.service.dart';
import '../../../services/dialogs.service.dart';
import '../../../services/file_picker.service.dart';
import '../../../widgets/dialogs/loader/loader_dialog.view.dart';

class UpdateOrganizationViewModel extends ReactiveViewModel {
  final _dialogService = locator<DialogService>();
  final _apiService = locator<ApiService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _filePickerService = FilePickerService();

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Organization basic info controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController yourNameController = TextEditingController();
  final TextEditingController unitNameController = TextEditingController();
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
      if (profileModel?.corporateAddress != null) {
        // Copy from profile model data
        factoryAddressLine1Controller.text =
            profileModel!.corporateAddress!.addressLine1 ?? '';
        factoryAddressLine2Controller.text =
            profileModel!.corporateAddress!.addressLine2 ?? '';
        factoryCityController.text = profileModel!.corporateAddress!.city ?? '';
        factoryStateController.text =
            profileModel!.corporateAddress!.state ?? '';
        factoryCountryController.text =
            profileModel!.corporateAddress!.country ?? '';
        factoryPinCodeController.text =
            profileModel!.corporateAddress!.pincode ?? '';
        _factoryCountry.value = _getValidCountry(
          profileModel!.corporateAddress!.country,
        );
      } else {
        // Fallback to controller values
        factoryAddressLine1Controller.text = addressLine1Controller.text;
        factoryAddressLine2Controller.text = addressLine2Controller.text;
        factoryCityController.text = cityController.text;
        factoryStateController.text = stateController.text;
        factoryCountryController.text = countryController.text;
        factoryPinCodeController.text = pinCodeController.text;
        _factoryCountry.value = _country.value;
      }
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

  // Helper method to validate and get a valid country value
  String _getValidCountry(String? country) {
    if (country == null || country.isEmpty) return 'India';

    // Check if the country is already in our list
    if (countries.contains(country)) return country;

    // Handle regional variants like "India (Assam)" -> "India"
    if (country.contains('(')) {
      String mainCountry = country.split('(')[0].trim();
      if (countries.contains(mainCountry)) return mainCountry;
    }

    // Handle specific mappings for common variations
    switch (country.toLowerCase()) {
      case 'uae':
        return 'United Arab Emirates';
      case 'usa':
      case 'us':
        return 'United States';
      case 'uk':
        return 'United Kingdom';
      case 'south korea':
        return 'South Korea';
      case 'north korea':
        return 'North Korea';
    }

    return 'India'; // Default fallback
  }

  String _countrySearchQuery = '';
  String get countrySearchQuery => _countrySearchQuery;

  intl.Country? _selectedCountry;
  intl.Country? get selectedCountry => _selectedCountry;

  intl.Country? _selectedCountryF;
  intl.Country? get selectedCountryF => _selectedCountryF;

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

  // Method to save personal information section
  Future<void> savePersonalInfo() async {
    // Prepare profile data for personal info update
    final profileData = {
      "unitName": unitNameController.text,
      "designation":
          _designationType.value == 'Other'
              ? otherDesignationController.text
              : _designationType.value,
    };

    // Show loader dialog
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(task: () => updateProfileData(profileData)),
    );

    if (response?.confirmed == true) {
      isPersonalInfoEditable = false;
      notifyListeners();
    }
  }

  // Method to save corporate address section
  Future<void> saveCorporateAddress() async {
    // Prepare profile data for corporate address update
    final profileData = {
      "corporateAddress": {
        "addressLine1": addressLine1Controller.text,
        "addressLine2": addressLine2Controller.text,
        "city": cityController.text,
        "state": stateController.text,
        "country": countryController.text,
        "pincode": pinCodeController.text,
      },
    };

    // Show loader dialog
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(task: () => updateProfileData(profileData)),
    );

    if (response?.confirmed == true) {
      isCorporateAddressEditable = false;
      notifyListeners();
    }
  }

  // Method to save factory address section
  Future<void> saveFactoryAddress() async {
    // Prepare profile data for factory address update
    final profileData = {
      "factoryAddress": {
        "addressLine1": factoryAddressLine1Controller.text,
        "addressLine2": factoryAddressLine2Controller.text,
        "city": factoryCityController.text,
        "state": factoryStateController.text,
        "country": factoryCountryController.text,
        "pincode": factoryPinCodeController.text,
      },
    };

    // Show loader dialog
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(task: () => updateProfileData(profileData)),
    );

    if (response?.confirmed == true) {
      isFactoryAddressEditable = false;
      notifyListeners();
    }
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

  void updateSelectedCountry(intl.Country? country) {
    _selectedCountry = country;
    notifyListeners();
  }

  void updateSelectedCountryF(intl.Country? country) {
    _selectedCountryF = country;
    notifyListeners();
  }

  // List of countries
  List<String> countries = [
    "Afghanistan",
    "Albania",
    "Algeria",
    "Argentina",
    "Armenia",
    "Australia",
    "Austria",
    "Azerbaijan",
    "Bahrain",
    "Bangladesh",
    "Belarus",
    "Belgium",
    "Brazil",
    "Brunei",
    "Bulgaria",
    "Cambodia",
    "Canada",
    "Chile",
    "China",
    "Colombia",
    "Croatia",
    "Cyprus",
    "Czech Republic",
    "Denmark",
    "Egypt",
    "Estonia",
    "Finland",
    "France",
    "Georgia",
    "Germany",
    "Greece",
    "Hungary",
    "Iceland",
    "India",
    "Indonesia",
    "Iran",
    "Iraq",
    "Ireland",
    "Israel",
    "Italy",
    "Japan",
    "Jordan",
    "Kazakhstan",
    "Kuwait",
    "Kyrgyzstan",
    "Latvia",
    "Lebanon",
    "Lithuania",
    "Luxembourg",
    "Malaysia",
    "Mexico",
    "Morocco",
    "Netherlands",
    "New Zealand",
    "Norway",
    "Oman",
    "Pakistan",
    "Peru",
    "Philippines",
    "Poland",
    "Portugal",
    "Qatar",
    "Romania",
    "Russia",
    "Saudi Arabia",
    "Singapore",
    "Slovakia",
    "Slovenia",
    "South Africa",
    "South Korea",
    "Spain",
    "Sri Lanka",
    "Sweden",
    "Switzerland",
    "Thailand",
    "Turkey",
    "Ukraine",
    "United Arab Emirates",
    "United Kingdom",
    "United States",
    "Uzbekistan",
    "Vietnam",
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

  final _profileModel = ReactiveValue<ProfileModel?>(null);
  ProfileModel? get profileModel => _profileModel.value;

  void init(Organization? organization) async {
    setBusy(true);

    // Fetch profile data
    await fetchProfileData();

    _addTextChangedListeners();
    setBusy(false);
  }

  Future<void> fetchProfileData() async {
    try {
      final response = await _apiService.get(url: ApiEndpoints.getProfile);

      if (response.statusCode == 200) {
        // Handle different response data types
        Map<String, dynamic> responseData;
        if (response.data is String) {
          responseData = jsonDecode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          responseData = response.data;
        } else {
          AppLogger.error('Invalid response format');
          return;
        }

        // Check if response has nested data structure
        ProfileModel profile;
        if (responseData['success'] == true && responseData['data'] != null) {
          profile = ProfileModel.fromJson(responseData['data']);
        } else {
          // Direct profile data parsing - handle user field as string ID
          Map<String, dynamic> profileData = Map<String, dynamic>.from(
            responseData,
          );
          if (profileData['user'] is String) {
            // If user is a string ID, create a minimal User object
            profileData['user'] = {
              '_id': profileData['user'],
              'fullName': '',
              'email': '',
            };
          }
          profile = ProfileModel.fromJson(profileData);
        }

        _profileModel.value = profile;
        _populateFormWithProfileData(profile);
        notifyListeners();
      } else {
        AppLogger.error('Failed to fetch profile: ${response.statusMessage}');
      }
    } catch (e) {
      AppLogger.error('Error fetching profile data: $e');
    }
  }

  Future<void> updateProfileData(Map<String, dynamic> profileData) async {
    try {
      final response = await _apiService.put(
        url: ApiEndpoints.updateProfile,
        data: profileData,
      );

      if (response.statusCode == 200) {
        // Handle different response data types
        Map<String, dynamic> responseData;
        if (response.data is String) {
          responseData = jsonDecode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          responseData = response.data;
        } else {
          AppLogger.error('Invalid response format');
          Fluttertoast.showToast(
            msg: 'Invalid response format',
            backgroundColor: Colors.red,
          );
          return;
        }

        // Check if response has nested data structure
        ProfileModel profile;
        if (responseData['success'] == true && responseData['data'] != null) {
          profile = ProfileModel.fromJson(responseData['data']);
        } else {
          // Direct profile data parsing - handle user field as string ID
          Map<String, dynamic> profileData = Map<String, dynamic>.from(
            responseData,
          );
          if (profileData['user'] is String) {
            // If user is a string ID, create a minimal User object
            profileData['user'] = {
              '_id': profileData['user'],
              'fullName': _profileModel.value?.user?.fullName ?? '',
              'email': _profileModel.value?.user?.email ?? '',
            };
          }
          profile = ProfileModel.fromJson(profileData);
        }

        _profileModel.value = profile;
        _populateFormWithProfileData(profile);
        notifyListeners();
        Fluttertoast.showToast(
          msg: 'Profile updated successfully',
          backgroundColor: Colors.green,
        );
      } else {
        AppLogger.error('Failed to update profile: ${response.statusMessage}');
        Fluttertoast.showToast(
          msg: 'Failed to update profile: ${response.statusMessage}',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      AppLogger.error('Error updating profile data: $e');
      Fluttertoast.showToast(
        msg: 'Error updating profile: $e',
        backgroundColor: Colors.red,
      );
    }
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

  void _populateFormWithProfileData(ProfileModel profile) {
    AppLogger.info('Populating form with profile data: ${profile.toJson()}');

    // Set basic organization fields from profile
    if (profile.user != null) {
      nameController.text = profile.user!.fullName ?? '';
      yourNameController.text = profile.user!.fullName ?? '';
      phoneController.text = profile.user!.phone ?? '';
      emailController.text = profile.user!.email ?? '';
      _email = profile.user!.email ?? "";
      _name = profile.user!.fullName ?? "";
    }

    // Set organization name
    organizationType.text = profile.organizationName ?? '';

    // Set unit name
    unitNameController.text = profile.unitName ?? '';

    // Set designation
    if (profile.designation != null && profile.designation!.isNotEmpty) {
      // Map API designation values to dropdown values
      String apiDesignation = profile.designation!.toLowerCase();
      if (apiDesignation.contains('managing director') ||
          apiDesignation.contains('md')) {
        _designationType.value = 'MD';
      } else if (apiDesignation.contains('chief executive officer') ||
          apiDesignation.contains('ceo')) {
        _designationType.value = 'CEO';
      } else if (apiDesignation.contains('chairman') ||
          apiDesignation.contains('chairperson')) {
        _designationType.value = 'Chairman';
      } else {
        _designationType.value = 'Other';
        otherDesignationController.text = profile.designation ?? '';
        _showOtherDesignation.value = true;
      }
    }

    // Set corporate address fields
    if (profile.corporateAddress != null) {
      addressLine1Controller.text =
          profile.corporateAddress!.addressLine1 ?? '';
      addressLine2Controller.text =
          profile.corporateAddress!.addressLine2 ?? '';
      cityController.text = profile.corporateAddress!.city ?? '';
      stateController.text = profile.corporateAddress!.state ?? '';
      String corporateCountry = _getValidCountry(
        profile.corporateAddress!.country,
      );
      countryController.text = corporateCountry;
      _country.value = corporateCountry;
      pinCodeController.text = profile.corporateAddress!.pincode ?? '';
    }

    // Set factory address fields
    if (profile.factoryAddress != null) {
      factoryAddressLine1Controller.text =
          profile.factoryAddress!.addressLine1 ?? '';
      factoryAddressLine2Controller.text =
          profile.factoryAddress!.addressLine2 ?? '';
      factoryCityController.text = profile.factoryAddress!.city ?? '';
      factoryStateController.text = profile.factoryAddress!.state ?? '';
      String factoryCountry = _getValidCountry(profile.factoryAddress!.country);
      factoryCountryController.text = factoryCountry;
      _factoryCountry.value = factoryCountry;
      factoryPinCodeController.text = profile.factoryAddress!.pincode ?? '';

      // Check if addresses are the same
      _sameAsCorpAddress.value = _checkIfAddressesAreSameFromProfile(profile);
    }
  }

  bool _checkIfAddressesAreSameFromProfile(ProfileModel profile) {
    if (profile.corporateAddress == null || profile.factoryAddress == null)
      return false;

    return profile.corporateAddress!.addressLine1 ==
            profile.factoryAddress!.addressLine1 &&
        profile.corporateAddress!.addressLine2 ==
            profile.factoryAddress!.addressLine2 &&
        profile.corporateAddress!.city == profile.factoryAddress!.city &&
        profile.corporateAddress!.state == profile.factoryAddress!.state &&
        profile.corporateAddress!.country == profile.factoryAddress!.country &&
        profile.corporateAddress!.pincode == profile.factoryAddress!.pincode;
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
    if (designationType.isNotEmpty) {
      if (designationType != 'Other' ||
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

  void onLogoRemove() {
    logoUrl = '';
    _logoFile = null;
    _onFormChanged();
    notifyListeners();
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

  void updatePhoneNumber(intl.PhoneNumber phoneNumber) {
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
