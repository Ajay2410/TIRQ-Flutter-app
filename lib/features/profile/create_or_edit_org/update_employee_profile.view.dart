import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:manager/core/models/employee.dart';
import 'package:stacked/stacked.dart';

import '../../../resources/app_resources/app_maps.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../services/language.service.dart';
import 'update_employee_profile.vm.dart';

class EmployeeProfileViewAttributes {
  final Employee? employee;
  EmployeeProfileViewAttributes({this.employee});
}

class EmployeeProfileView extends StatelessWidget {
  const EmployeeProfileView({super.key, required this.attributes});
  final EmployeeProfileViewAttributes attributes;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EmployeeProfileViewModel>.reactive(
      viewModelBuilder: () => EmployeeProfileViewModel(),
      onViewModelReady: (EmployeeProfileViewModel model) =>
          model.init(attributes.employee),
      disposeViewModel: false,
      builder: (
          BuildContext context,
          EmployeeProfileViewModel model,
          Widget? child,
          ) {
        return WillPopScope(
          onWillPop: () async {
            if (!model.isDataChanged) return true;
            final shouldLeave = await _showExitConfirmationDialog(context);
            return shouldLeave;
          },
          child: Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: AppColors.white),
              backgroundColor: AppColors.primary,
              title: Text(
                model.isEditing ? LanguageService.get("update_profile") : LanguageService.get("create_profile"),
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(color: AppColors.white),
              ),
            ),
            body: model.isBusy
                ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
                : Form(
              key: model.formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.w30,
                  vertical: AppSizes.h20,
                ),
                children: [
                  // Profile Picture Upload Section
                  _buildProfilePictureSection(context, model),

                  // Personal Details Section
                  _buildSectionTitle(context, LanguageService.get("personal_details")),
                  SizedBox(height: AppSizes.h10),
                  _buildTextField(
                    context,
                    controller: model.fullNameController,
                    label: LanguageService.get("full_name"),
                    onChanged: (_) => model.markDataChanged(),
                  ),
                  _buildDateField(context, model),
                  _buildGenderField(context, model),
                  _buildBloodGroupField(context, model),

                  SizedBox(height: AppSizes.h30),

                  // Contact Info Section
                  _buildSectionTitle(context, LanguageService.get("contact_info")),
                  SizedBox(height: AppSizes.h10),
                  _buildPhoneField(
                    context,
                    model,
                    controller: model.personalPhoneController,
                    label: LanguageService.get("personal_phone_no"),
                    onChanged: (_) => model.markDataChanged(),
                  ),
                  _buildPhoneField(
                    context,
                    model,
                    controller: model.whatsappController,
                    label: LanguageService.get("whatsapp_no"),
                    onChanged: (_) => model.markDataChanged(),
                  ),
                  _buildTextField(
                    context,
                    controller: model.personalEmailController,
                    label: LanguageService.get("personal_email"),
                    onChanged: (_) => model.markDataChanged(),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  SizedBox(height: AppSizes.h30),

                  // Address Section
                  _buildSectionTitle(context,  LanguageService.get("address")),
                  SizedBox(height: AppSizes.h10),
                  _buildTextField(
                    context,
                    controller: model.currentAddressLine1Controller,
                      label: LanguageService.get("current_address_line_1"),
                    onChanged: (_) => model.markDataChanged(),
                  ),
                  _buildTextField(
                    context,
                    controller: model.currentAddressLine2Controller,
                    label: LanguageService.get("current_address_line_2"),
                    onChanged: (_) => model.markDataChanged(),
                  ),
                  _buildTextField(
                    context,
                    controller: model.currentCityController,
                    label: LanguageService.get("current_city"),
                    onChanged: (_) => model.markDataChanged(),
                  ),
                  _buildTextField(
                    context,
                    controller: model.currentStateController,
                    label: LanguageService.get("current_state"),
                    onChanged: (_) => model.markDataChanged(),
                  ),
                  _buildCountryDropdown(context, model),
                  SizedBox(height: AppSizes.h20),
                  _buildTextField(
                    context,
                    controller: model.currentZipCodeController,
                    label: LanguageService.get("current_zip_code"),
                    onChanged: (_) => model.markDataChanged(),
                    keyboardType: TextInputType.text,
                  ),

                  SizedBox(height: AppSizes.h20),

                  // Permanent Address Section
                  _buildPermanentAddressSection(context, model),

                  SizedBox(height: AppSizes.h30),

                  // Emergency Contact Section
                  _buildSectionTitle(context, LanguageService.get("emergency_contact")),
                  SizedBox(height: AppSizes.h10),
                  _buildTextField(
                    context,
                    controller: model.emergencyContactNameController,
                    label: LanguageService.get("emergency_contact_name"),
                    onChanged: (_) => model.markDataChanged(),
                  ),
                  _buildRelationshipField(context, model),
                  _buildPhoneField(
                    context,
                    model,
                    controller: model.emergencyPhoneController,
                    label: LanguageService.get("emergency_phone_no"),
                    onChanged: (_) => model.markDataChanged(),
                  ),

                  SizedBox(height: AppSizes.h30),

                  // Identification Section
                  _buildSectionTitle(context, LanguageService.get("identification")),
                  SizedBox(height: AppSizes.h10),
                  _buildDocumentUploadSection(context, model, LanguageService.get("local_id_passport")),
                  _buildTextField(
                    context,
                    controller: model.nationalTaxIdController,
                    label: LanguageService.get("national_tax_id"),
                    onChanged: (_) => model.markDataChanged(),
                  ),

                  SizedBox(height: AppSizes.h30),

                  // Documents Section
                  _buildSectionTitle(context, LanguageService.get("resume_documents") ),
                  SizedBox(height: AppSizes.h10),
                  _buildDocumentUploadSection(context, model, LanguageService.get("resume_cv")),
                  _buildDocumentUploadSection(context, model, LanguageService.get("degree_certificates")),
                  _buildDocumentUploadSection(context, model, LanguageService.get("experience_letters"),),

                  SizedBox(height: AppSizes.h30),

                  // Language Preference Section
                  _buildSectionTitle(context, LanguageService.get("language_preference")),
                  SizedBox(height: AppSizes.h10),
                  _buildLanguageField(context, model),

                  SizedBox(height: AppSizes.h30),

                  // Locked Fields Section (if HR approved)
                  if (model.isHRApproved) _buildLockedFieldsSection(context, model),

                  SizedBox(height: AppSizes.h40),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: model.onSave,
                          style: Theme.of(context)
                              .elevatedButtonTheme
                              .style
                              ?.copyWith(
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.v12,
                                ),
                              ),
                            ),
                          ),
                          child: Text(
                            model.isEditing ? LanguageService.get("update_profile") : LanguageService.get("create_profile"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentUploadSection(
      BuildContext context,
      EmployeeProfileViewModel model,
      String documentType,
      ) {
    // Get existing document URLs for this type
    List<String> existingUrls = [];
    switch (documentType) {
      case "Resume/CV":
        existingUrls = model.resumeUrls;
        break;
      case "Degree Certificates":
        existingUrls = model.degreeCertificateUrls;
        break;
      case "Experience Letters":
        existingUrls = model.experienceLetterUrls;
        break;
      case "Local ID/Passport":
        existingUrls = model.localIdPassportUrls;
        break;
    }

    // Get newly uploaded files for this type
    List<File> newFiles = model.uploadedDocuments[documentType] ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h16),
      padding: EdgeInsets.all(AppSizes.w16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGray),
        borderRadius: BorderRadius.circular(AppSizes.v12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            documentType,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppSizes.h8),

          // Show existing documents
          if (existingUrls.isNotEmpty) ...[
            Text(
              LanguageService.get("existing_documents"),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.gray,
              ),
            ),
            SizedBox(height: AppSizes.h4),
            ...existingUrls.asMap().entries.map((entry) {
              return Container(
                margin: EdgeInsets.only(bottom: AppSizes.h4),
                padding: EdgeInsets.all(AppSizes.w8),
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppSizes.v8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.description, size: 16, color: AppColors.primary),
                    SizedBox(width: AppSizes.w8),
                    Expanded(
                      child: Text(
                        "${entry.key + 1}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: AppSizes.h8),
          ],

          // Show newly uploaded files
          if (newFiles.isNotEmpty) ...[
            Text(
              LanguageService.get("new_documents"),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppSizes.h4),
            ...newFiles.asMap().entries.map((entry) {
              return Container(
                margin: EdgeInsets.only(bottom: AppSizes.h4),
                padding: EdgeInsets.all(AppSizes.w8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.v8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_file, size: 16, color: AppColors.primary),
                    SizedBox(width: AppSizes.w8),
                    Expanded(
                      child: Text(
                        entry.value.path.split('/').last,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.pending, size: 16, color: Colors.orange),
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: AppSizes.h8),
          ],

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => model.uploadDocument(documentType),
                  icon: Icon(Icons.upload_file),
                  label: Text(
                    LanguageService.get("upload"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection(
      BuildContext context,
      EmployeeProfileViewModel model,
      ) {
    final completionPercentage = model.calculateProfileCompletion();

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h16),
      padding: EdgeInsets.all(AppSizes.w16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: model.onProfilePictureUpload,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: AppSizes.h130,
                  width: AppSizes.h130,
                  child: CircularProgressIndicator(
                    value: completionPercentage / 100,
                    backgroundColor: AppColors.lightGray,
                    color: AppColors.primary,
                    strokeWidth: 4,
                  ),
                ),
                ClipOval(
                  child: Container(
                    height: AppSizes.h120,
                    width: AppSizes.h120,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.v14),
                      border: Border.all(color: AppColors.white, width: 3),
                      image: model.profilePictureFile != null
                          ? DecorationImage(
                        image: FileImage(model.profilePictureFile!),
                        fit: BoxFit.cover,
                      )
                          : model.profilePictureUrl.isNotEmpty
                          ? DecorationImage(
                        image: NetworkImage(model.profilePictureUrl),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: model.profilePictureFile == null &&
                        model.profilePictureUrl.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: AppSizes.v36,
                            color: AppColors.gray,
                          ),
                          SizedBox(height: AppSizes.h4),
                          Text(
                            LanguageService.get("add_photo"),
                            style: TextStyle(
                              fontSize: AppSizes.v12,
                              color: AppColors.gray,
                            ),
                          ),
                        ],
                      ),
                    )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary),
            ),
            child: Text(
              "${completionPercentage.toStringAsFixed(0)}%",
              style: TextStyle(
                fontSize: AppSizes.v12,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (model.profilePictureFile != null || model.profilePictureUrl.isNotEmpty) ...[
            TextButton(
              onPressed: model.isUploading ? null : model.onProfilePictureRemove,
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(
                LanguageService.get("remove_photo"),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(top: AppSizes.h4),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildTextField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        TextInputType? keyboardType,
        TextInputAction textInputAction = TextInputAction.next,
        String? Function(String?)? validator,
        int maxLines = 1,
        bool readOnly = false,
        void Function(String)? onChanged,
      }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.v14),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: AppSizes.w4),
        ),
      ),
      child: TextFormField(
        controller: controller,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onChanged: onChanged,
        decoration: InputDecoration(
          label: Text(label),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.w16,
            vertical: AppSizes.h16,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPhoneField(
      BuildContext context,
      EmployeeProfileViewModel model, {
        required TextEditingController controller,
        required String label,
        void Function(String)? onChanged,
        bool isRequired = false,
        bool readOnly = false,
      }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.v14),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: AppSizes.w4),
        ),
      ),
      child: IntlPhoneField(
        readOnly: readOnly,
        controller: controller,
        pickerDialogStyle: PickerDialogStyle(
          backgroundColor: AppColors.white,
          countryCodeStyle: TextStyle(color: AppColors.black),
          countryNameStyle: TextStyle(color: AppColors.black),
        ),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v12),
            borderSide: BorderSide(color: AppColors.lightGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v12),
            borderSide: BorderSide(color: AppColors.lightGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        initialCountryCode: 'IN',
        onChanged: (phone) {
          model.updatePhoneNumber(phone);
          if (onChanged != null) onChanged(phone.completeNumber);
        },
        validator: isRequired
            ? (phone) {
          if (phone == null || phone.number.isEmpty) {
            return LanguageService.get("please_enter_phone_number");
          }
          return null;
        }
            : null,
      ),
    );
  }

  Widget _buildDateField(BuildContext context, EmployeeProfileViewModel model) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.v14),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: AppSizes.w4),
        ),
      ),
      child: TextFormField(
        controller: model.dateOfBirthController,
        readOnly: true,
        onTap: () => model.selectDateOfBirth(context),
        decoration: InputDecoration(
          label: Text(
            LanguageService.get("date_of_birth"),
          ),
          suffixIcon: Icon(Icons.calendar_today),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.w16,
            vertical: AppSizes.h16,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderField(BuildContext context, EmployeeProfileViewModel model) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.v14),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: AppSizes.w4),
        ),
      ),


      // make it language Dropdown
      child: DropdownButtonFormField<String>(
        value: model.selectedGender,
        decoration: InputDecoration(
          labelText: LanguageService.get("gender"),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.w16,
            vertical: AppSizes.h16,
          ),
        ),
        dropdownColor: AppColors.white,
        items: ['Male', 'Female', 'Other', 'Prefer not to say']
            .map((gender) => DropdownMenuItem(value: gender, child: Text(
          LanguageService.get(gender),
        )))
            .toList(),
        onChanged: (value) => model.updateGender(value),
      ),
    );
  }

  Widget _buildBloodGroupField(BuildContext context, EmployeeProfileViewModel model) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.v14),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: AppSizes.w4),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: model.selectedBloodGroup,
        decoration: InputDecoration(
          labelText: LanguageService.get("blood_group"),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.w16,
            vertical: AppSizes.h16,
          ),
        ),
        dropdownColor: AppColors.white,
        items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
            .map((blood) => DropdownMenuItem(value: blood, child: Text(blood)))
            .toList(),
        onChanged: (value) => model.updateBloodGroup(value),
      ),
    );
  }

  Widget _buildRelationshipField(BuildContext context, EmployeeProfileViewModel model) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.v14),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: AppSizes.w4),
        ),
      ),
      //also make it language dropwon
      child: DropdownButtonFormField<String>(
        value: model.emergencyRelationship,
        decoration: InputDecoration(
          labelText: LanguageService.get("emergency_relationship"),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.w16,
            vertical: AppSizes.h16,
          ),
        ),
        dropdownColor: AppColors.white,
        items: ['Father', 'Mother', 'Spouse', 'Sibling', 'Friend', 'Other']
            .map((rel) => DropdownMenuItem(value: rel, child: Text(
          LanguageService.get(rel),
        )))
            .toList(),
        onChanged: (value) => model.updateEmergencyRelationship(value),
      ),
    );
  }

  Widget _buildCountryDropdown(
      BuildContext context,
      EmployeeProfileViewModel model,
      ) {
    return GestureDetector(
      onTap: () => _showSearchableCountryDropdown(context, model),
      child: AbsorbPointer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.v12),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: TextFormField(
            controller: TextEditingController(
              text:
              model.selectedCountry != null
                  ? '${model.selectedCountry!.flag} ${model.selectedCountry!.name}'
                  : '',
            ),
            decoration: InputDecoration(
              labelText: LanguageService.get("country"),
              hintText: LanguageService.get("select_country"),
              suffixIcon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.v12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.v12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.v12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            validator:
                (value) =>
            model.selectedCountry == null
                ? LanguageService.get("please_select_country")
                : null,
          ),
        ),
      ),
    );
  }

  // FIXED LANGUAGE FIELD - This is the main fix for your issue
  Widget _buildLanguageField(BuildContext context, EmployeeProfileViewModel model) {
    // Get unique language keys to avoid duplicates
    final uniqueLanguages = AppMaps.languageMap.keys.toSet().toList();

    // Ensure the current preferred language exists in the list
    String? currentValue = model.preferredLanguage;
    if (currentValue != null && !uniqueLanguages.contains(currentValue)) {
      currentValue = uniqueLanguages.isNotEmpty ? uniqueLanguages.first : null;
    }

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.v14),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: AppSizes.w4),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        decoration: InputDecoration(
          labelText: LanguageService.get("language"),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.w16,
            vertical: AppSizes.h16,
          ),
        ),
        dropdownColor: AppColors.white,
        items: uniqueLanguages
            .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
            .toList(),
        onChanged: (value) => model.updateLanguage(value ?? 'English'),
      ),
    );
  }

  Widget _buildPermanentAddressSection(
      BuildContext context,
      EmployeeProfileViewModel model,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle(context, LanguageService.get("permanent_address")),
            Spacer(),
            Row(
              children: [
                Checkbox(
                  value: model.sameAsCurrentAddress,
                  onChanged: (value) {
                    model.toggleSameAsCurrentAddress(value ?? false);
                  },
                ),
                Text(LanguageService.get("same_as_current")),
              ],
            ),
          ],
        ),
        SizedBox(height: AppSizes.h10),
        _buildTextField(
          context,
          controller: model.permanentAddressLine1Controller,
          label: LanguageService.get("permanent_address_line_1"),
          readOnly: model.sameAsCurrentAddress,
          onChanged: (_) => model.markDataChanged(),
        ),
        _buildTextField(
          context,
          controller: model.permanentAddressLine2Controller,
          label: LanguageService.get("permanent_address_line_2"),
          readOnly: model.sameAsCurrentAddress,
          onChanged: (_) => model.markDataChanged(),
        ),
        _buildTextField(
          context,
          controller: model.permanentCityController,
          label: LanguageService.get("permanent_city"),
          readOnly: model.sameAsCurrentAddress,
          onChanged: (_) => model.markDataChanged(),
        ),
        _buildTextField(
          context,
          controller: model.permanentStateController,
          label: LanguageService.get("permanent_state"),
          readOnly: model.sameAsCurrentAddress,
          onChanged: (_) => model.markDataChanged(),
        ),
        _buildCountryDropdown(context, model),
        SizedBox(height: AppSizes.h20),
        _buildTextField(
          context,
          controller: model.permanentZipCodeController,
          label:LanguageService.get("pin_code"),
          keyboardType: TextInputType.text,
          readOnly: model.sameAsCurrentAddress,
          onChanged: (_) => model.markDataChanged(),
        ),
      ],
    );
  }

  Widget _buildLockedFieldsSection(
      BuildContext context,
      EmployeeProfileViewModel model,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, LanguageService.get("locked_fields")),
        Container(
          padding: EdgeInsets.all(AppSizes.w12),
          margin: EdgeInsets.only(bottom: AppSizes.h16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(AppSizes.v8),
          ),
          child: Row(
            children: [
              Icon(Icons.lock, color: Colors.orange, size: 20),
              SizedBox(width: AppSizes.w8),
              Expanded(
                child: Text(
                 LanguageService.get("fields_locked_hr_approved"),
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: AppSizes.v12,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSizes.h10),
        _buildTextField(
          context,
          controller: model.panAadharController,
          label: LanguageService.get("pan_aadhar"),
          readOnly: true,
        ),
        _buildTextField(
          context,
          controller: model.bankDetailsController,
          label: LanguageService.get("bank_details"),
          readOnly: true,
        ),
        _buildTextField(
          context,
          controller: model.workRegionController,
          label: LanguageService.get("work_region"),
          readOnly: true,
        ),
        _buildTextField(
          context,
          controller: model.reportingManagerController,
          label: LanguageService.get("reporting_manager"),
          readOnly: true,
        ),
        _buildJoiningDateField(context, model),
        SizedBox(height: AppSizes.h20),
      ],
    );
  }

  Widget _buildJoiningDateField(BuildContext context, EmployeeProfileViewModel model) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.v14),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: AppSizes.w4),
        ),
      ),
      child: TextFormField(
        controller: model.joiningDateController,
        readOnly: true,
        decoration: InputDecoration(
          label: Text(
            LanguageService.get("joining_date"),
          ),
          suffixIcon: Icon(Icons.calendar_today),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.w16,
            vertical: AppSizes.h16,
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(
         LanguageService.get("discard_changes"),
          style: TextStyle(color: AppColors.black),
        ),
        content: Text(
         LanguageService.get("unsaved_changes_warning"),
          style: TextStyle(color: AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
             LanguageService.get("cancel"),
              style: TextStyle(color: AppColors.gray),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              LanguageService.get("yes_leave"),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _showSearchableCountryDropdown(
      BuildContext context,
      EmployeeProfileViewModel model,
      )
  {
    List<Country> countriesList = countries.toList();
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Filter countries based on search
            List<Country> filteredCountries =
            searchQuery.isEmpty
                ? countriesList
                : countriesList
                .where(
                  (country) => country.name.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
            )
                .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.v24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: AppSizes.h12),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header with search
                  Container(
                    padding: EdgeInsets.all(AppSizes.w20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                               LanguageService.get("select_country"),
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: AppColors.gray),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.h16),

                        // Search field
                        TextField(
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: LanguageService.get("search_country"),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.primary,
                            ),
                            suffixIcon:
                            searchQuery.isNotEmpty
                                ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: AppColors.gray,
                              ),
                              onPressed: () {
                                setState(() {
                                  searchQuery = '';
                                });
                              },
                            )
                                : null,
                            fillColor: AppColors.lightGray.withValues(
                              alpha: 0.3,
                            ),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSizes.v12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: AppSizes.h12,
                              horizontal: AppSizes.w16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Results info
                  if (searchQuery.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.w20),
                      child: Row(
                        children: [
                          Text(
                            "${filteredCountries.length}${LanguageService.get("countries_found")}",
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.gray),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: AppSizes.h8),

                  // Countries list
                  Expanded(
                    child:
                    filteredCountries.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.gray.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          SizedBox(height: AppSizes.h16),
                          Text(
                           LanguageService.get("no_countries_found"),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.gray),
                          ),
                          Text(
                            LanguageService.get("try_different_search"),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.gray),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.w20,
                      ),
                      itemCount: filteredCountries.length,
                      itemBuilder: (context, index) {
                        final country = filteredCountries[index];
                        final isSelected =
                            model.selectedCountry == country;

                        return Container(
                          margin: EdgeInsets.only(bottom: AppSizes.h4),
                          decoration: BoxDecoration(
                            color:
                            isSelected
                                ? AppColors.primary.withValues(
                              alpha: 0.1,
                            )
                                : AppColors.transparent,
                            borderRadius: BorderRadius.circular(
                              AppSizes.v8,
                            ),
                            border:
                            isSelected
                                ? Border.all(
                              color: AppColors.primary,
                              width: 1,
                            )
                                : null,
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 32,
                              child: Text(
                                country.flag,
                                style: TextStyle(
                                  fontSize: AppSizes.v20,
                                ),
                              ),
                            ),
                            title: Text(
                              country.name,
                              style: TextStyle(
                                color:
                                isSelected
                                    ? AppColors.primary
                                    : AppColors.black,
                                fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing:
                            isSelected
                                ? Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: AppSizes.v20,
                            )
                                : null,
                            onTap: () {
                              model.updateSelectedCountry(country);
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.v8,
                              ),
                            ),
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSizes.w12,
                              vertical: AppSizes.h4,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}