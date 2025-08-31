import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_input/phone_input_package.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/widgets/common_text_field.dart';

import 'create_new_customer.vm.dart';

class CreateNewCustomerView extends StatelessWidget {
  final bool isEditMode;
  final Map<String, dynamic>? machineData;
  final VoidCallback? onCustomerCreated;
  final String? customerId;

  const CreateNewCustomerView({
    super.key,
    this.isEditMode = false,
    this.machineData,
    this.onCustomerCreated,
    this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateNewCustomerViewModel>.reactive(
      viewModelBuilder:
          () => CreateNewCustomerViewModel(
            isEditMode: isEditMode,
            machineData: machineData,
            onCustomerCreated: onCustomerCreated,
            customerId: customerId,
          )..init(),
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
    CreateNewCustomerViewModel model,
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
      title: Text(
        isEditMode
            ? LanguageService.get('edit')
            : LanguageService.get('add_new_customer'),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CreateNewCustomerViewModel model) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.white,
      child: SingleChildScrollView(
        child: Form(
          key: model.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCustomerInfoSection(context, model),
                    if (!model.isEditMode) ...[
                      const SizedBox(height: 24),
                      _buildMachineOwnershipSection(context, model),
                    ],
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
    CreateNewCustomerViewModel model,
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
        ),
        const SizedBox(height: 16),
        _buildDesignationDropdown(context, model),
        if (!model.isEditMode) ...[
          const SizedBox(height: 16),
          _buildMachineDropdown(context, model),
        ],
      ],
    );
  }

  Widget _buildPhoneField(
    BuildContext context,
    CreateNewCustomerViewModel model,
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
        PhoneInput(
          flagShape: BoxShape.rectangle,
          countrySelectorNavigator: CountrySelectorNavigator.dialog(),
          defaultCountry:
              model.countryCode.isNotEmpty
                  ? _getIsoCodeFromCountryCode(model.countryCode)
                  : IsoCode.IN,
          initialValue:
              model.isEditMode &&
                      model.displayPhoneNumber.isNotEmpty &&
                      model.countryCode.isNotEmpty
                  ? PhoneNumber(
                    isoCode: _getIsoCodeFromCountryCode(model.countryCode),
                    nsn: model.displayPhoneNumber,
                  )
                  : null,
          key: ValueKey(
            'phone_${model.isEditMode}_${model.displayPhoneNumber}_${model.countryCode}',
          ),
          onChanged: (phone) {
            if (phone != null) {
              model.updatePhoneNumber(phone);
            }
          },
          countryCodeStyle: TextStyle(color: AppColors.textGray),
          decoration: InputDecoration(
            hintText: LanguageService.get('phone_number_placeholder'),
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.white,
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 16,
            ),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (phone) {
            if (phone == null || phone.nsn.isEmpty) {
              return LanguageService.get('please_enter_phone_number');
            }
            if (phone.nsn.length < 10) {
              return LanguageService.get('please_enter_valid_phone_number');
            }
            return null;
          },
        ),
      ],
    );
  }

  IsoCode _getIsoCodeFromCountryCode(String countryCode) {
    switch (countryCode) {
      case '1':
        return IsoCode.US;
      case '91':
        return IsoCode.IN;
      case '44':
        return IsoCode.GB;
      case '61':
        return IsoCode.AU;
      case '86':
        return IsoCode.CN;
      case '81':
        return IsoCode.JP;
      case '49':
        return IsoCode.DE;
      case '33':
        return IsoCode.FR;
      case 'IN':
        return IsoCode.IN;
      case 'US':
        return IsoCode.US;
      case 'GB':
        return IsoCode.GB;
      case 'CA':
        return IsoCode.CA;
      case 'AU':
        return IsoCode.AU;
      case 'DE':
        return IsoCode.DE;
      case 'FR':
        return IsoCode.FR;
      case 'JP':
        return IsoCode.JP;
      case 'CN':
        return IsoCode.CN;
      case 'BR':
        return IsoCode.BR;
      default:
        return IsoCode.IN;
    }
  }

  Widget _buildDesignationDropdown(
    BuildContext context,
    CreateNewCustomerViewModel model,
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
                SizedBox(
                  height: 50,
                  child: DropdownFlutter<String>(
                    items: model.designationItems,
                    onChanged: (value) {
                      model.updateDesignation(value);
                      field.didChange(value);
                      field.validate();
                    },
                    initialItem: model.selectedDesignation,
                    hintText: LanguageService.get('select_designation'),
                    decoration: CustomDropdownDecoration(
                      headerStyle: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      listItemStyle: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      closedFillColor: AppColors.white,
                      closedBorder: Border.all(
                        color:
                            field.hasError
                                ? AppColors.error
                                : AppColors.lightGray,
                      ),
                      closedBorderRadius: BorderRadius.circular(12),
                      closedErrorBorder: Border.all(
                        color: AppColors.error,
                        width: 1,
                      ),
                      closedSuffixIcon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text(
                      field.errorText!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 11,
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
    CreateNewCustomerViewModel model,
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
                SizedBox(
                  height: 50,
                  child:
                      model.isLoadingMachines
                          ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.lightGray),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  LanguageService.get('loading_machines'),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : DropdownFlutter<String>(
                            items: model.machineItems,
                            onChanged: (value) {
                              model.updateMachine(value);
                              field.didChange(value);
                              field.validate();
                            },
                            initialItem: model.selectedMachine,
                            hintText:
                                model.machineItems.isEmpty
                                    ? LanguageService.get(
                                      'no_machines_available',
                                    )
                                    : LanguageService.get('select_machine'),
                            decoration: CustomDropdownDecoration(
                              headerStyle: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                              listItemStyle: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              closedFillColor: AppColors.white,
                              closedBorder: Border.all(
                                color:
                                    field.hasError
                                        ? AppColors.redBack
                                        : AppColors.lightGray,
                              ),
                              closedBorderRadius: BorderRadius.circular(12),
                              closedErrorBorder: Border.all(
                                color: AppColors.redBack,
                                width: 1,
                              ),
                              closedSuffixIcon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text(
                      field.errorText!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 11,
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
    CreateNewCustomerViewModel model,
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
              child: _buildClickableDateRow(
                AppImages.purchaseDate,
                LanguageService.get('purchase_date'),
                model.formattedPurchaseDate,
                AppColors.colorF2A22E,
                () => model.selectPurchaseDate(context),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildClickableDateRow(
                AppImages.installationDate,
                LanguageService.get('installation_date'),
                model.formattedInstallationDate,
                AppColors.colorFF6868,
                () => model.selectInstallationDate(context),
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
              child: _buildClickableDateRow(
                AppImages.warrantyDate,
                LanguageService.get('warranty_start'),
                model.formattedWarrantyStartDate,
                AppColors.primarySuperLight,
                () => model.selectWarrantyStartDate(context),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildClickableDateRow(
                AppImages.warrantyDate,
                LanguageService.get('warranty_end'),
                model.formattedWarrantyEndDate,
                AppColors.primarySuperLight,
                () => model.selectWarrantyEndDate(context),
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
              child: _buildClickableWarrantyStatusRow(
                AppImages.warrantyStatus,
                LanguageService.get('warranty_status'),
                model.warrantyStatus,
                model.warrantyStatusColor,
                () => model.toggleWarrantyStatus(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildClickableInvoiceRow(
                AppImages.invoice,
                LanguageService.get('invoice_contract_no'),
                model.invoiceContractNo.isEmpty
                    ? LanguageService.get('not_available')
                    : model.invoiceContractNo,
                AppColors.color41C293,
                () => _showInvoiceContractDialog(context, model),
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

  Widget _buildClickableDateRow(
    String iconPath,
    String label,
    String value,
    Color iconColor,
    VoidCallback onTap,
  ) {
    final bool isNotAvailable = value == LanguageService.get('not_available');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              iconPath,
              width: 20,
              height: 20,
              color: iconColor,
            ),
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
                    color:
                        isNotAvailable
                            ? AppColors.redBack
                            : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableWarrantyStatusRow(
    String iconPath,
    String label,
    String value,
    Color iconColor,
    VoidCallback onTap,
  ) {
    final bool isEmpty = value.isEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              iconPath,
              width: 20,
              height: 20,
              color: AppColors.success,
            ),
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
                    color: isEmpty ? AppColors.redBack : iconColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableInvoiceRow(
    String iconPath,
    String label,
    String value,
    Color iconColor,
    VoidCallback onTap,
  ) {
    final bool isEmpty = value == LanguageService.get('not_available');

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              iconPath,
              width: 20,
              height: 20,
              color: iconColor,
            ),
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
                    color: isEmpty ? AppColors.redBack : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInvoiceContractDialog(
    BuildContext context,
    CreateNewCustomerViewModel model,
  ) {
    final TextEditingController controller = TextEditingController(
      text: model.invoiceContractNo,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text(
            LanguageService.get('invoice_contract_no'),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonTextField(
                controller: controller,
                label: LanguageService.get('invoice_contract_no'),
                placeholder: LanguageService.get('enter_invoice_contract_no'),
              ),
            ],
          ),
          actions: [
            SizedBox(
              height: 46,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  LanguageService.get('cancel'),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  model.updateInvoiceContractNo(controller.text);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  LanguageService.get('save'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    CreateNewCustomerViewModel model,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => model.onSavePressed(context),
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
