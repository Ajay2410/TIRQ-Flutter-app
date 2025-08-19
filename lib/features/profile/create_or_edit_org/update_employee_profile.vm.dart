import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:manager/core/models/employee.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/employee_profile.service.dart';
import 'package:manager/widgets/bottom_sheets/file_picker_options/file_picker_options_sheet.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/type_def.dart';
import '../../../resources/app_resources/app_maps.dart';
import '../../../services/bottom_sheets.service.dart';
import '../../../services/dialogs.service.dart';
import '../../../services/file_picker.service.dart';
import '../../../services/file_upload.service.dart';
import '../../../widgets/dialogs/loader/loader_dialog.view.dart';

class EmployeeProfileViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _userProfileService = locator<EmployeeProfileService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _filePickerService = FilePickerService();
  final _fileUploadService = FileUploadService();

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Personal Details controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();

  // Contact Info controllers
  final TextEditingController personalPhoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController personalEmailController = TextEditingController();

  // Current Address controllers
  final TextEditingController currentAddressLine1Controller = TextEditingController();
  final TextEditingController currentAddressLine2Controller = TextEditingController();
  final TextEditingController currentCityController = TextEditingController();
  final TextEditingController currentStateController = TextEditingController();
  final TextEditingController currentCountryController = TextEditingController();
  final TextEditingController currentZipCodeController = TextEditingController();

  // Permanent Address controllers
  final TextEditingController permanentAddressLine1Controller = TextEditingController();
  final TextEditingController permanentAddressLine2Controller = TextEditingController();
  final TextEditingController permanentCityController = TextEditingController();
  final TextEditingController permanentStateController = TextEditingController();
  final TextEditingController permanentCountryController = TextEditingController();
  final TextEditingController permanentZipCodeController = TextEditingController();

  // Emergency Contact controllers
  final TextEditingController emergencyContactNameController = TextEditingController();
  final TextEditingController emergencyPhoneController = TextEditingController();

  // Identification controllers
  final TextEditingController nationalTaxIdController = TextEditingController();

  // Locked Fields controllers (HR Approved)
  final TextEditingController panAadharController = TextEditingController();
  final TextEditingController bankDetailsController = TextEditingController();
  final TextEditingController workRegionController = TextEditingController();
  final TextEditingController reportingManagerController = TextEditingController();
  final TextEditingController joiningDateController = TextEditingController();

  bool isDataChanged = false;

  void markDataChanged() {
    isDataChanged = true;
    notifyListeners();
  }

  String _countrySearchQuery = '';

  String get countrySearchQuery => _countrySearchQuery;

  Country? _selectedCountry;

  Country? get selectedCountry => _selectedCountry;

  List<Country> get filteredCountries {
    if (_countrySearchQuery.isEmpty) {
      return countries.toList();
    }
    return countries.where((country) =>
        country.name.toLowerCase().contains(_countrySearchQuery.toLowerCase())
    ).toList();
  }

  void updateCountrySearchQuery(String query) {
    _countrySearchQuery = query;
    notifyListeners();
  }

  void updateSelectedCountry(Country? country) {
    _selectedCountry = country;
    if (country != null) {
      currentCountryController.text = country.name;
      _currentCountry.value = country.name;

      // Update permanent country if same as current address is checked
      if (_sameAsCurrentAddress.value) {
        permanentCountryController.text = country.name;
        _permanentCountry.value = country.name;
      }
    }
    markDataChanged();
    notifyListeners();
  }

  String _language = 'English';

  String preferredLanguages() {
    return AppMaps.languageMap.entries
        .firstWhere(
          (e) => e.value == _language,
      orElse: () => AppMaps.languageMap.entries.first, // fallback to first entry
    ).key;
  }


  void updateLanguages(String value) {
    _language = AppMaps.languageMap.entries
        .firstWhere((e) => e.key == value).value;
    _onFormChanged();
    notifyListeners();
  }

  void _onFormChanged() {
    if (!_didChange) {
      _didChange = true;
      notifyListeners();
    }
  }

  // Gender dropdown
  final ReactiveValue<String?> _selectedGender = ReactiveValue<String?>(null);

  String? get selectedGender => _selectedGender.value;

  void updateGender(String? value) {
    _selectedGender.value = value;
    markDataChanged();
    notifyListeners();
  }

  // Blood Group dropdown
  final ReactiveValue<String?> _selectedBloodGroup = ReactiveValue<String?>(
      null);

  String? get selectedBloodGroup => _selectedBloodGroup.value;

  void updateBloodGroup(String? value) {
    _selectedBloodGroup.value = value;
    markDataChanged();
    notifyListeners();
  }

  // Emergency relationship
  final ReactiveValue<String?> _emergencyRelationship = ReactiveValue<String?>(
      null);

  String? get emergencyRelationship => _emergencyRelationship.value;

  void updateEmergencyRelationship(String? value) {
    _emergencyRelationship.value = value;
    markDataChanged();
    notifyListeners();
  }

  // Language preference
  final ReactiveValue<String> _preferredLanguage = ReactiveValue<String>(
      'English');

  String get preferredLanguage => _preferredLanguage.value;

  void updateLanguage(String value) {
    _preferredLanguage.value = value;
    markDataChanged();
    notifyListeners();
  }

  // Date of birth
  DateTime? _dateOfBirth;

  DateTime? get dateOfBirth => _dateOfBirth;

  Future<void> selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ??
          DateTime.now().subtract(Duration(days: 18 * 365)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateOfBirth) {
      _dateOfBirth = picked;
      dateOfBirthController.text =
      "${picked.day}/${picked.month}/${picked.year}";
      markDataChanged();
      notifyListeners();
    }
  }

  // Joining Date for HR approved fields
  DateTime? _joiningDate;

  DateTime? get joiningDate => _joiningDate;

  Future<void> selectJoiningDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _joiningDate) {
      _joiningDate = picked;
      joiningDateController.text =
      "${picked.day}/${picked.month}/${picked.year}";
      markDataChanged();
      notifyListeners();
    }
  }

  // Same as current address flag
  final ReactiveValue<bool> _sameAsCurrentAddress = ReactiveValue<bool>(false);

  bool get sameAsCurrentAddress => _sameAsCurrentAddress.value;

  void toggleSameAsCurrentAddress(bool value) {
    _sameAsCurrentAddress.value = value;
    if (value) {
      // Copy current address to permanent address
      permanentAddressLine1Controller.text = currentAddressLine1Controller.text;
      permanentAddressLine2Controller.text = currentAddressLine2Controller.text;
      permanentCityController.text = currentCityController.text;
      permanentStateController.text = currentStateController.text;
      permanentCountryController.text = currentCountryController.text;
      permanentZipCodeController.text = currentZipCodeController.text;
      _permanentCountry.value = _currentCountry.value;
    }
    markDataChanged();
    notifyListeners();
  }

  // Country dropdowns
  final ReactiveValue<String?> _currentCountry = ReactiveValue<String?>(null);

  String? get currentCountry => _currentCountry.value;

  void updateCurrentCountry(String? value) {
    if (value != null) {
      _currentCountry.value = value;
      currentCountryController.text = value;
      markDataChanged();
      notifyListeners();

      // Update permanent country if same as current address is checked
      if (_sameAsCurrentAddress.value) {
        _permanentCountry.value = value;
        permanentCountryController.text = value;
      }
    }
  }

  final ReactiveValue<String?> _permanentCountry = ReactiveValue<String?>(null);

  String? get permanentCountry => _permanentCountry.value;

  void updatePermanentCountry(String? value) {
    if (value != null) {
      _permanentCountry.value = value;
      permanentCountryController.text = value;
      markDataChanged();
      notifyListeners();
    }
  }

  // Profile picture management
  String profilePictureUrl = '';
  File? _profilePictureFile;

  File? get profilePictureFile => _profilePictureFile;

  // Document storage - matches Employee model structure
  Map<String, List<File>> uploadedDocuments = {};
  List<String> resumeUrls = [];
  List<String> degreeCertificateUrls = [];
  List<String> experienceLetterUrls = [];
  List<String> localIdPassportUrls = [];

  // For file upload status
  final ReactiveValue<bool> _isUploading = ReactiveValue<bool>(false);

  bool get isUploading => _isUploading.value;

  final ReactiveValue<double> _uploadProgress = ReactiveValue<double>(0.0);

  double get uploadProgress => _uploadProgress.value;

  bool _isEditing = false;

  bool get isEditing => _isEditing;

  bool _didChange = false;

  bool get didChange => _didChange;

  bool _isHRApproved = false;

  bool get isHRApproved => _isHRApproved;

  Employee? _userProfile;

  void init(Employee? userProfile) async {
    setBusy(true);

    if (userProfile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final response = await _dialogService.showCustomDialog(
          variant: DialogType.loader,
          data: LoaderDialogAttributes(
            task: () => _userProfileService.getProfile(),
          ),
        );

        if (response?.data != null) {
          ((response?.data) as EitherResult<Employee>).fold(
                (exception) {
              Fluttertoast.showToast(msg: exception.toString());
            },
                (profile) {
              _userProfile = profile;
              _populateFormWithProfileData(profile);
              _isEditing = true;
            },
          );
        }
      });
    } else {
      _userProfile = userProfile;
      _populateFormWithProfileData(userProfile);
      _isEditing = true;
    }

    _addTextChangedListeners();
    setBusy(false);
  }

  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      AppLogger.error('Error parsing date: $dateString, error: $e');
      return null;
    }
  }

  Country? _findCountryByName(String? countryName) {
    if (countryName == null || countryName.isEmpty) return null;
    try {
      return countries.firstWhere(
            (country) =>
        country.name.toLowerCase() == countryName.toLowerCase(),
      );
    } catch (e) {
      AppLogger.info('Country not found: $countryName');
      return null;
    }
  }

  void _populateFormWithProfileData(Employee profile) {
    AppLogger.info('Populating form with profile data: ${profile.toJson()}');

    // Personal Details
    fullNameController.text = profile.fullName ?? profile.name ?? '';

    // Parse date of birth from string
    if (profile.dateOfBirth != null && profile.dateOfBirth!.isNotEmpty) {
      _dateOfBirth = _parseDate(profile.dateOfBirth);
      if (_dateOfBirth != null) {
        dateOfBirthController.text =
        "${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}";
      }
    }
    _selectedGender.value = profile.gender;
    _selectedBloodGroup.value = profile.bloodGroup;

    // Contact Info - Handle phone number from API data
    personalPhoneController.text = profile.personalPhone ?? profile.phone ?? '';
    whatsappController.text = profile.whatsappNumber ?? '';
    personalEmailController.text = profile.personalEmail ?? profile.email ?? '';

    // Current Address - using flat fields from Employee model
    currentAddressLine1Controller.text = profile.currentAddressLine1 ?? '';
    currentAddressLine2Controller.text = profile.currentAddressLine2 ?? '';
    currentCityController.text = profile.currentCity ?? '';
    currentStateController.text = profile.currentState ?? '';

    // Handle country selection
    String? currentCountryName = profile.currentCountry;
    if (currentCountryName != null && currentCountryName.isNotEmpty) {
      currentCountryController.text = currentCountryName;
      _currentCountry.value = currentCountryName;
      _selectedCountry = _findCountryByName(currentCountryName);
    }

    currentZipCodeController.text = profile.currentZipCode ?? '';

    // Permanent Address - using flat fields from Employee model
    permanentAddressLine1Controller.text = profile.permanentAddressLine1 ?? '';
    permanentAddressLine2Controller.text = profile.permanentAddressLine2 ?? '';
    permanentCityController.text = profile.permanentCity ?? '';
    permanentStateController.text = profile.permanentState ?? '';

    String? permanentCountryName = profile.permanentCountry;
    if (permanentCountryName != null && permanentCountryName.isNotEmpty) {
      permanentCountryController.text = permanentCountryName;
      _permanentCountry.value = permanentCountryName;
    }

    permanentZipCodeController.text = profile.permanentZipCode ?? '';

    // Check if addresses are the same
    _sameAsCurrentAddress.value = _checkIfAddressesAreSame(profile);

    // Emergency Contact - Handle emergency contact data from API
    emergencyContactNameController.text = profile.emergencyContactName ?? '';
    _emergencyRelationship.value = profile.emergencyRelationship;

    // Handle emergency phone from the API data structure
    String emergencyPhone = profile.emergencyPhone ?? '';
    if (emergencyPhone.isEmpty) {
      // Fallback to emergencyContact field if it exists in the JSON
      // This handles the case where the API returns "emergencyContact": "5678767897"
      final Map<String, dynamic> profileJson = profile.toJson();
      emergencyPhone = profileJson['emergencyContact']?.toString() ?? '';
    }
    emergencyPhoneController.text = emergencyPhone;

    // Identification
    nationalTaxIdController.text = profile.nationalTaxId ?? '';

    // Profile Picture
    profilePictureUrl = profile.profilePictureUrl ?? '';

    // Language - Handle from API data
    String language = profile.preferredLanguage ?? 'English';
    // The API returns "English" so we use it directly
    _preferredLanguage.value = language;

    // HR Approval status
    _isHRApproved = profile.isHRApproved ?? false;

    // Document URLs
    resumeUrls = profile.resumeUrls ?? [];
    degreeCertificateUrls = profile.degreeCertificateUrls ?? [];
    experienceLetterUrls = profile.experienceLetterUrls ?? [];
    localIdPassportUrls = profile.localIdPassportUrls ?? [];

    // Locked Fields (if HR approved)
    if (_isHRApproved) {
      panAadharController.text = profile.panAadharSsnNin ?? '';
      bankDetailsController.text = profile.bankDetails ?? '';
      workRegionController.text = profile.workRegion ?? '';
      reportingManagerController.text = profile.reportingManager ?? '';

      if (profile.joiningDate != null && profile.joiningDate!.isNotEmpty) {
        _joiningDate = _parseDate(profile.joiningDate);
        if (_joiningDate != null) {
          joiningDateController.text =
          "${_joiningDate!.day}/${_joiningDate!.month}/${_joiningDate!.year}";
        }
      }
    } else {
      // Handle hiring/employment dates from API data
      final Map<String, dynamic> profileJson = profile.toJson();

      // Handle hireDate from API
      String? hireDate = profileJson['hireDate']?.toString();
      if (hireDate != null && hireDate.isNotEmpty) {
        DateTime? parsedHireDate = _parseDate(hireDate);
        if (parsedHireDate != null) {
          _joiningDate = parsedHireDate;
          joiningDateController.text =
          "${parsedHireDate.day}/${parsedHireDate.month}/${parsedHireDate
              .year}";
        }
      }

      // Handle role from API data
      String role = profile.role ?? '';
      if (role.isNotEmpty) {
        reportingManagerController.text = role;
      }

      // Handle employee_Id from API data
      String employeeId = profileJson['employee_Id']?.toString() ?? '';
      panAadharController.text = employeeId;
    }

    // Reset change tracking after initial population
    _didChange = false;
    isDataChanged = false;
  }

  bool _checkIfAddressesAreSame(Employee profile) {
    return profile.currentAddressLine1 == profile.permanentAddressLine1 &&
        profile.currentAddressLine2 == profile.permanentAddressLine2 &&
        profile.currentCity == profile.permanentCity &&
        profile.currentState == profile.permanentState &&
        profile.currentCountry == profile.permanentCountry &&
        profile.currentZipCode == profile.permanentZipCode;
  }

  void _addTextChangedListeners() {
    // Personal Details
    fullNameController.addListener(() => markDataChanged());
    dateOfBirthController.addListener(() => markDataChanged());

    // Contact Info
    personalPhoneController.addListener(() => markDataChanged());
    whatsappController.addListener(() => markDataChanged());
    personalEmailController.addListener(() => markDataChanged());

    // Current Address
    currentAddressLine1Controller.addListener(() => markDataChanged());
    currentAddressLine2Controller.addListener(() => markDataChanged());
    currentCityController.addListener(() => markDataChanged());
    currentStateController.addListener(() => markDataChanged());
    currentCountryController.addListener(() => markDataChanged());
    currentZipCodeController.addListener(() => markDataChanged());

    // Permanent Address
    permanentAddressLine1Controller.addListener(() => markDataChanged());
    permanentAddressLine2Controller.addListener(() => markDataChanged());
    permanentCityController.addListener(() => markDataChanged());
    permanentStateController.addListener(() => markDataChanged());
    permanentCountryController.addListener(() => markDataChanged());
    permanentZipCodeController.addListener(() => markDataChanged());

    // Emergency Contact
    emergencyContactNameController.addListener(() => markDataChanged());
    emergencyPhoneController.addListener(() => markDataChanged());

    // Identification
    nationalTaxIdController.addListener(() => markDataChanged());
  }

  // Calculate profile completion percentage
  double calculateProfileCompletion() {
    int totalFields = 15; // Count of primary fields we're tracking
    int filledFields = 0;

    // Personal Details
    if (fullNameController.text.isNotEmpty) filledFields++;
    if (dateOfBirthController.text.isNotEmpty) filledFields++;
    if (_selectedGender.value != null) filledFields++;
    if (_selectedBloodGroup.value != null) filledFields++;

    // Contact Info
    if (personalPhoneController.text.isNotEmpty) filledFields++;
    if (personalEmailController.text.isNotEmpty) filledFields++;

    // Current Address
    if (currentAddressLine1Controller.text.isNotEmpty) filledFields++;
    if (currentCityController.text.isNotEmpty) filledFields++;
    if (currentStateController.text.isNotEmpty) filledFields++;
    if (_currentCountry.value != null) filledFields++;
    if (currentZipCodeController.text.isNotEmpty) filledFields++;

    // Emergency Contact
    if (emergencyContactNameController.text.isNotEmpty) filledFields++;
    if (_emergencyRelationship.value != null) filledFields++;
    if (emergencyPhoneController.text.isNotEmpty) filledFields++;

    // Profile Picture
    if (_profilePictureFile != null ||
        profilePictureUrl.isNotEmpty) filledFields++;

    return (filledFields / totalFields) * 100;
  }

  // Profile Picture handlers
  Future<void> onProfilePictureUpload() async {
    await showImagePickerOptions();
  }

  Future<void> showImagePickerOptions() async {
    final result = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.filePickerOptions,
      data: FilePickerOptionsSheetAttributes(),
      title: 'Upload Profile Picture',
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
        if (failure.message != 'No image selected') {
          Fluttertoast.showToast(
            msg: failure.message,
            backgroundColor: Colors.red,
          );
        }
      },
          (file) {
        _profilePictureFile = file;
        markDataChanged();
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
        if (failure.message != 'No photo taken') {
          Fluttertoast.showToast(
            msg: failure.message,
            backgroundColor: Colors.red,
          );
        }
      },
          (file) {
        _profilePictureFile = file;
        markDataChanged();
        notifyListeners();
      },
    );
  }

  Future<String?> _uploadProfilePicture() async {
    if (_profilePictureFile == null) return profilePictureUrl;

    _isUploading.value = true;
    _uploadProgress.value = 0.0;
    notifyListeners();

    final result = await _fileUploadService.uploadFileWithProgress(
        _profilePictureFile!, (progress) {
      _uploadProgress.value = progress;
      notifyListeners();
    });

    _isUploading.value = false;
    _uploadProgress.value = 1.0;
    notifyListeners();

    return result.fold((failure) {
      AppLogger.error('Failed to upload profile picture: ${failure.message}');
      Fluttertoast.showToast(
        msg: 'Failed to upload profile picture: ${failure.message}',
        backgroundColor: Colors.red,
      );
      return null;
    }, (url) => url);
  }

  void onProfilePictureRemove() {
    profilePictureUrl = '';
    _profilePictureFile = null;
    markDataChanged();
    notifyListeners();
  }

  // Document upload handler
  Future<void> uploadDocument(String documentType) async {
    final result = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.filePickerOptions,
      data: FilePickerOptionsSheetAttributes(),
      title: 'Upload $documentType',
      description: 'Choose file source',
      mainButtonTitle: 'Cancel',
    );

    if (result?.confirmed == true) {
      final option = result?.data;
      if (option == 'camera') {
        await captureDocumentPhoto(documentType);
      } else if (option == 'gallery') {
        await pickDocumentFromGallery(documentType);
      }
    }
  }

  Future<void> captureDocumentPhoto(String documentType) async {
    final pickerResult = await _filePickerService.takePhoto(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );

    pickerResult.fold(
          (failure) {
        if (failure.message != 'No photo taken') {
          Fluttertoast.showToast(
            msg: failure.message,
            backgroundColor: Colors.red,
          );
        }
      },
          (file) {
        if (uploadedDocuments[documentType] == null) {
          uploadedDocuments[documentType] = [];
        }
        uploadedDocuments[documentType]!.add(file);
        markDataChanged();
        notifyListeners();
        Fluttertoast.showToast(msg: '$documentType captured successfully');
      },
    );
  }

  Future<void> pickDocumentFromGallery(String documentType) async {
    final pickerResult = await _filePickerService.pickImageFromGallery(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );

    pickerResult.fold(
          (failure) {
        if (failure.message != 'No image selected') {
          Fluttertoast.showToast(
            msg: failure.message,
            backgroundColor: Colors.red,
          );
        }
      },
          (file) {
        if (uploadedDocuments[documentType] == null) {
          uploadedDocuments[documentType] = [];
        }
        uploadedDocuments[documentType]!.add(file);
        markDataChanged();
        notifyListeners();
        Fluttertoast.showToast(msg: '$documentType uploaded successfully');
      },
    );
  }

  Future<Map<String, List<String>>> _uploadDocuments() async {
    Map<String, List<String>> documentUrls = {};

    for (String documentType in uploadedDocuments.keys) {
      List<String> urls = [];
      for (File file in uploadedDocuments[documentType]!) {
        _isUploading.value = true;
        notifyListeners();

        final result = await _fileUploadService.uploadFileWithProgress(
            file, (progress) {
          _uploadProgress.value = progress;
          notifyListeners();
        });

        result.fold(
              (failure) {
            AppLogger.error(
                'Failed to upload $documentType: ${failure.message}');
            Fluttertoast.showToast(
              msg: 'Failed to upload $documentType',
              backgroundColor: Colors.red,
            );
          },
              (url) => urls.add(url),
        );
      }
      if (urls.isNotEmpty) {
        documentUrls[documentType] = urls;
      }
    }

    _isUploading.value = false;
    notifyListeners();
    return documentUrls;
  }

  // Save profile data
  Future<void> onSave() async {
    if (formKey.currentState?.validate() ?? true) {
      setBusy(true);

      try {
        // Upload profile picture if we have a new one
        String? uploadedProfilePictureUrl;
        if (_profilePictureFile != null) {
          uploadedProfilePictureUrl = await _uploadProfilePicture();
          if (uploadedProfilePictureUrl == null) {
            Fluttertoast.showToast(
              msg: "Profile picture upload failed, continuing with other changes",
              backgroundColor: Colors.orange,
            );
          }
        }

        // Upload documents and separate them according to Employee model structure
        Map<String, List<String>> documentUrls = await _uploadDocuments();

        // Separate document types according to Employee model
        List<String> newResumeUrls = [...resumeUrls];
        List<String> newDegreeCertificateUrls = [...degreeCertificateUrls];
        List<String> newExperienceLetterUrls = [...experienceLetterUrls];
        List<String> newLocalIdPassportUrls = [...localIdPassportUrls];

        // Add newly uploaded documents
        if (documentUrls.containsKey('Resume/CV')) {
          newResumeUrls.addAll(documentUrls['Resume/CV']!);
        }
        if (documentUrls.containsKey('Degree Certificates')) {
          newDegreeCertificateUrls.addAll(documentUrls['Degree Certificates']!);
        }
        if (documentUrls.containsKey('Experience Letters')) {
          newExperienceLetterUrls.addAll(documentUrls['Experience Letters']!);
        }
        if (documentUrls.containsKey('Local ID/Passport')) {
          newLocalIdPassportUrls.addAll(documentUrls['Local ID/Passport']!);
        }

        final profileData = {
          // Personal Details
          "fullName": fullNameController.text,
          "dateOfBirth": _dateOfBirth?.toIso8601String(),
          "gender": _selectedGender.value,
          "bloodGroup": _selectedBloodGroup.value,

          // Contact Info
          "personalPhone": personalPhoneController.text,
          "whatsappNumber": whatsappController.text,
          "personalEmail": personalEmailController.text,

          // Current Address - using flat structure to match Employee model
          "currentAddressLine1": currentAddressLine1Controller.text,
          "currentAddressLine2": currentAddressLine2Controller.text,
          "currentCity": currentCityController.text,
          "currentState": currentStateController.text,
          "currentCountry": _currentCountry.value,
          "currentZipCode": currentZipCodeController.text,

          // Permanent Address - using flat structure to match Employee model
          "permanentAddressLine1": sameAsCurrentAddress
              ? currentAddressLine1Controller.text
              : permanentAddressLine1Controller.text,
          "permanentAddressLine2": sameAsCurrentAddress
              ? currentAddressLine2Controller.text
              : permanentAddressLine2Controller.text,
          "permanentCity": sameAsCurrentAddress
              ? currentCityController.text
              : permanentCityController.text,
          "permanentState": sameAsCurrentAddress
              ? currentStateController.text
              : permanentStateController.text,
          "permanentCountry": sameAsCurrentAddress
              ? _currentCountry.value
              : _permanentCountry.value,
          "permanentZipCode": sameAsCurrentAddress
              ? currentZipCodeController.text
              : permanentZipCodeController.text,
          "sameAsCurrentAddress": sameAsCurrentAddress,

          // Emergency Contact
          "emergencyContactName": emergencyContactNameController.text,
          "emergencyRelationship": _emergencyRelationship.value,
          "emergencyPhone": emergencyPhoneController.text,

          // Identification
          "nationalTaxId": nationalTaxIdController.text,

          // Profile Picture
          "profilePictureUrl": uploadedProfilePictureUrl ?? profilePictureUrl,

          // Language
          "preferredLanguage": _preferredLanguage.value,

          // Documents - separated according to Employee model structure
          "resumeUrls": newResumeUrls,
          "degreeCertificateUrls": newDegreeCertificateUrls,
          "experienceLetterUrls": newExperienceLetterUrls,
          "localIdPassportUrls": newLocalIdPassportUrls,
          "documents": documentUrls, // Generic document storage

          // HR Approval status (read-only, won't be updated from client)
          "isHRApproved": _isHRApproved,
        };

        // Only include locked fields if not HR approved (they can't be changed after approval)
        if (!_isHRApproved) {
          profileData.addAll({
            "panAadharSsnNin": panAadharController.text,
            "bankDetails": bankDetailsController.text,
            "workRegion": workRegionController.text,
            "reportingManager": reportingManagerController.text,
            "joiningDate": _joiningDate?.toIso8601String(),
          });
        }

        final response = await _dialogService.showCustomDialog(
          variant: DialogType.loader,
          data: LoaderDialogAttributes(
            task: () => _userProfileService.updateEmployeeProfile(profileData),
          ),
        );

        if (response?.data != null) {
          ((response?.data) as EitherResult<bool>).fold(
                (exception) {
              Fluttertoast.showToast(msg: exception.toString());
            },
                (success) {
              Fluttertoast.showToast(
                msg: _isEditing
                    ? "Profile updated successfully!"
                    : "Profile created successfully!",
              );
              _navigationService.back(result: true);
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
    // Personal Details
    fullNameController.dispose();
    dateOfBirthController.dispose();

    // Contact Info
    personalPhoneController.dispose();
    whatsappController.dispose();
    personalEmailController.dispose();

    // Current Address
    currentAddressLine1Controller.dispose();
    currentAddressLine2Controller.dispose();
    currentCityController.dispose();
    currentStateController.dispose();
    currentCountryController.dispose();
    currentZipCodeController.dispose();

    // Permanent Address
    permanentAddressLine1Controller.dispose();
    permanentAddressLine2Controller.dispose();
    permanentCityController.dispose();
    permanentStateController.dispose();
    permanentCountryController.dispose();
    permanentZipCodeController.dispose();

    // Emergency Contact
    emergencyContactNameController.dispose();
    emergencyPhoneController.dispose();

    // Identification
    nationalTaxIdController.dispose();

    // Locked Fields
    panAadharController.dispose();
    bankDetailsController.dispose();
    workRegionController.dispose();
    reportingManagerController.dispose();
    joiningDateController.dispose();

    super.dispose();
  }

  String _fullPhoneNumber = '';

  String get fullPhoneNumber => _fullPhoneNumber;

  void updatePhoneNumber(PhoneNumber phoneNumber) {
    _fullPhoneNumber = '${phoneNumber.countryCode}${phoneNumber.number}';
    markDataChanged();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [];
}