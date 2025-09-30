import 'package:flutter/material.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:phone_input/phone_input_package.dart';
import 'package:manager/core/models/organization.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/widgets/common_text_field.dart';
import 'package:manager/widgets/common_elevated_button.dart';
import 'package:manager/widgets/common_app_bar.dart';

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
      onViewModelReady: (UpdateOrganizationViewModel model) => model.init(attributes.organization),
      disposeViewModel: false,
      builder: (BuildContext context, UpdateOrganizationViewModel model, Widget? child) {
        return WillPopScope(
          onWillPop: () async {
            // if (!model.isDataChanged)
            return true;
            // final shouldLeave = await _showExitConfirmationDialog(context, model);
            // return shouldLeave;
          },
          child: Scaffold(
            appBar: _buildAppBar(context, model),
            backgroundColor: AppColors.cultured,
            body:
                model.isBusy
                    ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : Form(
                      key: model.formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            // Personal Information Section
                            _buildPersonalInformationSection(context, model),
                            const SizedBox(height: 15),

                            // Corporate Address Section
                            _buildCorporateAddressSection(context, model),
                            const SizedBox(height: 15),

                            // Factory Address Section
                            _buildFactoryAddressSection(context, model),
                          ],
                        ),
                      ),
                    ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, UpdateOrganizationViewModel model) {
    return GradientAppBar(titleKey: "update_profile");
  }

  Widget _buildPersonalInformationSection(BuildContext context, UpdateOrganizationViewModel model) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 3),
                          image:
                              model.logoFile != null
                                  ? DecorationImage(image: FileImage(model.logoFile!), fit: BoxFit.cover)
                                  : model.logoUrl.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(model.logoUrl), fit: BoxFit.cover)
                                  : null,
                        ),
                        child: model.logoFile == null && model.logoUrl.isEmpty ? const Icon(Icons.person, size: 40, color: AppColors.gray) : null,
                      ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            // model.navigateToCreateOrEditOrgView();
                          },
                          child: Container(
                            padding: EdgeInsets.all(3.5),
                            decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(14)),
                            child: Image.asset(AppImages.edit, width: 20, height: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Name and Email
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        (model.profileModel?.user?.fullName != null && model.profileModel!.user!.fullName!.isNotEmpty)
                            ? model.profileModel!.user!.fullName!
                            : model.nameController.text.isNotEmpty
                            ? model.nameController.text
                            : "Leslie Alexander",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.black),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        (model.profileModel?.user?.email != null && model.profileModel!.user!.email!.isNotEmpty)
                            ? model.profileModel!.user!.email!
                            : model.emailController.text.isNotEmpty
                            ? model.emailController.text
                            : "yourmail@gmail.com",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 25),

          Row(
            children: [
              Expanded(
                child: Text(
                  LanguageService.get("personal_information"),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.black),
                ),
              ),
              // Edit Details / Update Button
              CommonElevatedButton(
                onPressed: () {
                  if (model.isPersonalInfoEditable ?? false) {
                    model.savePersonalInfo();
                  } else {
                    model.togglePersonalInfoEdit();
                  }
                },
                label: (model.isPersonalInfoEditable ?? false) ? LanguageService.get("update") : LanguageService.get("edit_details"),
                backgroundColor: (model.isPersonalInfoEditable ?? false) ? AppColors.success : AppColors.primaryDark,
                textColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                borderRadius: 10,
                fontSize: 10,
                height: 28,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Organization Name (Read-only)
          CommonTextField(
            controller: TextEditingController(text: model.profileModel?.organizationName ?? "Samsung"),
            label: LanguageService.get("organization_name"),
            placeholder: model.profileModel?.organizationName ?? "Samsung",
            readOnly: true,
            contentPadding: EdgeInsets.all(12),
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          // Unit Name with info icon
          Stack(
            children: [
              CommonTextField(
                controller: model.unitNameController,
                label: LanguageService.get("unit_name"),
                placeholder: LanguageService.get("unit_name"),
                readOnly: !(model.isPersonalInfoEditable ?? false),
                contentPadding: EdgeInsets.all(12),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Positioned(
                right: 0,
                bottom: 2,
                child: Center(
                  child: CustomPopup(
                    content: Text(
                      '''Use this to create and manage a new factory or unit under your\ncompany — such as a new location, branch, or brand in another country.''',
                      style: TextStyle(color: AppColors.white, fontSize: 9, fontWeight: FontWeight.w500),
                    ),
                    position: PopupPosition.top,
                    arrowColor: AppColors.textGrey,
                    backgroundColor: AppColors.textGrey,
                    child: Padding(padding: EdgeInsets.all(16), child: Image.asset(AppImages.alert, width: 16, height: 16)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Your Name (Read-only)
          CommonTextField(
            controller: TextEditingController(text: model.profileModel?.user?.fullName ?? "Raj"),
            label: LanguageService.get("your_name"),
            placeholder: model.profileModel?.user?.fullName ?? "Raj",
            readOnly: true,
            contentPadding: EdgeInsets.all(12),
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          // Your Designation (Dropdown)
          _buildDesignationDropdown(context, model),
          const SizedBox(height: 16),

          // Primary Phone Number
          _buildPhoneFieldWithFlag(context, model),
          const SizedBox(height: 16),

          // Primary Email with verification
          CommonTextField(
            controller: TextEditingController(text: model.profileModel?.user?.email ?? "tt@gamil.com"),
            label: LanguageService.get("primary_email"),
            placeholder: model.profileModel?.user?.email ?? "tt@gamil.com",
            keyboardType: TextInputType.emailAddress,
            suffixIcon: Padding(padding: const EdgeInsets.all(12), child: Image.asset(AppImages.verified, width: 22, height: 22)),
            contentPadding: EdgeInsets.all(12),
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),

          // Verification message
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success),
            ),
            child: Row(
              children: [
                Image.asset(AppImages.alert, width: 19, height: 19, color: AppColors.success),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    LanguageService.get('verification_sent_message'),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorporateAddressSection(BuildContext context, UpdateOrganizationViewModel model) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10)),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  LanguageService.get("corporate_address"),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.black),
                ),
              ),
              // Edit Details / Update Button
              CommonElevatedButton(
                onPressed: () {
                  if (model.isCorporateAddressEditable ?? false) {
                    model.saveCorporateAddress();
                  } else {
                    model.toggleCorporateAddressEdit();
                  }
                },
                label: (model.isCorporateAddressEditable ?? false) ? LanguageService.get("update") : LanguageService.get("edit_details"),
                backgroundColor: (model.isCorporateAddressEditable ?? false) ? AppColors.success : AppColors.primaryDark,
                textColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                borderRadius: 10,
                fontSize: 10,
                height: 28,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
          const SizedBox(height: 15),

          CommonTextField(
            controller: model.addressLine1Controller,
            label: LanguageService.get("address_line_1"),
            placeholder: LanguageService.get("address_line_1"),
            readOnly: !(model.isCorporateAddressEditable ?? false),
            contentPadding: EdgeInsets.all(12),
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 15),

          CommonTextField(
            controller: model.addressLine2Controller,
            label: LanguageService.get("address_line_2"),
            placeholder: LanguageService.get("address_line_2"),
            readOnly: !(model.isCorporateAddressEditable ?? false),
            contentPadding: EdgeInsets.all(12),
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: CommonTextField(
                  controller: model.cityController,
                  label: LanguageService.get("city"),
                  placeholder: LanguageService.get("city"),
                  readOnly: !(model.isCorporateAddressEditable ?? false),
                  contentPadding: EdgeInsets.all(12),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 15),

              Expanded(
                child: CommonTextField(
                  controller: model.stateController,
                  label: LanguageService.get("state_province"),
                  placeholder: LanguageService.get("state_province"),
                  readOnly: !(model.isCorporateAddressEditable ?? false),
                  contentPadding: EdgeInsets.all(12),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _buildCountryDropdown(
                  context,
                  model,
                  model.profileModel?.corporateAddress?.country ?? "India",
                  (value) => model.updateCountry(value),
                  !(model.isCorporateAddressEditable ?? false),
                ),
              ),
              const SizedBox(width: 15),

              Expanded(
                child: CommonTextField(
                  controller: model.pinCodeController,
                  label: LanguageService.get("pin_code"),
                  placeholder: LanguageService.get("pin_code"),
                  readOnly: !(model.isCorporateAddressEditable ?? false),
                  contentPadding: EdgeInsets.all(12),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFactoryAddressSection(BuildContext context, UpdateOrganizationViewModel model) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10)),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LanguageService.get("factory_address"),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.black),
                    ),
                    SizedBox(height: 9),
                    // Same as Corporate Address checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: model.sameAsCorpAddress,
                          onChanged: (model.isFactoryAddressEditable ?? false) ? (value) => model.toggleSameAsCorpAddress(value ?? false) : null,
                        ),
                        SizedBox(width: 6),
                        Text(
                          LanguageService.get("same_as_corporate_address"),
                          style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Edit Details / Update Button
              CommonElevatedButton(
                onPressed: () {
                  if (model.isFactoryAddressEditable ?? false) {
                    model.saveFactoryAddress();
                  } else {
                    model.toggleFactoryAddressEdit();
                  }
                },
                label: (model.isFactoryAddressEditable ?? false) ? LanguageService.get("update") : LanguageService.get("edit_details"),
                backgroundColor: (model.isFactoryAddressEditable ?? false) ? AppColors.success : AppColors.primaryDark,
                textColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                borderRadius: 10,
                fontSize: 10,
                height: 28,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
          const SizedBox(height: 15),

          CommonTextField(
            controller: model.factoryAddressLine1Controller,
            label: LanguageService.get("address_line_1"),
            placeholder: LanguageService.get("address_line_1"),
            readOnly: model.sameAsCorpAddress || !(model.isFactoryAddressEditable ?? false),
            contentPadding: EdgeInsets.all(12),
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 15),

          CommonTextField(
            controller: model.factoryAddressLine2Controller,
            label: LanguageService.get("address_line_2"),
            placeholder: LanguageService.get("address_line_2"),
            readOnly: model.sameAsCorpAddress || !(model.isFactoryAddressEditable ?? false),
            contentPadding: EdgeInsets.all(12),
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: CommonTextField(
                  controller: model.factoryCityController,
                  label: LanguageService.get("city"),
                  placeholder: LanguageService.get("city"),
                  readOnly: model.sameAsCorpAddress || !(model.isFactoryAddressEditable ?? false),
                  contentPadding: EdgeInsets.all(12),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 15),

              Expanded(
                child: CommonTextField(
                  controller: model.factoryStateController,
                  label: LanguageService.get("state_province"),
                  placeholder: LanguageService.get("state_province"),
                  readOnly: model.sameAsCorpAddress || !(model.isFactoryAddressEditable ?? false),
                  contentPadding: EdgeInsets.all(12),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _buildCountryDropdown(
                  context,
                  model,
                  model.profileModel?.factoryAddress?.country ?? "India",
                  (value) => model.updateFactoryCountry(value),
                  model.sameAsCorpAddress || !(model.isFactoryAddressEditable ?? false),
                ),
              ),
              const SizedBox(width: 15),

              Expanded(
                child: CommonTextField(
                  controller: model.factoryPinCodeController,
                  label: LanguageService.get("pin_code"),
                  placeholder: LanguageService.get("pin_code"),
                  readOnly: model.sameAsCorpAddress || !(model.isFactoryAddressEditable ?? false),
                  contentPadding: EdgeInsets.all(12),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesignationDropdown(BuildContext context, UpdateOrganizationViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LanguageService.get("your_designation"), style: const TextStyle(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SizedBox(
          height: 46,
          child: AbsorbPointer(
            absorbing: !(model.isPersonalInfoEditable ?? false),
            child: DropdownFlutter<String>(
              closedHeaderPadding: EdgeInsets.all(12),
              items: const ["MD", "CEO", "Chairman", "Other"],
              onChanged:
                  (model.isPersonalInfoEditable ?? false)
                      ? (value) {
                        model.updateDesignationType(value);
                        if (value == 'Other') {
                          model.showOtherDesignation = true;
                        } else {
                          model.showOtherDesignation = false;
                        }
                      }
                      : null,
              initialItem: _getValidInitialItem(model.designationType),
              hintText: LanguageService.get('select_designation'),
              decoration: CustomDropdownDecoration(
                headerStyle: TextStyle(
                  fontSize: 14,
                  color: (model.isPersonalInfoEditable ?? false) ? AppColors.black : AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                closedBorder: Border.all(color: AppColors.lightGrey),
                expandedBorder: Border.all(color: AppColors.primary),
                expandedFillColor: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneFieldWithFlag(BuildContext context, UpdateOrganizationViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageService.get("primary_phone_number"),
          style: const TextStyle(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        AbsorbPointer(
          absorbing: !(model.isPersonalInfoEditable ?? false),
          child: PhoneInput(
            flagShape: BoxShape.rectangle,
            defaultCountry: _mapCountryCodeToIso(model.profileModel?.user?.countryCode) ?? IsoCode.IN,
            initialValue:
                (model.profileModel?.user?.phone != null && model.profileModel!.user!.phone!.isNotEmpty)
                    ? PhoneNumber(
                      isoCode: _mapCountryCodeToIso(model.profileModel?.user?.countryCode) ?? IsoCode.IN,
                      nsn: model.profileModel!.user!.phone!,
                    )
                    : null,
            key: ValueKey('org_phone_${model.profileModel?.user?.countryCode}_${model.profileModel?.user?.phone}'),
            countrySelectorNavigator: CountrySelectorNavigator.dialog(
              countryCodeStyle: const TextStyle(color: AppColors.black),
              countryNameStyle: const TextStyle(color: AppColors.black),
              searchInputTextStyle: const TextStyle(color: AppColors.textGrey),
              searchInputDecoration: InputDecoration(
                hintText: LanguageService.get('search_country'),
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.v12),
                  borderSide: const BorderSide(color: AppColors.lightGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.v12),
                  borderSide: const BorderSide(color: AppColors.lightGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.v12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            onChanged:
                (model.isPersonalInfoEditable ?? false)
                    ? (phone) {
                      if (phone != null) {
                        // Convert phone_input PhoneNumber to the format expected by the model
                        model.updatePhoneNumberFromString('${phone.countryCode}${phone.nsn}');
                      }
                    }
                    : null,

            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: AppColors.lightGrey)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: AppColors.lightGrey)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              suffixIcon: Padding(padding: const EdgeInsets.all(12), child: Image.asset(AppImages.verified, width: 22, height: 22)),
            ),
          ),
        ),
      ],
    );
  }

  String? _getValidInitialItem(String? designationType) {
    const List<String> validItems = ["MD", "CEO", "Chairman", "Other"];

    if (designationType != null && validItems.contains(designationType)) {
      return designationType;
    }
    return null;
  }

  // Very small mapper for now – expands easily if needed
  IsoCode? _mapCountryCodeToIso(String? countryCode) {
    switch (countryCode) {
      case '+91':
        return IsoCode.IN;
      case '+1':
        return IsoCode.US;
      case '+44':
        return IsoCode.GB;
    }
    return null;
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
  //             border: Border.all(color: AppColors.lightGrey),
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

  Widget _buildCountryDropdown(
    BuildContext context,
    UpdateOrganizationViewModel model,
    String selectedValue,
    Function(String?) onChanged,
    bool isReadOnly,
  ) {
    // Ensure the selected value is in the countries list, otherwise use default
    String validSelectedValue = selectedValue;
    if (!model.countries.contains(selectedValue)) {
      validSelectedValue = 'India'; // Default fallback
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LanguageService.get("country"), style: const TextStyle(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SizedBox(
          height: 46,
          child: AbsorbPointer(
            absorbing: isReadOnly,
            child: DropdownFlutter<String>(
              closedHeaderPadding: EdgeInsets.all(12),
              items: model.countries,
              onChanged: isReadOnly ? null : onChanged,
              initialItem: validSelectedValue,
              hintText: LanguageService.get('select_country'),
              decoration: CustomDropdownDecoration(
                headerStyle: TextStyle(fontSize: 12, color: isReadOnly ? AppColors.textGrey : AppColors.black, fontWeight: FontWeight.w500),
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                closedBorder: Border.all(color: AppColors.lightGrey),
                expandedBorder: Border.all(color: AppColors.primary),
                expandedFillColor: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
