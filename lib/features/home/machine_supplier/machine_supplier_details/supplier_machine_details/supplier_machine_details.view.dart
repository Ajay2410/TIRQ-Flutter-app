import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/core/models/machine_supplier_details_model.dart';

class SupplierMachineDetailsView extends StatefulWidget {
  final MachineElement machineElement;

  const SupplierMachineDetailsView({super.key, required this.machineElement});

  @override
  State<SupplierMachineDetailsView> createState() => _SupplierMachineDetailsViewState();
}

class _SupplierMachineDetailsViewState extends State<SupplierMachineDetailsView> {
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
                child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: _buildMachineDetails()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final machine = widget.machineElement.machine;
    final machineName = machine?.machineName ?? 'Unknown Machine';

    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Text(machineName, style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMachineDetails() {
    final machine = widget.machineElement.machine;
    final processingDimensions = machine?.processingDimensions;

    // Helper methods for data extraction
    String getMachineType() => machine?.machineType ?? 'Unknown Type';
    String getModelNumber() => machine?.modelNumber ?? 'N/A';
    String getTotalPower() => machine?.totalPower?.toString() ?? '0';
    String getWarrantyStatus() => widget.machineElement.warrantyStatus ?? 'Unknown';
    String getInvoiceContractNo() => widget.machineElement.invoiceContractNo ?? 'N/A';

    // Processing dimensions
    String getMaxHeight() => processingDimensions?.maxHeight?.toString() ?? 'N/A';
    String getMaxWidth() => processingDimensions?.maxWidth?.toString() ?? 'N/A';
    String getMinHeight() => processingDimensions?.minHeight?.toString() ?? 'N/A';
    String getMinWidth() => processingDimensions?.minWidth?.toString() ?? 'N/A';

    // Date formatting
    String formatDate(DateTime? date) {
      if (date == null) return 'N/A';
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    String getPurchaseDate() => formatDate(widget.machineElement.purchaseDate);
    String getInstallationDate() => formatDate(widget.machineElement.installationDate);
    String getWarrantyStart() => formatDate(widget.machineElement.warrantyStart);
    String getWarrantyEnd() => formatDate(widget.machineElement.warrantyEnd);

    bool isWarrantyActive() => getWarrantyStatus().toLowerCase() == 'active';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('basic_information'.lang, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildInfoCard(AppImages.modelNumber, 'model_number'.lang, getModelNumber(), AppColors.colorF2A22E)),
                  SizedBox(width: 14),
                  Expanded(child: _buildInfoCard(AppImages.machineType, 'machine_type'.lang, getMachineType(), AppColors.colorFF6868)),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.lightGray),
              const SizedBox(height: 14),

              Text('maximum_processing_size'.lang, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildInfoCard(AppImages.height, 'height'.lang, getMaxHeight(), AppColors.color41C293)),
                  SizedBox(width: 14),
                  Expanded(child: _buildInfoCard(AppImages.width, 'width'.lang, getMaxWidth(), AppColors.primarySuperLight)),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.lightGray),
              const SizedBox(height: 14),

              Text('minimum_processing_size'.lang, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildInfoCard(AppImages.height, 'height'.lang, getMinHeight(), AppColors.color41C293)),
                  SizedBox(width: 14),
                  Expanded(child: _buildInfoCard(AppImages.width, 'width'.lang, getMinWidth(), AppColors.primarySuperLight)),
                ],
              ),

              const SizedBox(height: 14),
              Divider(color: AppColors.lightGray),
              const SizedBox(height: 14),
              Text('power_information'.lang, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildInfoCard(AppImages.powerConsumption, 'power_consumption'.lang, '${getTotalPower()} kw', AppColors.primarySuperLight),
              const SizedBox(height: 14),
              Divider(color: AppColors.lightGray),
              const SizedBox(height: 14),

              Text('machine_ownership'.lang, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildInfoRow(AppImages.purchaseDate, 'purchase_date'.lang, getPurchaseDate(), AppColors.colorF2A22E)),
                  SizedBox(width: 14),
                  Expanded(child: _buildInfoRow(AppImages.installationDate, 'installation_date'.lang, getInstallationDate(), AppColors.colorFF6868)),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: AppColors.lightGray),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildInfoRow(AppImages.warrantyDate, 'warranty_start'.lang, getWarrantyStart(), AppColors.primarySuperLight)),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoRow(AppImages.warrantyDate, 'warranty_end'.lang, getWarrantyEnd(), AppColors.primarySuperLight, isWarning: true),
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
                      isWarrantyActive() ? 'in_warranty'.lang : 'out_of_warranty'.lang,
                      AppColors.color41C293,
                      isWarning: !isWarrantyActive(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInfoRow(AppImages.invoice, 'invoice_contract_no'.lang, getInvoiceContractNo(), AppColors.color41C293)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String iconPath, String label, String value, Color iconColor, {bool isWarning = false}) {
    return Row(
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
              Text(value, style: TextStyle(color: isWarning ? AppColors.redBack : AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String iconPath, String label, String value, Color iconColor) {
    return _buildInfoRow(iconPath, label, value, iconColor);
  }
}
