import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'dart:convert';
import 'dart:io';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/models/profile_model.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/services/file_picker.service.dart';
import 'package:manager/services/profile.service.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/configs.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UpdateOrganizationViewModel extends ReactiveViewModel {
  final _apiService = locator<ApiService>();
  final _filePickerService = FilePickerService();
  final _profileService = locator<ProfileService>();

  // ProfileModel to store API response
  final ReactiveValue<ProfileModel?> _profileModel =
      ReactiveValue<ProfileModel?>(null);
  ProfileModel? get profileModel => _profileModel.value;

  // Profile image file
  File? _profileImageFile;
  File? get profileImageFile => _profileImageFile;

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Organization basic info controllers
  final TextEditingController yourNameController = TextEditingController();
  final TextEditingController unitNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

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
      notifyListeners();
    }
  }

  // Language selection
  String _language = 'English';
  String get language => _language;

  void updateLanguage(String value) {
    _language = value;
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
      copyCorporateToFactory();
    }

    notifyListeners();
  }

  // Country dropdown
  final ReactiveValue<String> _country = ReactiveValue<String>('India');
  String get country => _country.value;

  void updateCountry(String? value) {
    if (value != null) {
      _country.value = value;
      countryController.text = value;
      notifyListeners();
    }
  }

  // Factory country dropdown
  final ReactiveValue<String> _factoryCountry = ReactiveValue<String>('India');
  String get factoryCountry => _factoryCountry.value;

  void updateFactoryCountry(String? value) {
    if (value != null) {
      _factoryCountry.value = value;
      factoryCountryController.text = value;
      notifyListeners();
    }
  }

  // Edit mode flags
  bool? isPersonalInfoEditable = false;
  bool? isCorporateAddressEditable = false;
  bool? isFactoryAddressEditable = false;
  bool? isAdditionalInfoEditable = false;

  void togglePersonalInfoEdit() async {
    if (isPersonalInfoEditable ?? false) {
      // Currently in edit mode, save the data
      await updatePersonalInfo();
    } else {
      // Currently in view mode, switch to edit mode
      isPersonalInfoEditable = true;
      notifyListeners();
    }
  }

  void toggleCorporateAddressEdit() async {
    if (isCorporateAddressEditable ?? false) {
      // Currently in edit mode, save the data
      await updateCorporateAddress();
    } else {
      // Currently in view mode, switch to edit mode
      isCorporateAddressEditable = true;
      notifyListeners();
    }
  }

  void toggleFactoryAddressEdit() async {
    if (isFactoryAddressEditable ?? false) {
      // Currently in edit mode, save the data
      await updateFactoryAddress();
    } else {
      // Currently in view mode, switch to edit mode
      isFactoryAddressEditable = true;
      notifyListeners();
    }
  }

  // Copy corporate address to factory address
  void copyCorporateToFactory() {
    factoryAddressLine1Controller.text = addressLine1Controller.text;
    factoryAddressLine2Controller.text = addressLine2Controller.text;
    factoryCityController.text = cityController.text;
    factoryStateController.text = stateController.text;
    factoryCountryController.text = countryController.text;
    _factoryCountry.value = _country.value;
    factoryPinCodeController.text = pinCodeController.text;
    notifyListeners();
  }

  void toggleAdditionalInfoEdit() {
    isAdditionalInfoEditable = !(isAdditionalInfoEditable ?? false);
    notifyListeners();
  }

  // Logo management
  String logoUrl = '';
  bool hasLogoFile = false;

  // Profile image management
  String profileImageUrl = '';
  bool hasProfileImageFile = false;

  // Upload status
  final ReactiveValue<bool> _isUploading = ReactiveValue<bool>(false);
  bool get isUploading => _isUploading.value;

  final ReactiveValue<double> _uploadProgress = ReactiveValue<double>(0.0);
  double get uploadProgress => _uploadProgress.value;

  // List of countries for dropdown
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

  // Units management
  final ReactiveValue<List<Map<String, dynamic>>> _units =
      ReactiveValue<List<Map<String, dynamic>>>([]);
  List<Map<String, dynamic>> get units => _units.value;

  Map<int, TextEditingController> unitNameControllers = {};
  Map<int, TextEditingController> unitLocalityControllers = {};
  Map<int, String?> unitCountries = {};

  void addUnit() {
    final newIndex = _units.value.length;
    _units.value = [
      ..._units.value,
      {'name': '', 'locality': '', 'country': null},
    ];

    // Initialize controllers for the new unit
    unitNameControllers[newIndex] = TextEditingController();
    unitLocalityControllers[newIndex] = TextEditingController();
    unitCountries[newIndex] = null;

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

      notifyListeners();
    }
  }

  void updateUnitCountry(int index, String? country) {
    if (index < _units.value.length) {
      unitCountries[index] = country;
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

  // Image picker methods (UI only)
  Future<void> pickGalleryImage() async {
    // UI placeholder - no actual file picking logic
    hasLogoFile = true;
    notifyListeners();
  }

  Future<void> takePhoto() async {
    // UI placeholder - no actual camera logic
    hasLogoFile = true;
    notifyListeners();
  }

  void onLogoRemove() {
    logoUrl = '';
    hasLogoFile = false;
    notifyListeners();
  }

  Future<void> pickProfileImageFromGallery() async {
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
        _profileImageFile = file;
        hasProfileImageFile = true;
        notifyListeners();
        // Automatically upload the selected image
        uploadProfileImage();
      },
    );
  }

  Future<void> takeProfilePhoto() async {
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
        _profileImageFile = file;
        hasProfileImageFile = true;
        notifyListeners();
        // Automatically upload the captured photo
        uploadProfileImage();
      },
    );
  }

  void onProfileImageRemove() {
    profileImageUrl = '';
    hasProfileImageFile = false;
    _profileImageFile = null;
    notifyListeners();
  }

  // Upload profile image to server
  Future<void> uploadProfileImage() async {
    if (_profileImageFile == null) return;

    _isUploading.value = true;
    notifyListeners();

    try {
      // Create FormData for image upload
      final formData = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(
          _profileImageFile!.path,
          filename:
              'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: DioMediaType.parse('image/jpeg'),
        ),
      });

      final response = await _apiService.put(
        url: ApiEndpoints.updateProfile,
        data: formData,
      );

      if (response.statusCode == 200) {
        // Handle response
        Map<String, dynamic> responseData;
        if (response.data is String) {
          responseData = jsonDecode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          responseData = response.data;
        } else {
          AppLogger.error('Invalid response format');
          return;
        }

        // Use ProfileService to update profile data
        await _profileService.updateProfileData(responseData);

        // Refresh profile data from API to get latest data
        await refreshProfileData();

        Fluttertoast.showToast(
          msg: 'Profile image updated successfully',
          backgroundColor: Colors.green,
        );

        // Clear the file since it's now uploaded
        _profileImageFile = null;
        notifyListeners();
      } else {
        AppLogger.error(
          'Failed to update profile image: ${response.statusMessage}',
        );
        Fluttertoast.showToast(
          msg: 'Failed to update profile image',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      AppLogger.error('Error uploading profile image: $e');
      Fluttertoast.showToast(
        msg: 'Error uploading profile image: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      _isUploading.value = false;
      notifyListeners();
    }
  }

  // Update personal information
  Future<void> updatePersonalInfo() async {
    setBusy(true);
    notifyListeners();

    try {
      // Prepare the data to send
      final updateData = {
        'organizationName': organizationType.text,
        'unitName': unitNameController.text,
        'fullName': yourNameController.text,
        'designation': _designationType.value,
      };

      AppLogger.info('Updating personal info with data: $updateData');

      // Use ProfileService to update profile data
      await _profileService.updateProfileData(updateData);

      // Refresh profile data from API to get latest data
      await refreshProfileData();

      // Switch back to view mode
      isPersonalInfoEditable = false;

      Fluttertoast.showToast(
        msg: 'Personal information updated successfully',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      AppLogger.error('Error updating personal info: $e');
      Fluttertoast.showToast(
        msg: 'Error updating personal information: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Update corporate address
  Future<void> updateCorporateAddress() async {
    setBusy(true);
    notifyListeners();

    try {
      // Prepare the corporate address data to send
      final updateData = {
        'corporateAddress': {
          'addressLine1': addressLine1Controller.text,
          'addressLine2': addressLine2Controller.text,
          'city': cityController.text,
          'state': stateController.text,
          'country': _country.value,
          'pincode': pinCodeController.text,
        },
      };

      AppLogger.info('Updating corporate address with data: $updateData');

      // Use ProfileService to update profile data
      await _profileService.updateProfileData(updateData);

      // Refresh profile data from API to get latest data
      await refreshProfileData();

      // Switch back to view mode
      isCorporateAddressEditable = false;

      Fluttertoast.showToast(
        msg: 'Corporate address updated successfully',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      AppLogger.error('Error updating corporate address: $e');
      Fluttertoast.showToast(
        msg: 'Error updating corporate address: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Update factory address
  Future<void> updateFactoryAddress() async {
    setBusy(true);
    notifyListeners();

    try {
      // Prepare the factory address data to send
      final updateData = {
        'factoryAddress': {
          'addressLine1': factoryAddressLine1Controller.text,
          'addressLine2': factoryAddressLine2Controller.text,
          'city': factoryCityController.text,
          'state': factoryStateController.text,
          'country': _factoryCountry.value,
          'pincode': factoryPinCodeController.text,
        },
      };

      AppLogger.info('Updating factory address with data: $updateData');

      // Use ProfileService to update profile data
      await _profileService.updateProfileData(updateData);

      // Refresh profile data from API to get latest data
      await refreshProfileData();

      // Switch back to view mode
      isFactoryAddressEditable = false;

      Fluttertoast.showToast(
        msg: 'Factory address updated successfully',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      AppLogger.error('Error updating factory address: $e');
      Fluttertoast.showToast(
        msg: 'Error updating factory address: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Initialize the view model and load profile data
  Future<void> init() async {
    setBusy(true);
    await loadProfileData();
    setBusy(false);
  }

  // Refresh profile data from API after update
  Future<void> refreshProfileData() async {
    try {
      AppLogger.info('Refreshing profile data from API...');

      // Use ProfileService to refresh profile data
      await _profileService.refreshProfile();

      // Update local model with fresh data
      final updatedProfile = _profileService.globalProfileModel;
      if (updatedProfile != null) {
        _profileModel.value = updatedProfile;
        _populateFormWithProfileData(updatedProfile);
        AppLogger.info('Profile data refreshed successfully');
      }
    } catch (e) {
      AppLogger.error('Error refreshing profile data: $e');
    }
  }

  // Load profile data from ProfileService (with API call if needed)
  Future<void> loadProfileData() async {
    try {
      // First, ensure ProfileService is initialized
      if (!_profileService.isInitialized) {
        AppLogger.info('ProfileService not initialized, initializing now...');
        await _profileService.initializeProfile();
      }

      // Get profile data from ProfileService
      final profile = _profileService.globalProfileModel;
      if (profile != null) {
        _profileModel.value = profile;
        _populateFormWithProfileData(profile);
        AppLogger.info('Profile data loaded from ProfileService');
      } else {
        AppLogger.warning(
          'No profile data available in ProfileService after initialization',
        );
        // Try to fetch profile data directly if global model is still null
        final profileResult = await _profileService.getProfile();
        profileResult.fold(
          (failure) =>
              AppLogger.error('Failed to fetch profile: ${failure.message}'),
          (profileData) {
            _profileModel.value = profileData;
            _populateFormWithProfileData(profileData);
            AppLogger.info('Profile data fetched directly from API');
          },
        );
      }
    } catch (e) {
      AppLogger.error('Error loading profile data: $e');
    }
  }

  // Populate form fields with profile data
  void _populateFormWithProfileData(ProfileModel profileModel) {
    final profile = profileModel.profile;
    if (profile == null) return;

    // Set basic user info
    if (profile.user != null) {
      yourNameController.text = profile.user!.fullName ?? '';
      phoneController.text = profile.user!.phone ?? '';
      emailController.text = profile.user!.email ?? '';
    }

    // Set organization info
    organizationType.text = profile.organizationName ?? '';
    unitNameController.text = profile.unitName ?? '';

    // Set designation
    if (profile.designation != null && profile.designation!.isNotEmpty) {
      _designationType.value = profile.designation!;
    }

    // Set profile image URL
    if (profile.profileImage != null && profile.profileImage!.isNotEmpty) {
      String baseUrl = Configurations().url;
      if (profile.profileImage!.startsWith('/')) {
        profileImageUrl = baseUrl + profile.profileImage!;
      } else {
        profileImageUrl = '$baseUrl/${profile.profileImage!}';
      }
    }

    // Set corporate address
    if (profile.corporateAddress != null) {
      addressLine1Controller.text =
          profile.corporateAddress!.addressLine1 ?? '';
      addressLine2Controller.text =
          profile.corporateAddress!.addressLine2 ?? '';
      cityController.text = profile.corporateAddress!.city ?? '';
      stateController.text = profile.corporateAddress!.state ?? '';
      countryController.text = profile.corporateAddress!.country ?? '';
      _country.value = profile.corporateAddress!.country ?? 'India';
      pinCodeController.text = profile.corporateAddress!.pincode ?? '';
    }

    // Set factory address
    if (profile.factoryAddress != null) {
      factoryAddressLine1Controller.text =
          profile.factoryAddress!.addressLine1 ?? '';
      factoryAddressLine2Controller.text =
          profile.factoryAddress!.addressLine2 ?? '';
      factoryCityController.text = profile.factoryAddress!.city ?? '';
      factoryStateController.text = profile.factoryAddress!.state ?? '';
      factoryCountryController.text = profile.factoryAddress!.country ?? '';
      _factoryCountry.value = profile.factoryAddress!.country ?? 'India';
      factoryPinCodeController.text = profile.factoryAddress!.pincode ?? '';
    }
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    yourNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
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

  // Update phone number from string (used by phone input widget)
  void updatePhoneNumberFromString(String phoneNumber) {
    phoneController.text = phoneNumber;
    notifyListeners();
  }
}
