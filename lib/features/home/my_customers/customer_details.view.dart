import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/features/home/my_customers/machine_details/machine_details.view.dart';

class CustomerDetailsView extends StatelessWidget {
  const CustomerDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Container(
                color: AppColors.white,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: _buildCustomerContactCard(),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        color: AppColors.scaffoldBackground,
                        padding: const EdgeInsets.all(12),
                        child: SingleChildScrollView(
                          child: _buildMachineList(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
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
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.colorF0F2FC,
            ),
            child: Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                color: AppColors.bluebackground,
                shape: BoxShape.circle,
              ),
              child: Center(
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leslie Alexander',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'glass_processor'.lang,
                  style: TextStyle(
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
        PopupMenuButton<String>(
          menuPadding: EdgeInsets.zero,
          offset: const Offset(-10, 30),
          onSelected: (String value) {
            if (value == 'delete') {
              // Handle delete action
              _showDeleteConfirmation(context);
            }
          },
          itemBuilder:
              (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'delete'.lang,
                      style: const TextStyle(
                        color: AppColors.redBack,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppColors.white,
          shadowColor: AppColors.black.withValues(alpha: 0.1),
          child: const Icon(Icons.more_vert, color: AppColors.white, size: 24),
        ),
      ],
    );
  }

  Widget _buildCustomerContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.colorF0F2FC,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContactInfoRow(
                  'contact_person'.lang,
                  'not_available'.lang,
                ),
                const SizedBox(height: 12),
                _buildContactInfoRow('email'.lang, 'delta@gmail.com'),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContactInfoRow('designation'.lang, 'not_available'.lang),
                const SizedBox(height: 12),
                _buildContactInfoRow('phone'.lang, '+91 123 4346 568'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMachineList(BuildContext context) {
    final machines = [
      {
        'country': 'US',
        'model': 'DEF-MODEL-DEF',
        'modelNumber': 'DEF',
        'machineType': 'fully_automatic'.lang,
        'isInWarranty': false,
      },
      {
        'country': 'US',
        'model': 'DEF-MODEL-DEF',
        'modelNumber': 'DEF',
        'machineType': 'fully_automatic'.lang,
        'isInWarranty': true,
      },
      {
        'country': 'US',
        'model': 'DEF-MODEL-DEF',
        'modelNumber': 'DEF',
        'machineType': 'fully_automatic'.lang,
        'isInWarranty': true,
      },
      {
        'country': 'US',
        'model': 'DEF-MODEL-DEF',
        'modelNumber': 'DEF',
        'machineType': 'fully_automatic'.lang,
        'isInWarranty': true,
      },
      {
        'country': 'US',
        'model': 'DEF-MODEL-DEF',
        'modelNumber': 'DEF',
        'machineType': 'fully_automatic'.lang,
        'isInWarranty': false,
      },
      {
        'country': 'US',
        'model': 'DEF-MODEL-DEF',
        'modelNumber': 'DEF',
        'machineType': 'fully_automatic'.lang,
        'isInWarranty': true,
      },
      {
        'country': 'US',
        'model': 'DEF-MODEL-DEF',
        'modelNumber': 'DEF',
        'machineType': 'fully_automatic'.lang,
        'isInWarranty': true,
      },
      {
        'country': 'US',
        'model': 'DEF-MODEL-DEF',
        'modelNumber': 'DEF',
        'machineType': 'fully_automatic'.lang,
        'isInWarranty': true,
      },
    ];

    return Column(
      children:
          machines
              .map((machine) => _buildMachineCard(context, machine))
              .toList(),
    );
  }

  Widget _buildMachineCard(BuildContext context, Map<String, dynamic> machine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.colorF0F2FC,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  machine['country'],
                  style: TextStyle(
                    color: AppColors.colorBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  machine['model'],
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color:
                      machine['isInWarranty']
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.redBack.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  machine['isInWarranty']
                      ? 'in_warranty'.lang
                      : 'out_of_warranty'.lang,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        machine['isInWarranty']
                            ? AppColors.success
                            : AppColors.redBack,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => MachineDetailsView(
                            machine: {
                              'customerName': 'Leslie Alexander',
                              'machineType': 'glass_processor'.lang,
                              'model': machine['model'],
                              'modelNumber': machine['modelNumber'],
                              'machineType': machine['machineType'],
                              'maxHeight': '1.0',
                              'maxWidth': '1.0',
                              'minHeight': '1.0',
                              'minWidth': '1.0',
                              'powerConsumption': '11.0 kw',
                              'purchaseDate': 'Jul 01, 2025',
                              'installationDate': 'Jul 01, 2025',
                              'warrantyStart': 'Jul 01, 2025',
                              'warrantyEnd': 'Jul 01, 2025',
                              'isInWarranty': machine['isInWarranty'],
                              'invoiceNumber': '999',
                            },
                          ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.softGray,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.textGray.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Image.asset(
                    AppImages.arrowRight,
                    width: 16,
                    height: 16,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.lightGray),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMachineInfoRow(
                  'model_number'.lang,
                  machine['modelNumber'],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildMachineInfoRow(
                  'machine_type'.lang,
                  machine['machineType'],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMachineInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {},
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      icon: const Icon(Icons.add, size: 20),
      label: Text(
        'assign_new_machine'.lang,
        style: TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(10),
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.redBack.withValues(alpha: 0.1),
                  ),
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.redBack,
                    ),
                    child: const Center(
                      child: Text(
                        '!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Main Question Text
                Text(
                  'are_you_sure_remove_customer'.lang,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.darkGray,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          side: BorderSide(
                            color: AppColors.darkGray,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(45),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'cancel'.lang,
                          style: TextStyle(
                            color: AppColors.darkGray,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Remove Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
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
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Warning Message
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'remove_customer_warning'.lang,
                    style: TextStyle(
                      color: AppColors.redBack,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
