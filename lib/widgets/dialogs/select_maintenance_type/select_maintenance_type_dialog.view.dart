import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../resources/app_resources/app_resources.dart';
import '../../../services/language.service.dart';
import 'select_maintenance_type_dialog.vm.dart';

class SelectMaintenanceTypeDialog extends StatelessWidget {
  final SelectMaintenanceTypeDialogAttributes? attributes;
  final bool isWarrantyActive;

  const SelectMaintenanceTypeDialog({
    super.key,
    this.attributes,
    this.isWarrantyActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SelectMaintenanceTypeDialogViewModel>.reactive(
      viewModelBuilder:
          () =>
              SelectMaintenanceTypeDialogViewModel()
                ..init(isGeneralCheckUpDisabled: !isWarrantyActive),
      builder: (context1, model, child) {
        return Dialog(
          backgroundColor: AppColors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.v23),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.v23),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                // Header
                Container(
                  padding: EdgeInsets.all(AppSizes.v16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.v16),
                      topRight: Radius.circular(AppSizes.v16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LanguageService.get('select_maintenance_type'),
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color: AppColors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LanguageService.get(
                                'select_any_one_option_at_a_time',
                              ),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textGray),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(
                            context1,
                          ).pop(DialogResponse(confirmed: false));
                        },
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Maintenance Type Options
                _buildMaintenanceOption(
                  context,
                  model,
                  'General Check Up',
                  LanguageService.get('general_check_up'),
                  AppColors.primary,
                  isEnabled: isWarrantyActive,
                ),
                SizedBox(height: 10),
                _buildMaintenanceOption(
                  context,
                  model,
                  'Full Machine Service',
                  LanguageService.get('full_machine_service'),
                  AppColors.primary,
                  isEnabled: true,
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Padding(
                  padding: EdgeInsets.only(
                    left: AppSizes.v16,
                    right: AppSizes.v16,
                    bottom: AppSizes.v16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(
                              context1,
                            ).pop(DialogResponse(confirmed: false));
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.lightGray),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: AppSizes.h12,
                            ),
                          ),
                          child: Text(
                            LanguageService.get('cancel'),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              model.selectedType != null && !model.isLoading
                                  ? () async {
                                    await model.submit(model.selectedType!, (
                                      maintenanceType,
                                    ) async {
                                      await attributes?.onSubmit?.call(
                                        maintenanceType,
                                      );
                                    });
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                model.selectedType != null && !model.isLoading
                                    ? AppColors.primary
                                    : AppColors.lightGray,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: AppSizes.h12,
                            ),
                          ),
                          child:
                              model.isLoading
                                  ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.white,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    LanguageService.get('submit_ticket'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMaintenanceOption(
    BuildContext context,
    SelectMaintenanceTypeDialogViewModel model,
    String value,
    String label,
    Color color, {
    bool isEnabled = true,
  }) {
    final isSelected = model.selectedType == value;

    return GestureDetector(
      onTap: isEnabled ? () => model.selectType(value) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withValues(alpha: 0.1)
                  : isEnabled
                  ? AppColors.white
                  : AppColors.lightGray.withValues(alpha: 0.3),
          border: Border.all(
            color:
                isSelected
                    ? color
                    : isEnabled
                    ? AppColors.lightGray
                    : AppColors.lightGray.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: model.selectedType,
              onChanged:
                  isEnabled
                      ? (String? newValue) {
                        if (newValue != null) {
                          model.selectType(newValue);
                        }
                      }
                      : null,
              activeColor: color,
              fillColor: MaterialStateProperty.resolveWith<Color>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.selected)) {
                  return color;
                }
                return isEnabled ? AppColors.whisperGray : AppColors.lightGray;
              }),
            ),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      isSelected
                          ? color
                          : isEnabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (!isEnabled)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  LanguageService.get('out_of_warranty'),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SelectMaintenanceTypeDialogAttributes {
  final Future<void> Function(String maintenanceType)? onSubmit;
  final VoidCallback? onCancel;

  SelectMaintenanceTypeDialogAttributes({this.onSubmit, this.onCancel});
}
