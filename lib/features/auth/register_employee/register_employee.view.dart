import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:manager/features/auth/register_employee/register_employee.vm.dart';
import 'package:stacked/stacked.dart';

import '../../../resources/app_resources/app_resources.dart';
import '../../../services/language.service.dart';

class RegisterEmployeeView extends StatelessWidget {
  const RegisterEmployeeView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ViewModelBuilder<RegisterEmployeeViewModel>.reactive(
      viewModelBuilder: () => RegisterEmployeeViewModel(),
      onViewModelReady: (RegisterEmployeeViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (
          BuildContext context,
          RegisterEmployeeViewModel model,
          Widget? child,
          ) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: _buildCustomAppBar(context, model),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight -
                        MediaQuery.of(context).padding.vertical -
                        kToolbarHeight, // Account for appbar height
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.w20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Header Section
                          _buildHeaderSection(context),

                          // Registration Form
                          _buildRegistrationForm(context, model),
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

  PreferredSizeWidget _buildCustomAppBar(
      BuildContext context,
      RegisterEmployeeViewModel model,
      ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageService.get('step_1_of_2'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.h10),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.v10),
            child: LinearProgressIndicator(
              value: 0.5,
              backgroundColor: AppColors.lightGray,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: AppSizes.h6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.h20),
      child: Column(
        children: [
          Text(
           LanguageService.get('register_yourself'),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.h10),
          // Padding(
          //   padding: EdgeInsets.symmetric(horizontal: AppSizes.w20),
          //   child: Text(
          //     LanguageService.get('register_employee_description'),
          //     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          //       color: AppColors.textSecondary,
          //       fontWeight: FontWeight.w500,
          //     ),
          //     textAlign: TextAlign.center,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm(
      BuildContext context,
      RegisterEmployeeViewModel model,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSizes.h20),
      padding: EdgeInsets.all(AppSizes.w20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.v16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha:0.05),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Form(
        key: model.formKey,
        child: Column(
          children: [
            _buildTextFormField(
              context,
              controller: model.nameController,
              label: LanguageService.get('your_name'),
              validator: (value) =>
              value?.isEmpty == true ? LanguageService.get('please_enter_name') : null,
            ),
            SizedBox(height: AppSizes.h20),
            _buildTextFormField(
              context,
              controller: model.emailController,
              label: LanguageService.get('email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
              value?.isEmpty == true ? LanguageService.get('please_enter_email') : null,
            ),
            SizedBox(height: AppSizes.h20),
            IntlPhoneField(
              controller: model.phoneController,
              pickerDialogStyle: PickerDialogStyle(
                  backgroundColor: AppColors.white,
                  countryCodeStyle: TextStyle(color: AppColors.black),
                  countryNameStyle: TextStyle(color: AppColors.black)
              ),
              decoration: InputDecoration(
                labelText: LanguageService.get('phone_number'),
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
              initialCountryCode: 'IN', // Set initial country code
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
            SizedBox(height: AppSizes.h20),
            _buildPasswordFormField(
              context,
              controller: model.passwordController,
              obscureText: model.obscurePassword,
              onToggleVisibility: model.togglePassword,
              onFieldSubmitted: (_) =>
              model.isFormValid ? model.onSubmitForm() : null,
            ),
            SizedBox(height: AppSizes.h20),
            // _buildTermsAndConditionsCheckbox(context, model),
            // SizedBox(height: AppSizes.h20),
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
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
      validator: validator,
    );
  }

  Widget _buildPasswordFormField(
      BuildContext context, {
        required TextEditingController controller,
        required bool obscureText,
        required VoidCallback onToggleVisibility,
        void Function(String)? onFieldSubmitted,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: LanguageService.get('password'),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppColors.gray,
          ),
          onPressed: onToggleVisibility,
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
      value?.isEmpty == true ? LanguageService.get('please_enter_password') : null,
      onFieldSubmitted: onFieldSubmitted,
    );
  }

  Widget _buildTermsAndConditionsCheckbox(
      BuildContext context,
      RegisterEmployeeViewModel model,
      ) {
    return Row(
      children: [
        Checkbox(
          value: model.didAgree,
          onChanged: model.toggleAgree,
          activeColor: AppColors.white,
          side: BorderSide(width: 2, color: AppColors.primary), // Make border more visible
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0), // Slightly rounded corners
          ),
        ),
        // Checkbox(
        //   value: model.didAgree,
        //   onChanged: model.toggleAgree,
        // ),
        Expanded(
          child: RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              text: LanguageService.get('i_agree_to_the'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: LanguageService.get('terms_of_service'),
                  style: TextStyle(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: LanguageService.get('and')),
                TextSpan(
                  text: LanguageService.get('privacy_policy'),
                  style: TextStyle(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
      BuildContext context,
      RegisterEmployeeViewModel model,
      ) {
    return ElevatedButton(
      onPressed: model.didAgree ? model.onSubmitForm : null,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, AppSizes.h50),
      ),
      child: model.isBusy
          ?  SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: AppColors.white,
          strokeWidth: 2,
        ),
      )
          : Text(LanguageService.get("register")),
    );
  }
}