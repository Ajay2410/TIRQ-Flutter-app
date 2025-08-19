import 'permissions.dart';

class Employee {
  // Existing fields
  final String? id;
  String? name;
  String? email;
  String? phone;
  String? employmentStatus;
  String? employeeType;
  String? role;
  String? shift;
  Permissions? permissions;
  MachineQualifications? machineQualifications;
  String? accountStatus;
  bool? isEmailVerified;
  bool? isPhoneVerified;
  dynamic phoneVerificationOTP;
  dynamic phoneVerificationOTPExpires;
  String? createdAt;
  String? updatedAt;
  int? v;
  String? organizationId;

  // Personal Details
  String? fullName; // Use this instead of name for complete name
  String? dateOfBirth;
  String? gender;
  String? bloodGroup;

  // Contact Info
  String? personalPhone; // Different from work phone
  String? whatsappNumber;
  String? personalEmail; // Different from work email

  // Current Address
  String? currentAddressLine1;
  String? currentAddressLine2;
  String? currentCity;
  String? currentState;
  String? currentCountry;
  String? country;
  String? currentZipCode;

  // Permanent Address
  String? permanentAddressLine1;
  String? permanentAddressLine2;
  String? permanentCity;
  String? permanentState;
  String? permanentCountry;
  String? permanentZipCode;
  bool? sameAsCurrentAddress;

  // Emergency Contact
  String? emergencyContactName;
  String? emergencyRelationship;
  String? emergencyPhone;

  // Identification
  String? nationalTaxId;
  String? localIdPassportUrl; // URL to uploaded document
  List<String>? localIdPassportUrls; // Multiple documents

  // Profile Picture
  String? profilePictureUrl;

  // Resume/Documents
  List<String>? resumeUrls;
  List<String>? degreeCertificateUrls;
  List<String>? experienceLetterUrls;
  Map<String, List<String>>? documents; // Generic document storage

  // Language Preference
  String? preferredLanguage;

  // HR Approval and Locked Fields
  bool? isHRApproved;
  String? panAadharSsnNin;
  String? bankDetails;
  String? workRegion;
  String? reportingManager;
  String? joiningDate;

  // Additional Professional Info
  String? designation;
  String? department;
  String? employeeId;
  String? workLocation;
  String? salary;
  String? workEmail; // Separate work email
  String? workPhone; // Separate work phone
  String? supervisorId;
  String? teamId;

  // Onboarding Status
  bool? profileCompleted;
  double? profileCompletionPercentage;
  bool? documentsVerified;
  bool? backgroundCheckCompleted;
  String? onboardingStatus; // 'pending', 'in_progress', 'completed'

  // Additional Metadata
  String? lastLoginAt;
  String? profileUpdatedAt;
  bool? isActive;
  String? terminationDate;
  String? terminationReason;

