import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:manager/features/auth/register/register.vm.dart';
import 'package:stacked/stacked.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../services/language.service.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ViewModelBuilder<RegisterViewModel>.reactive(
      viewModelBuilder: () => RegisterViewModel(),
      onViewModelReady: (RegisterViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (
          BuildContext context,
          RegisterViewModel model,
          Widget? child,
          ) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight -
                        MediaQuery.of(context).padding.vertical -
                        kToolbarHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.w13),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: AppSizes.h12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start, // This moves items to the top
                            children: [
                              _buildBackButton(context),
                              _buildHeaderSection(context, model),
                            ],
                          ),
                          Column(
                            children: [
                              _buildTabSelection(context, model),
                              _buildRegistrationForm(context, model),
                              _buildSignInLink(context),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(BuildContext context, RegisterViewModel model) {
    return
      Column(
        children: [
          SizedBox(
            height:  model.isOrganization ? 240 : 220,
            width: 250,
            child: Image.asset(
              model.isOrganization ? 'assets/images/auth2.png' : 'assets/images/auth3.png',
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: AppSizes.h2),
        ],
      );
  }

  Widget _buildTabSelection(BuildContext context, RegisterViewModel model) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h15, top : AppSizes.h10),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppSizes.v45),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => model.setRegistrationType(true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: AppSizes.h14),
                decoration: BoxDecoration(
                  color: model.isOrganization ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.v45),
                    bottomLeft: Radius.circular(AppSizes.v45),
                  ),

                ),
                child: Text(
                  LanguageService.get('sign_up_as_organization'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: model.isOrganization ? AppColors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => model.setRegistrationType(false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: AppSizes.h12),
                decoration: BoxDecoration(
                  color: !model.isOrganization ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(AppSizes.v45),
                    bottomRight: Radius.circular(AppSizes.v45),
                  ),

                ),
                child: Text(
                  LanguageService.get('sign_up_as_employee'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: !model.isOrganization ? AppColors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                      fontSize: 13
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm(
      BuildContext context,
      RegisterViewModel model,
      ) {
    return Container(
      child: Form(
        key: model.formKey,
        child: Column(
          children: [
            _buildTextFormField(
              context,
              controller: model.nameController,
              label: model.isOrganization
                  ? LanguageService.get('organization_name')
                  : LanguageService.get('your_name'),
              validator: (value) => value?.isEmpty == true
                  ? (model.isOrganization
                  ? LanguageService.get('please_enter_organization_name')
                  : LanguageService.get('please_enter_name'))
                  : null,
            ),

            // Organization type dropdown (only for organization)
            if (model.isOrganization) ...[
              SizedBox(height: AppSizes.h13),
              _buildDropdownFormField(
                context,
                value: model.organizationType,
                label: LanguageService.get('organization_type'),
                items: [
                  {"value": "Machine Manufacturer", "display": LanguageService.get('machine_manufacturer')},
                  {"value": "Glass Processor", "display": LanguageService.get('glass_processor')},
                  {"value": "Aluminum Processor", "display": LanguageService.get('aluminum_processor')},
                  {"value": "UPVC Processor", "display": LanguageService.get('upvc_processor')},
                  {"value": "Others", "display": LanguageService.get('others')},
                ],
                onChanged: model.updateOrganizationType,
                validator: (value) => value == null ? LanguageService.get('please_select_organization_type') : null,
              ),

              // Other description field (only if "Others" is selected)
              if (model.organizationType == "Others") ...[
                SizedBox(height: AppSizes.h13),
                _buildTextFormField(
                  context,
                  controller: model.otherDescriptionController,
                  label: LanguageService.get('describe_your_organization'),
                  validator: (value) => value?.isEmpty == true
                      ? LanguageService.get('please_describe_your_organization')
                      : null,
                ),
              ],
            ],

            SizedBox(height: AppSizes.h13),
            _buildTextFormField(
              context,
              controller: model.emailController,
              label: LanguageService.get('email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value?.isEmpty == true
                  ? LanguageService.get('please_enter_email')
                  : null,
            ),

            SizedBox(height: AppSizes.h13),
            SizedBox(
              height: 60,
              child: IntlPhoneField(
                controller: model.phoneController,
                pickerDialogStyle: PickerDialogStyle(
                  backgroundColor: AppColors.white,
                  countryCodeStyle: TextStyle(color: AppColors.black),
                  countryNameStyle: TextStyle(color: AppColors.black),
                ),
                decoration: InputDecoration(
                  labelText: LanguageService.get('phone_number'),
                  labelStyle: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.v13),
                    borderSide: BorderSide(color: AppColors.lightGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.v13),
                    borderSide: BorderSide(color: AppColors.lightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.v13),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                initialCountryCode: 'IN',
                onChanged: (phone) {
                  model.updatePhoneNumber(phone);
                },
                validator: (phone) {
                  if (phone == null || phone.number.isEmpty) {
                    return LanguageService.get('please_enter_phone_number');
                  }
                  return null;
                },
              ),
            ),

            SizedBox(height: AppSizes.h5),
            _buildPasswordFormField(
              context,
              controller: model.passwordController,
              obscureText: model.obscurePassword,
              onToggleVisibility: model.togglePassword,
              onFieldSubmitted: (_) => model.onSubmitForm(),
            ),

            SizedBox(height: AppSizes.h15),
            _buildSubmitButton(context, model),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return SizedBox(
      height: 46,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.textGrey,
            fontSize: 13,
          ),
          floatingLabelStyle: TextStyle(
            color: AppColors.textGrey,
            fontSize: 13,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: AppColors.lightGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: AppColors.lightGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownFormField(
      BuildContext context, {
        required String? value,
        required String label,
        required List<Map<String, String>> items,
        required void Function(String?)? onChanged,
        String? Function(String?)? validator,
      }) {
    return SizedBox(
      height: 50,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.textGrey,
            fontSize: 13,
          ),
          floatingLabelStyle: TextStyle(
            color: AppColors.textGrey,
            fontSize: 14,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: AppColors.lightGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: AppColors.lightGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
        ),
        dropdownColor: AppColors.white,
        style: Theme.of(context).textTheme.bodyLarge,
        items: items.map((Map<String, String> item) {
          return DropdownMenuItem<String>(
            value: item['value'],
            child: Text(item['display']!),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }


  Widget _buildPasswordFormField(
      BuildContext context, {
        required TextEditingController controller,
        required bool obscureText,
        required VoidCallback onToggleVisibility,
        void Function(String)? onFieldSubmitted,
      }) {
    return SizedBox(
      height: 46,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: LanguageService.get('password'),
          labelStyle: TextStyle(
            color: AppColors.textGrey,
            fontSize: 13,
          ),
          floatingLabelStyle: TextStyle(
            color: AppColors.textGrey,
            fontSize: 14,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: AppColors.gray,
            ),
            onPressed: onToggleVisibility,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: AppColors.lightGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: AppColors.lightGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
        ),
        validator: (value) => value?.isEmpty == true
            ? LanguageService.get('please_enter_password')
            : null,
        onFieldSubmitted: onFieldSubmitted,
      ),
    );
  }

  Widget _buildSubmitButton(
      BuildContext context,
      RegisterViewModel model,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: model.onSubmitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 4,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: model.isBusy
            ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: AppColors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          LanguageService.get("continue"),
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
  Widget _buildSignInLink(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.h15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            LanguageService.get('already_have_account'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: AppSizes.w8),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Text(
              LanguageService.get('sign_in'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildBackButton(BuildContext context) {
  return Align(
    alignment: Alignment.topLeft,
    child: Container(
      margin: EdgeInsets.only(top: 5),// Add margin for proper spacing
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background
        shape: BoxShape.circle, // Makes it circular
      ),
      child: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(
          Icons.arrow_back,
          color: AppColors.textPrimary,
          size: 24,
        ),
        // Adjust padding for better circle appearance
      ),
    ),
  );
}