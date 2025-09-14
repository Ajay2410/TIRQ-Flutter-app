import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:stacked/stacked.dart';

import '../../resources/app_resources/app_resources.dart';
import '../../services/language.service.dart';
import '../../widgets/common_text_field.dart';
import 'set_service_pricing.vm.dart';

class SetServicePricingView extends StatelessWidget {
  const SetServicePricingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SetServicePricingViewModel>.reactive(
      viewModelBuilder: () => SetServicePricingViewModel(),
      onViewModelReady: (SetServicePricingViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (
        BuildContext context,
        SetServicePricingViewModel model,
        Widget? child,
      ) {
        return Scaffold(
          appBar: _buildAppBar(context),
          bottomNavigationBar: _buildBottomSaveButton(context, model),
          body: Stack(
            children: [
              Container(
                height: Get.size.height,
                color: AppColors.snowDrift,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSizes.v16),
                        color: AppColors.almostWhite,
                        child: Column(
                          children: [
                            _buildOnlineSupportSection(
                              context,
                              model,
                              isInWarranty: true,
                            ),
                            SizedBox(height: AppSizes.v24),

                            _buildOnlineSupportSection(
                              context,
                              model,
                              isInWarranty: false,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppSizes.v15),

                      Container(
                        padding: EdgeInsets.all(AppSizes.v16),
                        color: AppColors.almostWhite,

                        child: Column(
                          children: [
                            _buildOfflineSupportSection(
                              context,
                              model,
                              warrantyStatus: 'in_warranty',
                              serviceType: 'general_checkup',
                            ),
                            SizedBox(height: AppSizes.v24),

                            _buildOfflineSupportSection(
                              context,
                              model,
                              warrantyStatus: 'in_warranty',
                              serviceType: 'full_machine_service',
                            ),
                            SizedBox(height: AppSizes.v24),

                            _buildOfflineSupportSection(
                              context,
                              model,
                              warrantyStatus: 'out_of_warranty',
                              serviceType: 'full_machine_service',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (model.isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
      title: Text(
        LanguageService.get('set_service_pricing'),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      titleSpacing: 0,
    );
  }

  Widget _buildOnlineSupportSection(
    BuildContext context,
    SetServicePricingViewModel model, {
    required bool isInWarranty,
  }) {
    final warrantyText =
        isInWarranty ? 'machine_in_warranty' : 'machine_out_of_warranty';
    final controller =
        isInWarranty
            ? model.onlineInWarrantyController
            : model.onlineOutOfWarrantyController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageService.get('online_support'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSizes.v12),
        Row(
          children: [
            Expanded(
              child: CommonTextField(
                controller: TextEditingController(
                  text: LanguageService.get(warrantyText),
                ),
                placeholder: '',
                enabled: false,
                readOnly: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.v12,
                  vertical: AppSizes.v8,
                ),
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(width: AppSizes.v12),
            Expanded(
              child: CommonTextField(
                controller: controller,
                placeholder: LanguageService.get('enter_service_cost'),
                keyboardType: TextInputType.number,
                suffixIcon: _buildCurrencyDropdown(
                  model,
                  isInWarranty ? 'onlineInWarranty' : 'onlineOutOfWarranty',
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.v12,
                  vertical: AppSizes.v8,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOfflineSupportSection(
    BuildContext context,
    SetServicePricingViewModel model, {
    required String warrantyStatus,
    required String serviceType,
  }) {
    final warrantyText =
        warrantyStatus == 'in_warranty' ? 'in_warranty' : 'out_of_warranty';
    final serviceText =
        serviceType == 'general_checkup'
            ? 'general_checkup'
            : 'full_machine_service';

    TextEditingController controller;
    if (warrantyStatus == 'in_warranty' && serviceType == 'general_checkup') {
      controller = model.offlineInWarrantyGeneralController;
    } else if (warrantyStatus == 'in_warranty' &&
        serviceType == 'full_machine_service') {
      controller = model.offlineInWarrantyFullServiceController;
    } else {
      controller = model.offlineOutOfWarrantyController;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageService.get('offline_support_site_visit'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSizes.v12),
        Row(
          children: [
            Expanded(
              child: CommonTextField(
                controller: TextEditingController(
                  text: LanguageService.get(warrantyText),
                ),
                placeholder: '',
                enabled: false,
                readOnly: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.v12,
                  vertical: AppSizes.v8,
                ),
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(width: AppSizes.v12),
            Expanded(
              child: CommonTextField(
                controller: TextEditingController(
                  text: LanguageService.get(serviceText),
                ),
                placeholder: '',
                enabled: false,
                readOnly: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.v12,
                  vertical: AppSizes.v8,
                ),
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.v12),
        CommonTextField(
          controller: controller,
          placeholder: LanguageService.get('enter_service_cost'),
          keyboardType: TextInputType.number,
          suffixIcon: _buildCurrencyDropdown(
            model,
            _getFieldType(warrantyStatus, serviceType),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.v12,
            vertical: AppSizes.v8,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown(
    SetServicePricingViewModel model,
    String fieldType,
  ) {
    return PopupMenuButton<String>(
      onSelected: (String currency) {
        model.updateCurrency(currency, fieldType);
      },
      color: AppColors.white,
      itemBuilder: (BuildContext context) => _buildCurrencyMenuItems(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.v8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getCurrencyFlag(_getCurrencyForField(model, fieldType)),
              style: TextStyle(fontSize: 20),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildCurrencyMenuItems() {
    final currencies = [
      {'code': 'USD', 'flag': '🇺🇸', 'name': 'US Dollar'},
      {'code': 'INR', 'flag': '🇮🇳', 'name': 'Indian Rupee'},
      {'code': 'CNY', 'flag': '🇨🇳', 'name': 'Chinese Yuan'},
      {'code': 'EUR', 'flag': '🇪🇺', 'name': 'Euro'},
      {'code': 'JPY', 'flag': '🇯🇵', 'name': 'Japanese Yen'},
      {'code': 'SAR', 'flag': '🇸🇦', 'name': 'Saudi Riyal'},
      {'code': 'RUB', 'flag': '🇷🇺', 'name': 'Russian Ruble'},
      {'code': 'BDT', 'flag': '🇧🇩', 'name': 'Bangladeshi Taka'},
      {'code': 'TRY', 'flag': '🇹🇷', 'name': 'Turkish Lira'},
      {'code': 'KRW', 'flag': '🇰🇷', 'name': 'South Korean Won'},
      {'code': 'VND', 'flag': '🇻🇳', 'name': 'Vietnamese Dong'},
      {'code': 'THB', 'flag': '🇹🇭', 'name': 'Thai Baht'},
      {'code': 'PLN', 'flag': '🇵🇱', 'name': 'Polish Zloty'},
      {'code': 'IDR', 'flag': '🇮🇩', 'name': 'Indonesian Rupiah'},
      {'code': 'UAH', 'flag': '🇺🇦', 'name': 'Ukrainian Hryvnia'},
    ];

    return currencies.map((currency) {
      return PopupMenuItem<String>(
        value: currency['code']!,
        child: Row(
          children: [
            Text(currency['flag']!, style: TextStyle(fontSize: 16)),
            SizedBox(width: AppSizes.v8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currency['code']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    currency['name']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getFieldType(String warrantyStatus, String serviceType) {
    if (warrantyStatus == 'in_warranty' && serviceType == 'general_checkup') {
      return 'offlineInWarrantyGeneral';
    } else if (warrantyStatus == 'in_warranty' &&
        serviceType == 'full_machine_service') {
      return 'offlineInWarrantyFullService';
    } else {
      return 'offlineOutOfWarranty';
    }
  }

  String _getCurrencyForField(
    SetServicePricingViewModel model,
    String fieldType,
  ) {
    switch (fieldType) {
      case 'onlineInWarranty':
        return model.onlineInWarrantyCurrency;
      case 'onlineOutOfWarranty':
        return model.onlineOutOfWarrantyCurrency;
      case 'offlineInWarrantyGeneral':
        return model.offlineInWarrantyGeneralCurrency;
      case 'offlineInWarrantyFullService':
        return model.offlineInWarrantyFullServiceCurrency;
      case 'offlineOutOfWarranty':
        return model.offlineOutOfWarrantyCurrency;
      default:
        return 'USD';
    }
  }

  String _getCurrencyFlag(String currencyCode) {
    final flagMap = {
      'USD': '🇺🇸',
      'INR': '🇮🇳',
      'CNY': '🇨🇳',
      'EUR': '🇪🇺',
      'JPY': '🇯🇵',
      'SAR': '🇸🇦',
      'RUB': '🇷🇺',
      'BDT': '🇧🇩',
      'TRY': '🇹🇷',
      'KRW': '🇰🇷',
      'VND': '🇻🇳',
      'THB': '🇹🇭',
      'PLN': '🇵🇱',
      'IDR': '🇮🇩',
      'UAH': '🇺🇦',
    };
    return flagMap[currencyCode] ?? '🇺🇸';
  }

  Widget _buildBottomSaveButton(
    BuildContext context,
    SetServicePricingViewModel model,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.v16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed:
            model.isSaving
                ? null
                : () {
                  model.saveServicePricing(context);
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.v50),
          ),
          padding: EdgeInsets.symmetric(vertical: AppSizes.v16),
        ),
        child:
            model.isSaving
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.v8),
                    Text(
                      LanguageService.get('saving'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                )
                : Text(
                  LanguageService.get('save_changes'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
      ),
    );
  }
}
