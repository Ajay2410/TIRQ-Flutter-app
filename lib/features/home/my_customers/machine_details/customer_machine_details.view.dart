import 'package:flutter/material.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/services/customer.service.dart';
import 'package:manager/core/locator.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'customer_details/customer_edit_details.view.dart';

class CustomerMachineDetailsView extends StatefulWidget {
  final Customer customer;
  final MachineElement machineElement;

  const CustomerMachineDetailsView({super.key, required this.customer, required this.machineElement});

  @override
  State<CustomerMachineDetailsView> createState() => _CustomerMachineDetailsViewState();
}

class _CustomerMachineDetailsViewState extends State<CustomerMachineDetailsView> {
  final CustomerService _customerService = locator<CustomerService>();
  bool _isRemoving = false;

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${_getMonthName(date.month)} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Future<void> _removeMachine() async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(10),
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.redBack.withValues(alpha: 0.1)),
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.redBack),
                    child: const Center(child: Text('!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
                  ),
                ),
                const SizedBox(height: 15),

                Text(
                  'remove_machine_confirmation'.lang,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500, height: 1.3),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.darkGray,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          side: BorderSide(color: AppColors.darkGray, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('cancel'.lang, style: TextStyle(color: AppColors.darkGray, fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _isRemoving
                                ? null
                                : () {
                                  Navigator.of(context).pop(true);
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.redBack,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child:
                            _isRemoving
                                ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)),
                                )
                                : Text('remove'.lang, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.center,
                  child: Text('remove_machine_warning'.lang, style: TextStyle(color: AppColors.redBack, fontSize: 12, fontWeight: FontWeight.w400)),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldRemove != true) return;

    setState(() {
      _isRemoving = true;
    });

    try {
      final result = await _customerService.removeMachine(customerId: widget.customer.id!, machineId: widget.machineElement.machine?.id ?? '');

      result.fold(
        (failure) {
          Fluttertoast.showToast(
            msg: failure.message,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: AppColors.redBack,
            textColor: Colors.white,
          );
        },
        (updatedCustomer) {
          Fluttertoast.showToast(
            msg: 'machine_removed_successfully'.lang,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: AppColors.color41C293,
            textColor: Colors.white,
          );

          Navigator.of(context).pop(updatedCustomer);
        },
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'failed_to_remove_machine'.lang,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: AppColors.redBack,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isRemoving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
                  widget.customer.customerName ?? 'Unknown Customer',
                  style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.machineElement.machine?.machineType ?? 'customer'.lang,
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
            (widget.machineElement.machine?.machineName ?? 'Unknown Machine').toUpperCase(),
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
                      widget.machineElement.machine?.modelNumber ?? 'N/A',
                      AppColors.colorF2A22E,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.machineType,
                      'machine_type'.lang,
                      widget.machineElement.machine?.machineType ?? 'N/A',
                      AppColors.colorFF6868,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.lightGrey),
              const SizedBox(height: 14),

              Text('maximum_processing_size'.lang, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.height,
                      'height'.lang,
                      widget.machineElement.machine?.processingDimensions?.maxHeight?.toString() ?? 'N/A',
                      AppColors.color41C293,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.width,
                      'width'.lang,
                      widget.machineElement.machine?.processingDimensions?.maxWidth?.toString() ?? 'N/A',
                      AppColors.primarySuperLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.lightGrey),
              const SizedBox(height: 14),

              Text('minimum_processing_size'.lang, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.height,
                      'height'.lang,
                      widget.machineElement.machine?.processingDimensions?.minHeight?.toString() ?? 'N/A',
                      AppColors.color41C293,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.width,
                      'width'.lang,
                      widget.machineElement.machine?.processingDimensions?.minWidth?.toString() ?? 'N/A',
                      AppColors.primarySuperLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                AppImages.powerConsumption,
                'power_consumption'.lang,
                '${widget.machineElement.machine?.totalPower ?? 'N/A'} kw',
                AppColors.primarySuperLight,
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.lightGrey),
              const SizedBox(height: 14),

              Text('machine_ownership'.lang, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.purchaseDate,
                      'purchase_date'.lang,
                      _formatDate(widget.machineElement.purchaseDate),
                      AppColors.colorF2A22E,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.installationDate,
                      'installation_date'.lang,
                      _formatDate(widget.machineElement.installationDate),
                      AppColors.colorFF6868,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: AppColors.lightGrey),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.warrantyDate,
                      'warranty_start'.lang,
                      _formatDate(widget.machineElement.warrantyStart),
                      AppColors.primarySuperLight,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.warrantyDate,
                      'warranty_end'.lang,
                      _formatDate(widget.machineElement.warrantyEnd),
                      AppColors.primarySuperLight,
                      isWarning: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: AppColors.lightGrey),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.warrantyStatus,
                      'warranty_status'.lang,
                      widget.machineElement.warrantyStatus == 'In warranty' ? "In warranty" : "Out Of Warranty",
                      AppColors.color41C293,
                      isWarning: widget.machineElement.warrantyStatus != 'In warranty',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.invoice,
                      'invoice_contract_no'.lang,
                      widget.machineElement.invoiceContractNo ?? 'N/A',
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), offset: const Offset(0, -5), blurRadius: 10, spreadRadius: 0)],
      ),
      child: Row(
        children: [
          const SizedBox(width: 40),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CustomerEditDetailsView(customer: widget.customer, machineElement: widget.machineElement)),
                );

                if (result != null && result is Customer) {
                  Navigator.of(context).pop(result);
                }
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
              onPressed: _isRemoving ? null : _removeMachine,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redBack,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child:
                  _isRemoving
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                      : Text('remove'.lang, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
