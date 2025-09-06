import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';

class SupplierMachineDetailsView extends StatefulWidget {
  const SupplierMachineDetailsView({super.key});

  @override
  State<SupplierMachineDetailsView> createState() =>
      _SupplierMachineDetailsViewState();
}

class _SupplierMachineDetailsViewState
    extends State<SupplierMachineDetailsView> {
  // Dummy data
  final String _machineName = 'Machine 1';
  final String _machineType = 'Semi Automatic';
  final String _modelNumber = '4777';
  final String _maxHeight = '25';
  final String _maxWidth = '52';
  final String _minHeight = '8';
  final String _minWidth = '5';
  final String _totalPower = '88';
  final String _purchaseDate = 'Jan 15, 2024';
  final String _installationDate = 'Feb 01, 2024';
  final String _warrantyStart = 'Feb 01, 2024';
  final String _warrantyEnd = 'Feb 01, 2025';
  final String _warrantyStatus = 'Active';
  final String _invoiceContractNo = 'INV-2024-001';

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
      title: Text(
        _machineName,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
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
                    child: _buildInfoCard(
                      AppImages.modelNumber,
                      'model_number'.lang,
                      _modelNumber,
                      AppColors.colorF2A22E,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.machineType,
                      'machine_type'.lang,
                      _machineType,
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
                    child: _buildInfoCard(
                      AppImages.height,
                      'height'.lang,
                      _maxHeight,
                      AppColors.color41C293,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.width,
                      'width'.lang,
                      _maxWidth,
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
                    child: _buildInfoCard(
                      AppImages.height,
                      'height'.lang,
                      _minHeight,
                      AppColors.color41C293,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.width,
                      'width'.lang,
                      _minWidth,
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
              _buildInfoCard(
                AppImages.powerConsumption,
                'power_consumption'.lang,
                '$_totalPower kw',
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
                      _purchaseDate,
                      AppColors.colorF2A22E,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.installationDate,
                      'installation_date'.lang,
                      _installationDate,
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
                      _warrantyStart,
                      AppColors.primarySuperLight,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.warrantyDate,
                      'warranty_end'.lang,
                      _warrantyEnd,
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
                      _warrantyStatus == 'Active'
                          ? 'in_warranty'.lang
                          : 'out_of_warranty'.lang,
                      AppColors.color41C293,
                      isWarning: _warrantyStatus != 'Active',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.invoice,
                      'invoice_contract_no'.lang,
                      _invoiceContractNo,
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

  Widget _buildInfoCard(
    String iconPath,
    String label,
    String value,
    Color iconColor,
  ) {
    return _buildInfoRow(iconPath, label, value, iconColor);
  }
}
