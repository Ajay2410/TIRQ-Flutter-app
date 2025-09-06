import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'supplier_machine_details/supplier_machine_details.view.dart';

class MachineSupplierDetailsView extends StatefulWidget {
  const MachineSupplierDetailsView({super.key});

  @override
  State<MachineSupplierDetailsView> createState() =>
      _MachineSupplierDetailsViewState();
}

class _MachineSupplierDetailsViewState
    extends State<MachineSupplierDetailsView> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  // Dummy data
  final String _customerName = 'Machine Supplier 1';
  final String _contactPerson = 'John Smith';
  final String _email = 'john.smith@example.com';
  final String _designation = 'Technical Manager';
  final String _phoneNumber = '+1 234 567 8900';
  final List<Map<String, dynamic>> _machines = [
    {
      'name': 'Machine 1',
      'modelNumber': '4777',
      'machineType': 'Semi Automatic',
      'warrantyStatus': 'Active',
      'country': 'USA',
    },
    {
      'name': 'Machine 2',
      'modelNumber': '4778',
      'machineType': 'Fully Automatic',
      'warrantyStatus': 'Inactive',
      'country': 'Germany',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
        _customerName,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContactInfoRow('contact_person'.lang, _contactPerson),
                const SizedBox(height: 12),
                _buildContactInfoRow('email'.lang, _email),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContactInfoRow('designation'.lang, _designation),
                const SizedBox(height: 12),
                _buildContactInfoRow('phone'.lang, _phoneNumber),
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
    if (_machines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppImages.myCustomers,
              width: 80,
              height: 80,
              color: AppColors.gray,
            ),
            const SizedBox(height: 20),
            Text(
              'no_machines_assigned'.lang,
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'this_customer_has_no_machines'.lang,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children:
          _machines
              .map((machineData) => _buildMachineCard(context, machineData))
              .toList(),
    );
  }

  Widget _buildMachineCard(
    BuildContext context,
    Map<String, dynamic> machineData,
  ) {
    final machineName = machineData['name'] ?? 'Unknown Machine';
    final modelNumber = machineData['modelNumber'] ?? 'N/A';
    final machineType = machineData['machineType'] ?? 'Unknown Type';
    final isInWarranty = machineData['warrantyStatus'] == 'Active';

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
                  machineName.substring(0, 2).toUpperCase() ?? 'NA',
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
                  machineName,
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
                      isInWarranty
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.redBack.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isInWarranty ? 'in_warranty'.lang : 'out_of_warranty'.lang,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isInWarranty ? AppColors.success : AppColors.redBack,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SupplierMachineDetailsView(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
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
                child: _buildMachineInfoRow('model_number'.lang, modelNumber),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildMachineInfoRow('machine_type'.lang, machineType),
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
}
