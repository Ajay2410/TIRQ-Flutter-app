import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/features/auth/register_organization/register_organization.vm.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../services/language.service.dart';

class RegisterOrganizationView extends StatelessWidget {
  const RegisterOrganizationView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ViewModelBuilder<RegisterOrganizationViewModel>.reactive(
      viewModelBuilder: () => RegisterOrganizationViewModel(),
      onViewModelReady: (RegisterOrganizationViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (
          BuildContext context,
          RegisterOrganizationViewModel model,
          Widget? child,
          ) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: _buildCustomAppBar(context, model),
          body: SafeArea(
            child: Center(child:SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight -
                      MediaQuery.of(context).padding.vertical -
                      kToolbarHeight, // Account for appbar height
                ),
                child: IntrinsicHeight(
                  child:Padding(
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
                  ),),),
            )),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildCustomAppBar(
      BuildContext context,
      RegisterOrganizationViewModel model,
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: AppSizes.h10),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.v10),
            child: LinearProgressIndicator(
              value: 0.5,
              backgroundColor: AppColors.lightGrey,
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
            LanguageService.get('register_organization'),
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
          //     'Manage hiring, teams, and operations seamlessly.',
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
      RegisterOrganizationViewModel model,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSizes.h20),
      padding: EdgeInsets.all(AppSizes.w20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.v16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Form(
        key: model.formKey,
        child: Column(
          children: [
            _buildTextFormField(
              context,
              controller: model.nameController,
              label: LanguageService.get('organization_name'),
              validator:
                  (value) =>
              value?.isEmpty == true
                  ? LanguageService.get('please_enter_organization_name')
                  : null,
            ),
            SizedBox(height: AppSizes.h20),
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
            // Show description field if "Others" is selected
            if (model.organizationType == "Others") ...[
              SizedBox(height: AppSizes.h20),
              _buildTextFormField(
                context,
                controller: model.otherDescriptionController,
                label: LanguageService.get('describe_your_organization'),
                validator:
                    (value) =>
                value?.isEmpty == true
                    ? LanguageService.get('please_describe_your_organization')
                    : null,
              ),
            ],
            // SizedBox(height: AppSizes.h20),
            // _buildDropdownFormField(
            //   context,
            //   value: model.language,
            //   label: "Select Language",
            //   items: AppMaps.languageMap.keys.toList(),
            //   onChanged: model.updateLanguage,
            //   validator:
            //       (value) => value == null ? "Please select a language" : null,
            // ),
            SizedBox(height: AppSizes.h20),
            _buildTextFormField(
              context,
              controller: model.emailController,
              label: LanguageService.get('email'),
              keyboardType: TextInputType.emailAddress,
              validator:
                  (value) =>
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
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.v12),
                  borderSide: BorderSide(color: AppColors.lightGrey),
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
              onFieldSubmitted:
                  (_) =>  model.onSubmitForm() ,
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
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: validator,
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
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      dropdownColor: AppColors.white,
      style: Theme.of(context).textTheme.bodyLarge,
      items: items.map((Map<String, String> item) {
        return DropdownMenuItem<String>(
          value: item['value'], // English value for backend
          child: Text(item['display']!), // Translated text for display
        );
      }).toList(),
      onChanged: onChanged,
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
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator:
          (value) =>
      value?.isEmpty == true ? LanguageService.get('please_enter_password') : null,
      onFieldSubmitted: onFieldSubmitted,
    );
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        print('Could not launch $url');
      }
    } catch (e) {
      print('Could not launch $url: $e');
      // Optionally show error to the user
    }
  }


  // Widget _buildTermsAndConditionsCheckbox(
  //     BuildContext context,
  //     RegisterOrganizationViewModel model,
  //     ) {
  //   return Row(
  //     children: [
  //       Checkbox(
  //         value: model.didAgree,
  //         onChanged: model.toggleAgree,
  //         activeColor: AppColors.white,
  //         side: BorderSide(width: 2, color: AppColors.primary), // Make border more visible
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(4.0), // Slightly rounded corners
  //         ),
  //       ),
  //       Expanded(
  //         child: RichText(
  //           textAlign: TextAlign.start,
  //           text: TextSpan(
  //               text: "${LanguageService.get('i_agree_to_the')} ",
  //             style: Theme.of(context)
  //                 .textTheme
  //                 .bodySmall
  //                 ?.copyWith(color: AppColors.textSecondary),
  //             children: [
  //               TextSpan(
  //                 text: LanguageService.get('terms_of_service'),
  //                 style: TextStyle(
  //                   color: AppColors.primary,
  //                   decoration: TextDecoration.underline,
  //                 ),
  //                 recognizer: TapGestureRecognizer()
  //                   ..onTap = () {
  //                     _openUrl('https://docs.google.com/document/d/1NzKRW98du_hHVbw0UKkoXpghbAatA7UBOFe0lT0WT1Y/edit?usp=sharing');
  //                   },
  //               ),
  //               TextSpan(text: "${LanguageService.get('and')} "),
  //               TextSpan(
  //                 text: LanguageService.get('privacy_policy'),
  //                 style: TextStyle(
  //                   color: AppColors.primary,
  //                   decoration: TextDecoration.underline,
  //                 ),
  //                 recognizer: TapGestureRecognizer()
  //                   ..onTap = () {
  //                     _openUrl('https://docs.google.com/document/d/1E4B4i0rwgledzkUIuWNxvPIGfCW-r9TPqoSeZe9JYUM/edit?usp=sharing');
  //                   },
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSubmitButton(
      BuildContext context,
      RegisterOrganizationViewModel model,
      ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed:  model.onSubmitForm,
            style: ElevatedButton.styleFrom(
              fixedSize: Size(double.infinity, AppSizes.h60),
            ),
            child:
            model.isBusy
                ?  SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
                LanguageService.get("register")
            ),
          ),
        ),
      ],
    );
  }
}