  Employee({
    // Existing fields
    this.id,
    this.name,
    this.email,
    this.phone,
    this.employmentStatus,
    this.employeeType,
    this.role,
    this.shift,
    this.permissions,
    this.machineQualifications,
    this.accountStatus,
    this.isEmailVerified,
    this.isPhoneVerified,
    this.phoneVerificationOTP,
    this.phoneVerificationOTPExpires,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.organizationId,

    // Personal Details
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,

    // Contact Info
    this.personalPhone,
    this.whatsappNumber,
    this.personalEmail,

    // Current Address
    this.currentAddressLine1,
    this.currentAddressLine2,
    this.currentCity,
    this.currentState,
    this.currentCountry,
    this.currentZipCode,
    this.country,

    // Permanent Address
    this.permanentAddressLine1,
    this.permanentAddressLine2,
    this.permanentCity,
    this.permanentState,
    this.permanentCountry,
    this.permanentZipCode,
    this.sameAsCurrentAddress,

    // Emergency Contact
    this.emergencyContactName,
    this.emergencyRelationship,
    this.emergencyPhone,

    // Identification
    this.nationalTaxId,
    this.localIdPassportUrl,
    this.localIdPassportUrls,

    // Profile Picture
    this.profilePictureUrl,

    // Documents
    this.resumeUrls,
    this.degreeCertificateUrls,
    this.experienceLetterUrls,
    this.documents,

    // Language
    this.preferredLanguage,

    // HR Approval
    this.isHRApproved,
    this.panAadharSsnNin,
    this.bankDetails,
    this.workRegion,
    this.reportingManager,
    this.joiningDate,

    // Professional Info
    this.designation,
    this.department,
    this.employeeId,
    this.workLocation,
    this.salary,
    this.workEmail,
    this.workPhone,
    this.supervisorId,
    this.teamId,

    // Onboarding
    this.profileCompleted,
    this.profileCompletionPercentage,
    this.documentsVerified,
    this.backgroundCheckCompleted,
    this.onboardingStatus,

    // Metadata
    this.lastLoginAt,
    this.profileUpdatedAt,
    this.isActive,
    this.terminationDate,
    this.terminationReason,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      // Existing fields
      id: json['_id'],
      name: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      employmentStatus: json['employmentStatus'],
      employeeType: json['employeeType'],
      role: json['role'],
      shift: json['shift'],
      permissions: json['permissions'] != null
          ? Permissions.fromJson(json['permissions'])
          : null,
      machineQualifications: json['machineQualifications'] != null
          ? MachineQualifications.fromJson(json['machineQualifications'])
          : null,
      accountStatus: json['accountStatus'],
      isEmailVerified: json['isEmailVerified'],
      isPhoneVerified: json['isPhoneVerified'],
      phoneVerificationOTP: json['phoneVerificationOTP'],
      phoneVerificationOTPExpires: json['phoneVerificationOTPExpires'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
      organizationId: json['organizationId'],

      // Personal Details
      fullName: json['fullName'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      bloodGroup: json['bloodGroup'],

      // Contact Info
      personalPhone: json['personalPhone'],
      whatsappNumber: json['whatsappNumber'],
      personalEmail: json['personalEmail'],

      // Current Address
      currentAddressLine1: json['currentAddressLine1'],
      currentAddressLine2: json['currentAddressLine2'],
      currentCity: json['currentCity'],
      currentState: json['currentState'],
      currentCountry: json['currentCountry'],
      country: json['country'],
      currentZipCode: json['currentZipCode'],

      // Permanent Address
      permanentAddressLine1: json['permanentAddressLine1'],
      permanentAddressLine2: json['permanentAddressLine2'],
      permanentCity: json['permanentCity'],
      permanentState: json['permanentState'],
      permanentCountry: json['permanentCountry'],
      permanentZipCode: json['permanentZipCode'],
      sameAsCurrentAddress: json['sameAsCurrentAddress'],

      // Emergency Contact
      emergencyContactName: json['emergencyContactName'],
      emergencyRelationship: json['emergencyRelationship'],
      emergencyPhone: json['emergencyPhone'],

      // Identification
      nationalTaxId: json['nationalTaxId'],
      localIdPassportUrl: json['localIdPassportUrl'],
      localIdPassportUrls: json['localIdPassportUrls'] != null
          ? List<String>.from(json['localIdPassportUrls'])
          : null,

      // Profile Picture
      profilePictureUrl: json['profilePictureUrl'],

      // Documents
      resumeUrls: json['resumeUrls'] != null
          ? List<String>.from(json['resumeUrls'])
          : null,
      degreeCertificateUrls: json['degreeCertificateUrls'] != null
          ? List<String>.from(json['degreeCertificateUrls'])
          : null,
      experienceLetterUrls: json['experienceLetterUrls'] != null
          ? List<String>.from(json['experienceLetterUrls'])
          : null,
      documents: json['documents'] != null
          ? Map<String, List<String>>.from(
          json['documents'].map((key, value) =>
              MapEntry(key, List<String>.from(value))))
          : null,

      // Language
      preferredLanguage: json['preferredLanguage'],

      // HR Approval
      isHRApproved: json['isHRApproved'],
      panAadharSsnNin: json['panAadharSsnNin'],
      bankDetails: json['bankDetails'],
      workRegion: json['workRegion'],
      reportingManager: json['reportingManager'],
      joiningDate: json['joiningDate'],

      // Professional Info
      designation: json['designation'],
      department: json['department'],
      employeeId: json['employeeId'],
      workLocation: json['workLocation'],
      salary: json['salary'],
      workEmail: json['workEmail'],
      workPhone: json['workPhone'],
      supervisorId: json['supervisorId'],
      teamId: json['teamId'],

      // Onboarding
      profileCompleted: json['profileCompleted'],
      profileCompletionPercentage: json['profileCompletionPercentage']?.toDouble(),
      documentsVerified: json['documentsVerified'],
      backgroundCheckCompleted: json['backgroundCheckCompleted'],
      onboardingStatus: json['onboardingStatus'],

      // Metadata
      lastLoginAt: json['lastLoginAt'],
      profileUpdatedAt: json['profileUpdatedAt'],
      isActive: json['isActive'],
      terminationDate: json['terminationDate'],
      terminationReason: json['terminationReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Existing fields
      '_id': id,
      'name': fullName, // Keep original name field
      'email': email,
      'phone': phone,
      'employmentStatus': employmentStatus,
      'employeeType': employeeType,
      'role': role,
      'shift': shift,
      'permissions': permissions?.toJson(),
      'machineQualifications': machineQualifications?.toJson(),
      'accountStatus': accountStatus,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'phoneVerificationOTP': phoneVerificationOTP,
      'phoneVerificationOTPExpires': phoneVerificationOTPExpires,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'organizationId': organizationId,

      // Personal Details
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'bloodGroup': bloodGroup,

      // Contact Info
      'personalPhone': personalPhone,
      'whatsappNumber': whatsappNumber,
      'personalEmail': personalEmail,

      // Current Address
      'currentAddressLine1': currentAddressLine1,
      'currentAddressLine2': currentAddressLine2,
      'currentCity': currentCity,
      'currentState': currentState,
      'currentCountry': currentCountry,
      'country': country,
      'currentZipCode': currentZipCode,

      // Permanent Address
      'permanentAddressLine1': permanentAddressLine1,
      'permanentAddressLine2': permanentAddressLine2,
      'permanentCity': permanentCity,
      'permanentState': permanentState,
      'permanentCountry': permanentCountry,
      'permanentZipCode': permanentZipCode,
      'sameAsCurrentAddress': sameAsCurrentAddress,

      // Emergency Contact
      'emergencyContactName': emergencyContactName,
      'emergencyRelationship': emergencyRelationship,
      'emergencyPhone': emergencyPhone,

      // Identification
      'nationalTaxId': nationalTaxId,
      'localIdPassportUrl': localIdPassportUrl,
      'localIdPassportUrls': localIdPassportUrls,

      // Profile Picture
      'profilePictureUrl': profilePictureUrl,

      // Documents
      'resumeUrls': resumeUrls,
      'degreeCertificateUrls': degreeCertificateUrls,
      'experienceLetterUrls': experienceLetterUrls,
      'documents': documents,

      // Language
      'preferredLanguage': preferredLanguage,

      // HR Approval
      'isHRApproved': isHRApproved,
      'panAadharSsnNin': panAadharSsnNin,
      'bankDetails': bankDetails,
      'workRegion': workRegion,
      'reportingManager': reportingManager,
      'joiningDate': joiningDate,

      // Professional Info
      'designation': designation,
      'department': department,
      'employeeId': employeeId,
      'workLocation': workLocation,
      'salary': salary,
      'workEmail': workEmail,
      'workPhone': workPhone,
      'supervisorId': supervisorId,
      'teamId': teamId,

      // Onboarding
      'profileCompleted': profileCompleted,
      'profileCompletionPercentage': profileCompletionPercentage,
      'documentsVerified': documentsVerified,
      'backgroundCheckCompleted': backgroundCheckCompleted,
      'onboardingStatus': onboardingStatus,

      // Metadata
      'lastLoginAt': lastLoginAt,
      'profileUpdatedAt': profileUpdatedAt,
      'isActive': isActive,
      'terminationDate': terminationDate,
      'terminationReason': terminationReason,
    };
  }

  // Helper method to get display name (fullName if available, otherwise name)
  String get displayName => fullName?.isNotEmpty == true ? fullName! : (name ?? '');

  // Helper method to get primary email (work email if available, otherwise personal email)
  String get primaryEmail => email?.isNotEmpty == true ? email! : (personalEmail ?? '');

  // Helper method to get primary phone (work phone if available, otherwise personal phone)
  String get primaryPhone => phone?.isNotEmpty == true ? phone! : (personalPhone ?? '');

  // Helper method to check if profile is complete
  bool get isProfileComplete => profileCompleted ?? false;


  // Helper method to calculate profile completion
  double calculateProfileCompletion() {
    if (profileCompletionPercentage != null) {
      return profileCompletionPercentage!;
    }

    int totalFields = 15;
    int filledFields = 0;

    // Personal Details
    if (fullName?.isNotEmpty == true) filledFields++;
    if (dateOfBirth?.isNotEmpty == true) filledFields++;
    if (gender?.isNotEmpty == true) filledFields++;
    if (bloodGroup?.isNotEmpty == true) filledFields++;

    // Contact Info
    if (personalPhone?.isNotEmpty == true || phone?.isNotEmpty == true) filledFields++;
    if (personalEmail?.isNotEmpty == true || email?.isNotEmpty == true) filledFields++;

    // Current Address
    if (currentAddressLine1?.isNotEmpty == true) filledFields++;
    if (currentCity?.isNotEmpty == true) filledFields++;
    if (currentState?.isNotEmpty == true) filledFields++;
    if (currentCountry?.isNotEmpty == true) filledFields++;
    if (country?.isNotEmpty == true) filledFields++;
    if (currentZipCode?.isNotEmpty == true) filledFields++;

    // Emergency Contact
    if (emergencyContactName?.isNotEmpty == true) filledFields++;
    if (emergencyRelationship?.isNotEmpty == true) filledFields++;
    if (emergencyPhone?.isNotEmpty == true) filledFields++;

    // Profile Picture
    if (profilePictureUrl?.isNotEmpty == true) filledFields++;

    return (filledFields / totalFields) * 100;
  }

  @override
  String toString() {
    return toJson().toString();
  }

  // Copy with method for creating modified copies
  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? employmentStatus,
    String? employeeType,
    String? role,
    String? shift,
    Permissions? permissions,
    MachineQualifications? machineQualifications,
    String? accountStatus,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    dynamic phoneVerificationOTP,
    dynamic phoneVerificationOTPExpires,
    String? createdAt,
    String? updatedAt,
    int? v,
    String? organizationId,
    String? fullName,
    String? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? personalPhone,
    String? whatsappNumber,
    String? personalEmail,
    String? currentAddressLine1,
    String? currentAddressLine2,
    String? currentCity,
    String? currentState,
    String? currentCountry,
    String? country,
    String? currentZipCode,
    String? permanentAddressLine1,
    String? permanentAddressLine2,
    String? permanentCity,
    String? permanentState,
    String? permanentCountry,
    String? permanentZipCode,
    bool? sameAsCurrentAddress,
    String? emergencyContactName,
    String? emergencyRelationship,
    String? emergencyPhone,
    String? nationalTaxId,
    String? localIdPassportUrl,
    List<String>? localIdPassportUrls,
    String? profilePictureUrl,
    List<String>? resumeUrls,
    List<String>? degreeCertificateUrls,
    List<String>? experienceLetterUrls,
    Map<String, List<String>>? documents,
    String? preferredLanguage,
    bool? isHRApproved,
    String? panAadharSsnNin,
    String? bankDetails,
    String? workRegion,
    String? reportingManager,
    String? joiningDate,
    String? designation,
    String? department,
    String? employeeId,
    String? workLocation,
    String? salary,
    String? workEmail,
    String? workPhone,
    String? supervisorId,
    String? teamId,
    bool? profileCompleted,
    double? profileCompletionPercentage,
    bool? documentsVerified,
    bool? backgroundCheckCompleted,
    String? onboardingStatus,
    String? lastLoginAt,
    String? profileUpdatedAt,
    bool? isActive,
    String? terminationDate,
    String? terminationReason,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      employeeType: employeeType ?? this.employeeType,
      role: role ?? this.role,
      shift: shift ?? this.shift,
      permissions: permissions ?? this.permissions,
      machineQualifications: machineQualifications ?? this.machineQualifications,
      accountStatus: accountStatus ?? this.accountStatus,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      phoneVerificationOTP: phoneVerificationOTP ?? this.phoneVerificationOTP,
      phoneVerificationOTPExpires: phoneVerificationOTPExpires ?? this.phoneVerificationOTPExpires,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
      organizationId: organizationId ?? this.organizationId,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      personalPhone: personalPhone ?? this.personalPhone,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      personalEmail: personalEmail ?? this.personalEmail,
      currentAddressLine1: currentAddressLine1 ?? this.currentAddressLine1,
      currentAddressLine2: currentAddressLine2 ?? this.currentAddressLine2,
      currentCity: currentCity ?? this.currentCity,
      currentState: currentState ?? this.currentState,
      currentCountry: currentCountry ?? this.currentCountry,
      country: country ?? this.country,
      currentZipCode: currentZipCode ?? this.currentZipCode,
      permanentAddressLine1: permanentAddressLine1 ?? this.permanentAddressLine1,
      permanentAddressLine2: permanentAddressLine2 ?? this.permanentAddressLine2,
      permanentCity: permanentCity ?? this.permanentCity,
      permanentState: permanentState ?? this.permanentState,
      permanentCountry: permanentCountry ?? this.permanentCountry,
      permanentZipCode: permanentZipCode ?? this.permanentZipCode,
      sameAsCurrentAddress: sameAsCurrentAddress ?? this.sameAsCurrentAddress,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyRelationship: emergencyRelationship ?? this.emergencyRelationship,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      nationalTaxId: nationalTaxId ?? this.nationalTaxId,
      localIdPassportUrl: localIdPassportUrl ?? this.localIdPassportUrl,
      localIdPassportUrls: localIdPassportUrls ?? this.localIdPassportUrls,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      resumeUrls: resumeUrls ?? this.resumeUrls,
      degreeCertificateUrls: degreeCertificateUrls ?? this.degreeCertificateUrls,
      experienceLetterUrls: experienceLetterUrls ?? this.experienceLetterUrls,
      documents: documents ?? this.documents,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      isHRApproved: isHRApproved ?? this.isHRApproved,
      panAadharSsnNin: panAadharSsnNin ?? this.panAadharSsnNin,
      bankDetails: bankDetails ?? this.bankDetails,
      workRegion: workRegion ?? this.workRegion,
      reportingManager: reportingManager ?? this.reportingManager,
      joiningDate: joiningDate ?? this.joiningDate,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      employeeId: employeeId ?? this.employeeId,
      workLocation: workLocation ?? this.workLocation,
      salary: salary ?? this.salary,
      workEmail: workEmail ?? this.workEmail,
      workPhone: workPhone ?? this.workPhone,
      supervisorId: supervisorId ?? this.supervisorId,
      teamId: teamId ?? this.teamId,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      profileCompletionPercentage: profileCompletionPercentage ?? this.profileCompletionPercentage,
      documentsVerified: documentsVerified ?? this.documentsVerified,
      backgroundCheckCompleted: backgroundCheckCompleted ?? this.backgroundCheckCompleted,
      onboardingStatus: onboardingStatus ?? this.onboardingStatus,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      profileUpdatedAt: profileUpdatedAt ?? this.profileUpdatedAt,
      isActive: isActive ?? this.isActive,
      terminationDate: terminationDate ?? this.terminationDate,
      terminationReason: terminationReason ?? this.terminationReason,
    );
  }
}

// MachineQualifications class (if not already defined)
// class MachineQualifications {
//   // Add your machine qualifications fields here
//   Map<String, dynamic> toJson() => {};
//   factory MachineQualifications.fromJson(Map<String, dynamic> json) => MachineQualifications();
// }