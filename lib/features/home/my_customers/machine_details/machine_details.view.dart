import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';

class MachineDetailsView extends StatelessWidget {
  final Map<String, dynamic> machine;

  const MachineDetailsView({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Container(
                color: AppColors.scaffoldBackground,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildMachineDetails(),
                ),
              ),
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.colorF0F2FC,
                ),
                child: Container(
                  height: 26,
                  width: 26,
                  decoration: const BoxDecoration(
                    color: AppColors.bluebackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
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
              Positioned(
                bottom: -4,
                right: -4,
                child: Image.asset(AppImages.flag, width: 17, height: 17),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  machine['customerName'] ?? 'Leslie Alexander',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  machine['machineType'] ?? 'glass_processor'.lang,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text(
            machine['model'] ?? 'DEF-MODEL-DEF',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMachineDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'basic_information'.lang,
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
                      AppImages.modelNumber,
                      'model_number'.lang,
                      machine['modelNumber'] ?? 'DEF',
                      AppColors.colorF2A22E,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.machineType,
                      'machine_type'.lang,
                      machine['machineType'] ?? 'fully_automatic'.lang,
                      AppColors.colorFF6868,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.lightGray),
              const SizedBox(height: 14),

              Text(
                'maximum_processing_size'.lang,
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
                      AppImages.height,
                      'height'.lang,
                      machine['maxHeight'] ?? '1.0',
                      AppColors.color41C293,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.width,
                      'width'.lang,
                      machine['maxWidth'] ?? '1.0',
                      AppColors.primarySuperLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.lightGray),
              const SizedBox(height: 14),


              Text(
                'minimum_processing_size'.lang,
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
                      AppImages.height,
                      'height'.lang,
                      machine['maxHeight'] ?? '1.0',
                      AppColors.color41C293,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.width,
                      'width'.lang,
                      machine['maxWidth'] ?? '1.0',
                      AppColors.primarySuperLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.lightGray),
              const SizedBox(height: 14),

              Text(
                'power_information'.lang,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildInfoRow(
                AppImages.powerConsumption,
                'power_consumption'.lang,
                machine['powerConsumption'] ?? '11.0 kw',
                AppColors.primarySuperLight,
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.lightGray),
              const SizedBox(height: 14),

              Text(
                'machine_ownership'.lang,
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
                      'purchase_date'.lang,
                      machine['purchaseDate'] ?? 'Jul 01, 2025',
                      AppColors.colorF2A22E,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.installationDate,
                      'installation_date'.lang,
                      machine['installationDate'] ?? 'Jul 01, 2025',
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
                      'warranty_start'.lang,
                      machine['warrantyStart'] ?? 'Jul 01, 2025',
                      AppColors.primarySuperLight,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.warrantyDate,
                      'warranty_end'.lang,
                      machine['warrantyEnd'] ?? 'Jul 01, 2025',
                      AppColors.primarySuperLight,
                      isWarning: true,
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
                      'warranty_status'.lang,
                      machine['isInWarranty'] == true
                          ? 'in_warranty'.lang
                          : 'out_of_warranty'.lang,
                      AppColors.color41C293,
                      isWarning: machine['isInWarranty'] != true,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.invoice,
                      'invoice_contract_no'.lang,
                      machine['invoiceNumber'] ?? '999',
                      AppColors.color41C293,
                    ),
                  ),
                ],
              ),
            ],
          ),
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

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -5),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 40),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: Handle edit action - navigate to appropriate edit screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'edit'.lang,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 70),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Handle delete action here
                // You can add your delete logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redBack,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'remove'.lang,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
