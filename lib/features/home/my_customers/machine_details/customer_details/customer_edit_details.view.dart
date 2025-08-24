import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:manager/packages/animated_custom_dropdown/custom_dropdown.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/widgets/common_text_field.dart';
import '../../create_customer/create_new_customer.view.dart';

import 'customer_edit_details.vm.dart';

class CustomerEditDetailsView extends StatelessWidget {
  const CustomerEditDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CustomerEditDetailsViewModel>.reactive(
      viewModelBuilder: () => CustomerEditDetailsViewModel()..init(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: _buildAppBar(context, model),
          body: _buildBody(context, model),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    CustomerEditDetailsViewModel model,
  ) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: Image.asset(
          AppImages.back,
          width: 24,
          height: 24,
          color: AppColors.white,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.colorF0F2FC,
            ),
            child: Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                color: AppColors.bluebackground,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'CR',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Leslie Alexander',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          menuPadding: EdgeInsets.zero,
          offset: const Offset(-10, 30),
          onSelected: (String value) {
            if (value == 'edit') {
              // Create customer data map from current form values
              Map<String, dynamic> customerData = {
                'customerName': model.organizationNameController.text,
                'email': model.emailController.text,
                'contactPerson': model.contactPersonController.text,
                'designation': model.selectedDesignation,
                'machineType': model.selectedMachine,
                'phone':
                    model.fullPhoneNumber.isNotEmpty
                        ? '+${model.countryCode}${model.fullPhoneNumber}'
                        : null,
              };

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => CreateNewCustomerView(
                        isEditMode: true,
                        machineData: customerData,
                      ),
                ),
              );
            }
          },
          itemBuilder:
              (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'edit'.lang,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppColors.white,
          shadowColor: AppColors.black.withValues(alpha: 0.1),
          child: const Icon(Icons.more_vert, color: AppColors.white, size: 24),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, CustomerEditDetailsViewModel model) {
    return Container(
      color: AppColors.scaffoldBackground,
      child: SingleChildScrollView(
        child: Form(
          key: model.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCustomerInfoSection(context, model),
                    const SizedBox(height: 24),
                    _buildMachineOwnershipSection(context, model),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),

                child: _buildSaveButton(context, model),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfoSection(
    BuildContext context,
    CustomerEditDetailsViewModel model,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonTextField(
          controller: model.contactPersonController,
          label: LanguageService.get('contact_person'),
          placeholder: LanguageService.get('person_name'),
          validator: CommonValidators.required(
            LanguageService.get('please_enter_contact_person'),
          ),
          enabled: false,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        _buildPhoneField(context, model),
        const SizedBox(height: 16),

        CommonTextField(
          controller: model.emailController,
          label: LanguageService.get('email_address'),
          placeholder: LanguageService.get('email_address_placeholder'),
          keyboardType: TextInputType.emailAddress,
          validator: CommonValidators.email(
            LanguageService.get('please_enter_valid_email'),
          ),
          enabled: false,
          readOnly: true,
        ),
        const SizedBox(height: 16),

        CommonTextField(
          controller: model.designationController,
          label: LanguageService.get('designation'),
          placeholder: LanguageService.get('name'),
          validator: CommonValidators.required(
            LanguageService.get('please_enter_organization_name'),
          ),
          enabled: false,
          readOnly: true,
        ),
        const SizedBox(height: 16),

        // _buildDesignationDropdown(context, model),
        // const SizedBox(height: 16),
        _buildMachineDropdown(context, model),
      ],
    );
  }

  Widget _buildPhoneField(
    BuildContext context,
    CustomerEditDetailsViewModel model,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageService.get('phone_number'),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AbsorbPointer(
          absorbing: true,
          child: IntlPhoneField(
            pickerDialogStyle: PickerDialogStyle(
              backgroundColor: AppColors.colorF8FBFE,
              countryCodeStyle: TextStyle(color: AppColors.black),
              countryNameStyle: TextStyle(color: AppColors.black),
            ),
            controller: model.phoneController,
            initialCountryCode: 'IN',
            onChanged: (phone) {
              model.updatePhoneNumber(phone);
            },
            readOnly: true,
            decoration: InputDecoration(
              hintText: LanguageService.get('phone_number_placeholder'),
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.colorF8FBFE,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.lightGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.lightGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (phone) {
              if (phone == null || phone.number.isEmpty) {
                return LanguageService.get('please_enter_phone_number');
              }
              if (phone.number.length < 10) {
                return LanguageService.get('please_enter_valid_phone_number');
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesignationDropdown(
    BuildContext context,
    CustomerEditDetailsViewModel model,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageService.get('designation'),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        FormField<String>(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return LanguageService.get('please_select_designation');
            }
            return null;
          },
          builder: (FormFieldState<String> field) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDropdown(
                  items: [
                    LanguageService.get('md'),
                    LanguageService.get('ceo'),
                    LanguageService.get('chairman'),
                  ],
                  onChanged: (value) {
                    model.updateDesignation(value);
                    field.didChange(value);
                  },
                  controller: TextEditingController(
                    text: model.selectedDesignation ?? '',
                  ),
                  hintText: LanguageService.get('select_designation'),
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  selectedStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  listItemStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  errorBorderSide: BorderSide(color: AppColors.error, width: 1),
                  borderRadius: BorderRadius.circular(12),
                  fillColor: AppColors.white,
                  borderSide: BorderSide(
                    color:
                        field.hasError ? AppColors.error : AppColors.lightGray,
                  ),
                  fieldSuffixIcon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      field.errorText!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMachineDropdown(
    BuildContext context,
    CustomerEditDetailsViewModel model,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageService.get('assign_machine'),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        FormField<String>(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return LanguageService.get('please_select_machine');
            }
            return null;
          },
          builder: (FormFieldState<String> field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDropdown.search(
                  items: [
                    LanguageService.get('machine_name_format'),
                    LanguageService.get('machine_production_line_a'),
                    LanguageService.get('machine_assembly_unit_b'),
                    LanguageService.get('machine_testing_station_c'),
                  ],
                  onChanged: (value) {
                    model.updateMachine(value);
                    field.didChange(value);
                  },
                  controller: TextEditingController(
                    text: model.selectedMachine ?? '',
                  ),
                  hintText: LanguageService.get('select_machine'),
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  selectedStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  listItemStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  fillColor: AppColors.white,
                  borderSide: BorderSide(
                    color:
                        field.hasError ? AppColors.error : AppColors.lightGray,
                  ),
                  fieldSuffixIcon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      field.errorText!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMachineOwnershipSection(
    BuildContext context,
    CustomerEditDetailsViewModel model,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageService.get('machine_ownership'),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                AppImages.purchaseDate,
                LanguageService.get('purchase_date'),
                LanguageService.get('not_available'),
                AppColors.colorF2A22E,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildInfoRow(
                AppImages.installationDate,
                LanguageService.get('installation_date'),
                LanguageService.get('not_available'),
                AppColors.colorFF6868,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Divider(color: AppColors.lightGray),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                AppImages.warrantyDate,
                LanguageService.get('warranty_start'),
                LanguageService.get('not_available'),
                AppColors.primarySuperLight,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildInfoRow(
                AppImages.warrantyDate,
                LanguageService.get('warranty_end'),
                LanguageService.get('not_available'),
                AppColors.primarySuperLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Divider(color: AppColors.lightGray),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                AppImages.warrantyStatus,
                LanguageService.get('warranty_status'),
                LanguageService.get('not_available'),
                AppColors.color41C293,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildInfoRow(
                AppImages.invoice,
                LanguageService.get('invoice_contract_no'),
                LanguageService.get('not_available'),
                AppColors.color41C293,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String iconPath,
    String label,
    String value,
    Color iconColor, {
    bool isWarning = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.asset(iconPath, width: 20, height: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: isWarning ? AppColors.redBack : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    CustomerEditDetailsViewModel model,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: model.onSavePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(45),
          ),
          elevation: 5,
        ),
        child:
            model.isBusy
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
                : Text(
                  LanguageService.get('save'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}
