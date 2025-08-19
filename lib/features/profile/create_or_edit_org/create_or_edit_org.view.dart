import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:manager/core/models/organization.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';

import '../../../resources/app_resources/app_maps.dart';
import '../../../resources/app_resources/app_resources.dart';
import 'create_or_edit_org.vm.dart';

class UpdateOrganizationViewAttributes {
  final Organization? organization;
  UpdateOrganizationViewAttributes({this.organization});
}

class UpdateOrganizationView extends StatelessWidget {
  const UpdateOrganizationView({super.key, required this.attributes});

  final UpdateOrganizationViewAttributes attributes;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UpdateOrganizationViewModel>.reactive(
      viewModelBuilder: () => UpdateOrganizationViewModel(),
      onViewModelReady: (UpdateOrganizationViewModel model) =>
          model.init(attributes.organization),
      disposeViewModel: false,
      builder: (
          BuildContext context,
          UpdateOrganizationViewModel model,
          Widget? child,
          ) {
        return WillPopScope(
          onWillPop: () async {
            // if (!model.isDataChanged)
            return true;
            // final shouldLeave = await _showExitConfirmationDialog(context, model);
            // return shouldLeave;

          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                model.isEditing ? LanguageService.get("update_details") : LanguageService.get("create_organization"),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.white),
              ),
            ),
            body:

            model.isBusy
                ?
            Container(
              color: AppColors.scaffoldBackground,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            )
                :
            Container(
              color: AppColors.scaffoldBackground,
              child: Form(
                key: model.formKey,
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.w10,
                    vertical: AppSizes.h20,
                  ),
                  children: [
                    // Logo Upload Section with Profile Completion Circle
                    _buildLogoUploadSection(context, model),

                    // Personal Information Section
                    _buildSectionWithEdit(
                      context,
                      title: LanguageService.get("personal_information"),
                      isEditable: model.isPersonalInfoEditable ?? false,
                      onEditToggle: () => {
                        model.togglePersonalInfoEdit(),
                        if(!(model.isPersonalInfoEditable ?? false) )
                        model.onSave(),
                      },
                      children: [
                        _buildTextField(
                          context,
                          controller: model.nameController,
                          label: LanguageService.get("organization_name"),
                          onChanged: (_) => model.markDataChanged(),
                          readOnly: !(model.isPersonalInfoEditable ?? false),
                        ),
                        _buildTextField(
                          context,
                          controller: model.yourNameController,
                          label: LanguageService.get("your_name"),
                          onChanged: (_) => model.markDataChanged(),
                          readOnly: !(model.isPersonalInfoEditable ?? false),
                        ),
                        _buildDesignationField(context, model, !(model.isPersonalInfoEditable ?? false)),
                        if (model.showOtherDesignation)
                          _buildTextField(
                            context,
                            controller: model.otherDesignationController,
                            label: LanguageService.get("please_specify"),
                            onChanged: (_) => model.markDataChanged(),
                            readOnly: !(model.isPersonalInfoEditable ?? false),
                          ),
                        _buildTextField(
                          readOnly: true,
                          context,
                          controller: model.organizationType,
                          label: LanguageService.get("organization_type"),
                        ),
                        _buildPhoneField(
                          context,
                          model,
                          controller: model.phoneController,
                          label: LanguageService.get("primary_phone_no"),
                          onChanged: (_) => model.markDataChanged(),
                          isRequired: false,
                          readOnly: !(model.isPersonalInfoEditable ?? false),
                        ),
                        _buildPhoneField(
                          context,
                          model,
                          controller: model.phone2Controller,
                          label: LanguageService.get("secondary_phone_no"),
                          onChanged: (_) => model.markDataChanged(),
                          isRequired: false,
                          readOnly: !(model.isPersonalInfoEditable ?? false),
                        ),
                        _buildTextField(
                          context,
                          controller: model.emailController,
                          label: LanguageService.get("primary_email"),
                          onChanged: (_) => model.markDataChanged(),
                          keyboardType: TextInputType.emailAddress,
                          readOnly: !(model.isPersonalInfoEditable ?? false),
                          showVerifiedTick: true,
                        ),
                        _buildTextField(
                          context,
                          controller: model.email2Controller,
                          label: LanguageService.get("secondary_email"),
                          onChanged: (_) => model.markDataChanged(),
                          keyboardType: TextInputType.emailAddress,
                          readOnly: !(model.isPersonalInfoEditable ?? false),
                        ),
                      ],
                    ),

                    SizedBox(height: AppSizes.h20),

                    // Corporate Address Section
                    _buildSectionWithEdit(
                      context,
                      title: LanguageService.get("corporate_address"),
                      isEditable: model.isCorporateAddressEditable ?? false,
                      onEditToggle: () => {
                        model.toggleCorporateAddressEdit(),
                        if(!(model.isCorporateAddressEditable ?? false) )
                        model.onSave(),
                      },
                      children: [
                        _buildTextField(
                          context,
                          controller: model.addressLine1Controller,
                          label: LanguageService.get("address_line_1"),
                          onChanged: (_) => model.markDataChanged(),
                          readOnly: !(model.isCorporateAddressEditable ?? false),
                        ),
                        _buildTextField(
                          context,
                          controller: model.addressLine2Controller,
                          label: LanguageService.get("address_line_2"),
                          onChanged: (_) => model.markDataChanged(),
                          readOnly: !(model.isCorporateAddressEditable ?? false),
                        ),
                        _buildTextField(
                          context,
                          controller: model.cityController,
                          label: LanguageService.get("city"),
                          onChanged: (_) => model.markDataChanged(),
                          readOnly: !(model.isCorporateAddressEditable ?? false),
                        ),
                        _buildTextField(
                          context,
                          controller: model.stateController,
                          label: LanguageService.get("state_province"),
                          onChanged: (_) => model.markDataChanged(),
                          readOnly: !(model.isCorporateAddressEditable ?? false),
                        ),
                        _buildCountryDropdown(context, model, "corporate"),
                        _buildTextField(
                          context,
                          controller: model.pinCodeController,
                          label: LanguageService.get("pin_code"),
                          onChanged: (_) => model.markDataChanged(),
                          keyboardType: TextInputType.number,
                          readOnly: !(model.isCorporateAddressEditable ?? false),
                        ),
                      ],
                    ),

                    SizedBox(height: AppSizes.h20),
                    _buildSectionWithEdit(
                      context,
                      title: LanguageService.get("factory_address"),
                      isEditable: model.isFactoryAddressEditable ?? false,
                      onEditToggle: () => {
                        model.toggleFactoryAddressEdit(),
                        if(!(model.isFactoryAddressEditable ?? false))
                        model.onSave(),
                      },
                      showCheckbox: true,
                      checkboxValue: model.sameAsCorpAddress,
                      checkboxText: LanguageService.get("same_as_corporate_address"),
                      onCheckboxChanged: (model.isFactoryAddressEditable ?? false)
                          ? (value) => model.toggleSameAsCorpAddress(value ?? false)
                          : null,
                      children: [
                        _buildTextField(
                          context,
                          controller: model.factoryAddressLine1Controller,
                          label: LanguageService.get("address_line_1"),
                          readOnly: model.sameAsCorpAddress || !(model.isFactoryAddressEditable ?? false),
                          onChanged: (_) => model.markDataChanged(),
                        ),
                        _buildTextField(
                          context,
                          controller: model.factoryAddressLine2Controller,
                          label: LanguageService.get("address_line_2"),
                          readOnly: model.sameAsCorpAddress || !(model.isFactoryAddressEditable ?? false),
                          onChanged: (_) => model.markDataChanged(),
                        ),
                        _buildTextField(
                          context,
                          controller: model.factoryCityController,
                          label: LanguageService.get("city"),
                          readOnly: model.sameAsCorpAddress || !(model.isFactoryAddressEditable ?? false),
                          onChanged: (_) => model.markDataChanged(),
                        ),
                        _buildTextField(
                          context,
                          controller: model.factoryStateController,
                          label: LanguageService.get("state_province"),
                          readOnly: model.sameAsCorpAddress || !(model.isFactoryAddressEditable ?? false),
                          onChanged: (_) => model.markDataChanged(),
                        ),
                        _buildCountryDropdown(context, model, "factory"),
                        _buildTextField(
                          context,
                          controller: model.factoryPinCodeController,
                          label: LanguageService.get("pin_code"),
                          keyboardType: TextInputType.number,
                          readOnly: model.sameAsCorpAddress || !(model.isFactoryAddressEditable ?? false),
                          onChanged: (_) => model.markDataChanged(),
                        ),
                      ],
                    ),


                    // _buildUnitsSection(context, model),
                    // Additional Info Section
                    // _buildSectionWithEdit(
                    //   context,
                    //   title: LanguageService.get("additional_info"),
                    //   isEditable: model.isAdditionalInfoEditable ?? false,
                    //   onEditToggle: () => model.toggleAdditionalInfoEdit(),
                    //   children: [
                    //     _buildTextField(
                    //       context,
                    //       controller: model.establishedYearController,
                    //       label: LanguageService.get("established_year"),
                    //       onChanged: (_) => model.markDataChanged(),
                    //       keyboardType: TextInputType.number,
                    //       readOnly: !(model.isAdditionalInfoEditable ?? false),
                    //     ),
                    //     _buildTextField(
                    //       context,
                    //       controller: model.descriptionController,
                    //       label: LanguageService.get("few_words_about_your_organization"),
                    //       onChanged: (_) => model.markDataChanged(),
                    //       readOnly: !(model.isAdditionalInfoEditable ?? false),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionWithEdit(
      BuildContext context, {
        required String title,
        required bool isEditable,
        required VoidCallback onEditToggle,
        required List<Widget> children,
        bool showCheckbox = false,
        bool? checkboxValue,
        String? checkboxText,
        ValueChanged<bool?>? onCheckboxChanged,
      }) {
    return
      Container(
        padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w10,
        vertical: AppSizes.h15,
       ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.v12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ]
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle(context, title),
              ElevatedButton(
                onPressed: onEditToggle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEditable ? AppColors.success : AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.w12,
                    vertical: AppSizes.h8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.v20),
                  ),
                ),
                child: Text(isEditable ? LanguageService.get("update") : LanguageService.get("edit_details")),
              ),
            ],
          ),

          if (showCheckbox && checkboxText != null)
            Row(
              children: [
                Checkbox(
                  value: checkboxValue ?? false,
                  onChanged: onCheckboxChanged,
                  activeColor: AppColors.primary,
                ),
                Text(checkboxText),
              ],
            ),
          ...children,
        ],
            ),
      );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(top: AppSizes.h4),
      child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
      ),
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
        bool showVerifiedTick = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(
            left: AppSizes.w4,
            bottom: AppSizes.h5,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textGray,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        // Text field container
        Container(
          margin: EdgeInsets.only(bottom: AppSizes.h10),
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.v14),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: 16,
              color: readOnly ? Colors.grey.shade600 : Colors.black,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSizes.w16,
                vertical: AppSizes.h16,
              ),
              suffixIcon: showVerifiedTick
                  ? Icon(
                Icons.verified,
                color: Colors.green,
                size: AppSizes.w20,
              )
                  : null,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(
      BuildContext context,
      UpdateOrganizationViewModel model, {
        required TextEditingController controller,
        required String label,
        void Function(String)? onChanged,
        bool isRequired = false,
        bool readOnly = false,
      }) {
    return
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(
              left: AppSizes.w4,
              bottom: AppSizes.h5,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textGray,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Container(
          margin: EdgeInsets.only(bottom: AppSizes.h16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.v14),
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
              fillColor: readOnly ? AppColors.white : null,
              filled: readOnly,
            ),
            initialCountryCode: 'IN',
            onChanged: (phone) {
              model.updatePhoneNumber(phone);
              if (onChanged != null) {
                onChanged(phone.completeNumber);
              }
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
              ),
        ],
      );
  }

  Widget _buildDesignationField(
      BuildContext context,
      UpdateOrganizationViewModel model,
      bool readOnly,
      ) {
    return
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(
              left: AppSizes.w4,
              bottom: AppSizes.h5,
            ),
            child: Text(
              LanguageService.get("your_designation"),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textGray,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Container(
          margin: EdgeInsets.only(bottom: AppSizes.h16),
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.v14),
          ),
          child: DropdownButtonFormField<String>(
            value: model.designationType,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSizes.w16,
                vertical: AppSizes.h10,
              ),
              fillColor: readOnly ? AppColors.white : null,
              filled: readOnly,
            ),
            dropdownColor: AppColors.white,
            items: [
              DropdownMenuItem(value: 'md', child: Text('Managing Director (MD)')),
              DropdownMenuItem(value: 'ceo', child: Text('Chief Executive Officer (CEO)')),
              DropdownMenuItem(value: 'partner', child: Text('Managing Partner')),
              DropdownMenuItem(value: 'chairman', child: Text('Chairman / Chairperson')),
              DropdownMenuItem(value: 'others', child: Text('Others')),
            ],
            onChanged: readOnly ? null : (value) {
              model.updateDesignationType(value);
              if (value == 'others') {
                model.showOtherDesignation = true;
              } else {
                model.showOtherDesignation = false;
              }
            },
          ),
              ),
        ],
      );
  }

  Widget _buildCountryDropdown(
      BuildContext context,
      UpdateOrganizationViewModel model,
      String type, // "corporate" or "factory"
      ) {
    final isReadOnly = type == "corporate"
        ? !(model.isCorporateAddressEditable ?? false)
        : (type == "factory"
        ? (model.sameAsCorpAddress || !(model.isFactoryAddressEditable ?? false))
        : true);

    final selectedCountry = type == "corporate"
        ? model.selectedCountry
        : model.selectedCountryF;

    if (isReadOnly) {
      return Container(
        margin: EdgeInsets.only(bottom: AppSizes.h16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.v14),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.w16,
            vertical: AppSizes.h16,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.v12),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LanguageService.get("country"),
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showSearchableCountryDropdown(context, model, type),
      child: AbsorbPointer(
        child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(
                left: AppSizes.w4,
                bottom: AppSizes.h5,
              ),
              child: Text(
                LanguageService.get("Country"),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGray,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: AppSizes.h16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.v14),
              ),
              child: TextFormField(
                controller: TextEditingController(
                  text: selectedCountry != null
                      ? '${selectedCountry.flag} ${selectedCountry.name}'
                      : '',
                ),
                decoration: InputDecoration(
                  labelText: LanguageService.get("Select country"),
                  suffixIcon: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                  ),
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
                validator: (value) =>
                selectedCountry == null ? LanguageService.get("please_select_country") : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoUploadSection(
      BuildContext context,
      UpdateOrganizationViewModel model,
      ) {
    final completionPercentage = model.calculateProfileCompletion();

    return Container(
      padding: EdgeInsets.all(AppSizes.w16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.v14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer progress ring
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
              // Inner circle with logo/placeholder
              Container(
                height: AppSizes.h110,
                width: AppSizes.h110,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 3),
                  image: model.logoFile != null
                      ? DecorationImage(
                    image: FileImage(model.logoFile!),
                    fit: BoxFit.cover,
                  )
                      : model.logoUrl.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(model.logoUrl),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: model.logoFile == null && model.logoUrl.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: AppSizes.v36,
                        color: AppColors.gray,
                      ),
                      SizedBox(height: AppSizes.h4),
                      Text(
                        LanguageService.get("upload_logo"),
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
              // Edit button positioned at bottom right
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: model.onLogoUpload,
                  child: Container(
                    height: AppSizes.h36,
                    width: AppSizes.h36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: AppColors.white,
                      size: AppSizes.v18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (model.isUploading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.h8),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: model.uploadProgress,
                    backgroundColor: AppColors.lightGray,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  SizedBox(height: AppSizes.h4),
                  Text(
                    "${(model.uploadProgress * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontSize: AppSizes.v12,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: AppSizes.h10),
          Text(
            model.name ?? "",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
            Text(
                model.email ?? "",
                style: TextStyle(
                fontSize: 12,
                color: AppColors.textGray,
              ),
            ),
        ],
      ),
    );
  }

  // Widget _buildUnitsSection(
  //     BuildContext context,
  //     UpdateOrganizationViewModel model,
  //     ) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           _buildSectionTitle(context, LanguageService.get("factory_office_manufacturing_Location")),
  //         ],
  //       ),
  //       SizedBox(height: AppSizes.h20),
  //       ...List.generate(model.units.length, (index) {
  //         return _buildUnitCard(context, model, index);
  //       }),
  //       SizedBox(height: AppSizes.h10),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.end,
  //         children: [
  //           TextButton.icon(
  //             onPressed: model.addUnit,
  //             icon: Icon(Icons.add, color: AppColors.primary),
  //             label: Text(LanguageService.get("add"), style: TextStyle(color: AppColors.primary)),
  //           ),
  //         ],
  //       ),
  //       if (model.units.isEmpty)
  //         Container(
  //           padding: EdgeInsets.all(AppSizes.w20),
  //           decoration: BoxDecoration(
  //             border: Border.all(color: AppColors.lightGray),
  //             borderRadius: BorderRadius.circular(AppSizes.v12),
  //           ),
  //           child: Column(
  //             children: [
  //               Icon(
  //                 Icons.business_outlined,
  //                 size: AppSizes.v48,
  //                 color: AppColors.gray,
  //               ),
  //               SizedBox(height: AppSizes.h8),
  //               Text(
  //                 LanguageService.get("no_units_added"),
  //                 style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.gray),
  //               ),
  //               Text(
  //                 LanguageService.get("add_units_manage_locations"),
  //                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
  //                 textAlign: TextAlign.center,
  //               ),
  //             ],
  //           ),
  //         ),
  //     ],
  //   );
  // }

  Widget _buildUnitCard(
      BuildContext context,
      UpdateOrganizationViewModel model,
      int index,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h16),
      padding: EdgeInsets.all(AppSizes.w16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGray),
        borderRadius: BorderRadius.circular(AppSizes.v12),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              IconButton(
                onPressed: () => model.removeUnit(index),
                icon: Icon(Icons.delete_outline, color: AppColors.error),
                constraints: BoxConstraints(),
                padding: EdgeInsets.all(AppSizes.w8),
              ),
            ],
          ),
          SizedBox(height: AppSizes.h12),
          _buildTextField(
            context,
            controller: model.unitNameControllers[index]!,
            label: LanguageService.get("unit_name"),
          ),
          _buildCountrySelectionField(context, model, index),
          _buildTextField(
            context,
            controller: model.unitLocalityControllers[index]!,
            label: LanguageService.get("locality"),
          ),
        ],
      ),
    );
  }

  Widget _buildCountrySelectionField(
      BuildContext context,
      UpdateOrganizationViewModel model,
      int index,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.v14),
      ),
      child: GestureDetector(
        onTap: () => _showSearchableCountryDropdownForUnit(context, model, index),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.w16,
            vertical: AppSizes.h16,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGray),
            borderRadius: BorderRadius.circular(AppSizes.v12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LanguageService.get("country"),
                style: TextStyle(fontSize: 12, color: AppColors.gray),
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      model.unitCountries[index] ?? LanguageService.get("select_country"),
                      style: TextStyle(
                        color: model.unitCountries[index] != null
                            ? AppColors.black
                            : AppColors.gray,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: AppColors.gray),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchableCountryDropdown(
      BuildContext context,
      UpdateOrganizationViewModel model,
      String type,
      ) {
    List<Country> countriesList = countries.toList();
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<Country> filteredCountries = searchQuery.isEmpty
                ? countriesList
                : countriesList
                .where((country) => country.name.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.v24)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: AppSizes.h12),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(AppSizes.w20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                LanguageService.get("select_country"),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                        TextField(
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: LanguageService.get("search_countries"),
                            prefixIcon: Icon(Icons.search, color: AppColors.primary),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                              icon: Icon(Icons.clear, color: AppColors.gray),
                              onPressed: () {
                                setState(() {
                                  searchQuery = '';
                                });
                              },
                            )
                                : null,
                            fillColor: AppColors.lightGray.withOpacity(0.3),
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
                  if (searchQuery.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.w20),
                      child: Row(
                        children: [
                          Text(
                            "${filteredCountries.length} ${LanguageService.get("countries_found")}",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: AppSizes.h8),
                  Expanded(
                    child: filteredCountries.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.gray.withOpacity(0.5),
                          ),
                          SizedBox(height: AppSizes.h16),
                          Text(
                            LanguageService.get("no_countries_found"),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.gray),
                          ),
                          Text(
                            LanguageService.get("try_different_search"),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.w20),
                      itemCount: filteredCountries.length,
                      itemBuilder: (context, index) {
                        final country = filteredCountries[index];
                        final selectedCountry = type == "corporate"
                            ? model.selectedCountry
                            : model.selectedCountryF;
                        final isSelected = selectedCountry == country;

                        return Container(
                          margin: EdgeInsets.only(bottom: AppSizes.h4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.transparent,
                            borderRadius: BorderRadius.circular(AppSizes.v8),
                            border: isSelected
                                ? Border.all(color: AppColors.primary, width: 1)
                                : null,
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 32,
                              child: Text(
                                country.flag,
                                style: TextStyle(fontSize: AppSizes.v20),
                              ),
                            ),
                            title: Text(
                              country.name,
                              style: TextStyle(
                                color: isSelected ? AppColors.primary : AppColors.black,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: AppSizes.v20,
                            )
                                : null,
                            onTap: () {
                              if (type == "corporate") {
                                model.updateSelectedCountry(country);
                              } else {
                                model.updateSelectedCountryF(country);
                              }
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.v8),
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

  void _showSearchableCountryDropdownForUnit(
      BuildContext context,
      UpdateOrganizationViewModel model,
      int unitIndex,
      ) {
    List<Country> countriesList = countries.toList();
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<Country> filteredCountries = searchQuery.isEmpty
                ? countriesList
                : countriesList
                .where((country) => country.name.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.v24)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: AppSizes.h12),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(AppSizes.w20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${LanguageService.get("select_country_for_unit")} ${unitIndex + 1}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                        TextField(
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: LanguageService.get("search_countries"),
                            prefixIcon: Icon(Icons.search, color: AppColors.primary),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                              icon: Icon(Icons.clear, color: AppColors.gray),
                              onPressed: () {
                                setState(() {
                                  searchQuery = '';
                                });
                              },
                            )
                                : null,
                            fillColor: AppColors.lightGray.withOpacity(0.3),
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
                  if (searchQuery.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.w20),
                      child: Row(
                        children: [
                          Text(
                            "${filteredCountries.length} ${LanguageService.get("countries_found")}",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: AppSizes.h8),
                  Expanded(
                    child: filteredCountries.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.gray.withOpacity(0.5),
                          ),
                          SizedBox(height: AppSizes.h16),
                          Text(
                            LanguageService.get("no_countries_found"),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.gray),
                          ),
                          Text(
                            LanguageService.get("try_different_search"),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.w20),
                      itemCount: filteredCountries.length,
                      itemBuilder: (context, index) {
                        final country = filteredCountries[index];
                        final isSelected = model.unitCountries[unitIndex] == country.name;

                        return Container(
                          margin: EdgeInsets.only(bottom: AppSizes.h4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.transparent,
                            borderRadius: BorderRadius.circular(AppSizes.v8),
                            border: isSelected
                                ? Border.all(color: AppColors.primary, width: 1)
                                : null,
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 32,
                              child: Text(
                                country.flag,
                                style: TextStyle(fontSize: AppSizes.v20),
                              ),
                            ),
                            title: Text(
                              country.name,
                              style: TextStyle(
                                color: isSelected ? AppColors.primary : AppColors.black,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: AppSizes.v20,
                            )
                                : null,
                            onTap: () {
                              model.updateUnitCountry(unitIndex, country.name);
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.v8),
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

  Future<bool> _showExitConfirmationDialog(BuildContext context, UpdateOrganizationViewModel model) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(
          LanguageService.get("discard_changes"),
          style: TextStyle(color: AppColors.primary),
        ),
        content: Text(
          LanguageService.get("unsaved_changes_warning"),
          style: TextStyle(color: AppColors.primary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              LanguageService.get("cancel"),
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              model.onSave();
            },
            child: Text(LanguageService.get("save_and_leave")),
          ),
        ],
      ),
    ) ??
        false;
  }
}