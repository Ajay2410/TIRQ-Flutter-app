import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/features/home/machine_records/add_new_machine_model.view.dart';
import 'package:manager/features/home/machine_records/machine_details/machine_details.view.dart';
import 'package:manager/core/locator.dart';
import 'package:stacked_services/stacked_services.dart';

class MachineRecordsView extends StatelessWidget {
  const MachineRecordsView({super.key});

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
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(child: _buildMachineList(context)),
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
        icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Text('machine_records'.lang, style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
        'customerName': 'Leslie Alexander',
        'location': 'New York, US',
      },
      {
        'country': 'US',
        'model': 'DEF-MODEL-DEF',
        'modelNumber': 'DEF',
        'machineType': 'fully_automatic'.lang,
        'isInWarranty': true,
        'customerName': 'John Smith',
        'location': 'Los Angeles, US',
      },
      {
        'country': 'US',
        'model': 'DEF-MODEL-DEF',
        'modelNumber': 'DEF',
        'machineType': 'fully_automatic'.lang,
        'isInWarranty': true,
        'customerName': 'Sarah Johnson',
        'location': 'Chicago, US',
      },
      {
        'country': 'US',
        'model': 'DEF-MODEL-DEF',
        'modelNumber': 'DEF',
        'machineType': 'fully_automatic'.lang,
        'isInWarranty': true,
        'customerName': 'Mike Wilson',
        'location': 'Houston, US',
      },
      {
        'country': 'US',
        'model': 'DEF-MODEL-DEF',
        'modelNumber': 'DEF',
        'machineType': 'fully_automatic'.lang,
        'isInWarranty': false,
        'customerName': 'Emily Davis',
        'location': 'Phoenix, US',
      },
      {
        'country': 'US',
        'model': 'DEF-MODEL-DEF',
        'modelNumber': 'DEF',
        'machineType': 'fully_automatic'.lang,
        'isInWarranty': true,
        'customerName': 'David Brown',
        'location': 'Philadelphia, US',
      },
      {
        'country': 'US',
        'model': 'DEF-MODEL-DEF',
        'modelNumber': 'DEF',
        'machineType': 'fully_automatic'.lang,
        'isInWarranty': true,
        'customerName': 'Lisa Garcia',
        'location': 'San Antonio, US',
      },
      {
        'country': 'US',
        'model': 'DEF-MODEL-DEF',
        'modelNumber': 'DEF',
        'machineType': 'fully_automatic'.lang,
        'isInWarranty': true,
        'customerName': 'Robert Martinez',
        'location': 'San Diego, US',
      },
    ];

    return Column(children: machines.map((machine) => _buildMachineCard(context, machine)).toList());
  }

  Widget _buildMachineCard(BuildContext context, Map<String, dynamic> machine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(color: AppColors.colorF0F2FC, borderRadius: BorderRadius.circular(16)),
            child: Text(machine['country'], style: TextStyle(color: AppColors.colorBlue, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(machine['model'], style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text("${"remarks".lang}: ", style: TextStyle(color: AppColors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(
                      "${machine['customerName']}",
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => MachineDetailsView(machine: machine)));
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.softGray,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.textGray.withValues(alpha: 0.1)),
              ),
              child: Image.asset(AppImages.arrowRight, width: 16, height: 16, color: AppColors.darkGray),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Builder(
      builder:
          (context) => FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddNewMachineModelView()));
            },
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            icon: const Icon(Icons.add, size: 20),
            label: Text('add_new_models'.lang, style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
    );
  }
}
