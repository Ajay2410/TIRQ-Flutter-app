import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/widgets/common_text_field.dart';
import 'package:manager/core/models/customer.dart';

import 'customer_edit_details.vm.dart';

class CustomerEditDetailsView extends StatelessWidget {
  final Customer customer;
  final MachineElement? machineElement;

  const CustomerEditDetailsView({super.key, required this.customer, this.machineElement});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CustomerEditDetailsViewModel>.reactive(
      viewModelBuilder: () => CustomerEditDetailsViewModel(customer: customer)..init(machineElement: machineElement),
      builder: (context, model, child) {
        return Scaffold(appBar: _buildAppBar(context, model), body: _buildBody(context, model));
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, CustomerEditDetailsViewModel model) {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryLight, AppColors.primaryDark],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            stops: [0.08, 1],
          ),
        ),
      ),
      leading: IconButton(
        icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.colorF0F2FC),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 26,
                  width: 26,
                  decoration: BoxDecoration(color: AppColors.bluebackground, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      customer.customerName?.substring(0, 2).toUpperCase() ?? 'NA',
                      style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: ClipRRect(borderRadius: BorderRadius.circular(2), child: AppImages.getSvgFlag(customer.flag ?? "", width: 14, height: 14)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(customer.customerName ?? 'Unknown Customer', style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
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
                  children: [_buildCustomerInfoSection(context, model), const SizedBox(height: 24), _buildMachineOwnershipSection(context, model)],
                ),
              ),
              Padding(padding: const EdgeInsets.all(16), child: _buildSaveButton(context, model)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfoSection(BuildContext context, CustomerEditDetailsViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonTextField(
          controller: model.contactPersonController,
          label: LanguageService.get('contact_person'),
          placeholder: LanguageService.get('person_name'),
          validator: CommonValidators.required(LanguageService.get('please_enter_contact_person')),
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
          validator: CommonValidators.email(LanguageService.get('please_enter_valid_email')),
          enabled: false,
          readOnly: true,
        ),
        const SizedBox(height: 16),

        CommonTextField(
          controller: model.designationController,
          label: LanguageService.get('designation'),
          placeholder: LanguageService.get('designation_placeholder'),
          validator: CommonValidators.required(LanguageService.get('please_enter_designation')),
          enabled: false,
          readOnly: true,
        ),
        const SizedBox(height: 16),

        if (machineElement != null) ...{
          CommonTextField(
            controller: TextEditingController(text: machineElement?.machine?.machineName ?? ""),
            label: LanguageService.get('assign_machine'),
            placeholder: LanguageService.get('please_select_machine'),
            validator: CommonValidators.required(LanguageService.get('please_enter_designation')),
            enabled: false,
            readOnly: true,
          ),
        } else ...{
          _buildMachineDropdown(context, model),
        },
      ],
    );
  }

  Widget _buildPhoneField(BuildContext context, CustomerEditDetailsViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LanguageService.get('phone_number'), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
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
            initialCountryCode: model.initialCountryCode,
            onChanged: (phone) {
              model.updatePhoneNumber(phone);
            },
            readOnly: true,
            decoration: InputDecoration(
              hintText: LanguageService.get('phone_number_placeholder'),
              hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              filled: true,
              fillColor: AppColors.colorF8FBFE,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lightGray)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lightGray)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  Widget _buildMachineDropdown(BuildContext context, CustomerEditDetailsViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LanguageService.get('assign_machine'), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
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
                            decoration: BoxDecoration(border: Border.all(color: AppColors.lightGray), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
                                ),
                                const SizedBox(width: 12),
                                Text(LanguageService.get('loading_machines'), style: const TextStyle(color: AppColors.textSecondary)),
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
                                model.machineItems.isEmpty ? LanguageService.get('no_machines_available') : LanguageService.get('select_machine'),
                            decoration: CustomDropdownDecoration(
                              headerStyle: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                              listItemStyle: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                              hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                              closedFillColor: AppColors.white,
                              closedBorder: Border.all(color: field.hasError ? AppColors.redBack : AppColors.lightGray),
                              closedBorderRadius: BorderRadius.circular(12),
                              closedErrorBorder: Border.all(color: AppColors.redBack, width: 1),
                              closedSuffixIcon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                            ),
                          ),
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text(field.errorText!, style: const TextStyle(color: AppColors.error, fontSize: 11)),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMachineOwnershipSection(BuildContext context, CustomerEditDetailsViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageService.get('machine_ownership'),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
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
                model.invoiceContractNo.isEmpty ? LanguageService.get('not_available') : model.invoiceContractNo,
                AppColors.color41C293,
                () => _showInvoiceContractDialog(context, model),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClickableDateRow(String iconPath, String label, String value, Color iconColor, VoidCallback onTap) {
    final bool isNotAvailable = value == LanguageService.get('not_available');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Image.asset(iconPath, width: 20, height: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(color: isNotAvailable ? AppColors.redBack : AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableWarrantyStatusRow(String iconPath, String label, String value, Color iconColor, VoidCallback onTap) {
    final bool isEmpty = value.isEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Image.asset(iconPath, width: 20, height: 20, color: AppColors.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: isEmpty ? AppColors.redBack : iconColor, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableInvoiceRow(String iconPath, String label, String value, Color iconColor, VoidCallback onTap) {
    final bool isEmpty = value == LanguageService.get('not_available');

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Image.asset(iconPath, width: 20, height: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: isEmpty ? AppColors.redBack : AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInvoiceContractDialog(BuildContext context, CustomerEditDetailsViewModel model) {
    final TextEditingController controller = TextEditingController(text: model.invoiceContractNo);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text(
            LanguageService.get('invoice_contract_no'),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
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
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w500),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(LanguageService.get('save'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }

  Widget _buildSaveButton(BuildContext context, CustomerEditDetailsViewModel model) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => model.onSavePressed(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
          elevation: 5,
        ),
        child:
            model.isBusy
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)),
                )
                : Text(LanguageService.get('save'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
