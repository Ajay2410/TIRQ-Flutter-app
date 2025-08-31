import 'package:flutter/material.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';

class MachineDetailsView extends StatelessWidget {
  final Customer customer;
  final MachineElement machineElement;

  const MachineDetailsView({super.key, required this.customer, required this.machineElement});

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${_getMonthName(date.month)} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

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
        icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.colorF0F2FC),
            child: Container(
              height: 26,
              width: 26,
              decoration: const BoxDecoration(color: AppColors.bluebackground, shape: BoxShape.circle),
              child: const Center(child: Text('CR', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.customerName ?? 'Unknown Customer',
                  style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  machineElement.machine?.machineType ?? 'customer'.lang,
                  style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w400),
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
            machineElement.machine?.serialNumber ?? 'Unknown Machine',
            style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('basic_information'.lang, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.modelNumber,
                      'model_number'.lang,
                      machineElement.machine?.modelNumber ?? 'N/A',
                      AppColors.colorF2A22E,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.machineType,
                      'machine_type'.lang,
                      machineElement.machine?.machineType ?? 'N/A',
                      AppColors.colorFF6868,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.lightGray),
              const SizedBox(height: 14),

              Text('maximum_processing_size'.lang, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.height,
                      'height'.lang,
                      machineElement.machine?.processingDimensions?.maxHeight?.toString() ?? 'N/A',
                      AppColors.color41C293,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.width,
                      'width'.lang,
                      machineElement.machine?.processingDimensions?.maxWidth?.toString() ?? 'N/A',
                      AppColors.primarySuperLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.lightGray),
              const SizedBox(height: 14),

              Text('minimum_processing_size'.lang, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.height,
                      'height'.lang,
                      machineElement.machine?.processingDimensions?.minHeight?.toString() ?? 'N/A',
                      AppColors.color41C293,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.width,
                      'width'.lang,
                      machineElement.machine?.processingDimensions?.minWidth?.toString() ?? 'N/A',
                      AppColors.primarySuperLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                AppImages.powerConsumption,
                'power_consumption'.lang,
                '${machineElement.machine?.totalPower ?? 'N/A'} kw',
                AppColors.primarySuperLight,
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.lightGray),
              const SizedBox(height: 14),

              Text('machine_ownership'.lang, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.purchaseDate,
                      'purchase_date'.lang,
                      _formatDate(machineElement.purchaseDate),
                      AppColors.colorF2A22E,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.installationDate,
                      'installation_date'.lang,
                      _formatDate(machineElement.installationDate),
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
                      _formatDate(machineElement.warrantyStart),
                      AppColors.primarySuperLight,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.warrantyDate,
                      'warranty_end'.lang,
                      _formatDate(machineElement.warrantyEnd),
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
                      machineElement.warrantyStatus == 'Active' ? 'in_warranty'.lang : 'out_of_warranty'.lang,
                      AppColors.color41C293,
                      isWarning: machineElement.warrantyStatus != 'Active',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.invoice,
                      'invoice_contract_no'.lang,
                      machineElement.invoiceContractNo ?? 'N/A',
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

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), offset: const Offset(0, -5), blurRadius: 10, spreadRadius: 0)],
      ),
      child: Row(
        children: [
          const SizedBox(width: 40),
          Expanded(
            child: ElevatedButton(
              onPressed: () {

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text('edit'.lang, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 70),
          Expanded(
            child: ElevatedButton(
              onPressed: () {

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redBack,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text('remove'.lang, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
