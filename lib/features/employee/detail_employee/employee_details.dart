import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../core/models/employee.dart';
import '../../../services/language.service.dart';
import 'employee_details.vm.dart';
import '../add_employee/add_employee.view.dart';

class EmployeeDetailsViewAttributes {
  final String employeeId;

  EmployeeDetailsViewAttributes({
    required this.employeeId,
  });

  factory EmployeeDetailsViewAttributes.fromJson(Map<String, String> json) {
    return EmployeeDetailsViewAttributes(
      employeeId: json['employeeId'] ?? '',
    );
  }

  Map<String, String> toJson() {
    return {
      'employeeId': employeeId,
    };
  }
}

class EmployeeDetailsView extends StatelessWidget {
  const EmployeeDetailsView({super.key, required this.attributes});

  final EmployeeDetailsViewAttributes attributes;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EmployeeDetailsViewModel>.reactive(
      viewModelBuilder: () => EmployeeDetailsViewModel(),
      onViewModelReady: (model) => model.init(attributes),
      builder: (
          BuildContext context,
          EmployeeDetailsViewModel model,
          Widget? child,
          ) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildCustomAppBar(context, model),
          body: SafeArea(
            child: model.isBusy
                ? Center(child: CircularProgressIndicator())
                : model.employee == null
                ? Center(child: Text(LanguageService.get('employee_not_found')))
                : _buildEmployeeDetailsContent(context, model),
          ),
          floatingActionButton: model.employee != null
              ? FloatingActionButton(
            onPressed: () => model.onEditEmployee(context),
            backgroundColor: AppColors.primary,
            child: Icon(Icons.edit, color: AppColors.white),
          )
              : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context, EmployeeDetailsViewModel model) {
    return AppBar(
      backgroundColor: AppColors.primary,
      surfaceTintColor: AppColors.primary,
      iconTheme: IconThemeData(color: AppColors.white),
      title: Text(
        LanguageService.get('employee_details'),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (model.employee != null)
          PopupMenuButton<String>(
            onSelected: (value) => model.handleMenuAction(value, context),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: LanguageService.get('delete'),
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    LanguageService.get('delete'),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildEmployeeDetailsContent(BuildContext context, EmployeeDetailsViewModel model) {
    final employee = model.employee!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.w20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(context, employee),
          SizedBox(height: AppSizes.h20),
          _buildSectionHeader(context, LanguageService.get('personal_details')),
          SizedBox(height: AppSizes.h10),
          _buildInfoCard(context, [
            _buildInfoItem(context, LanguageService.get('name'), employee.name ?? 'N/A'),
            _buildInfoItem(context, LanguageService.get('email'), employee.email ?? 'N/A'),
            _buildInfoItem(context, LanguageService.get('phone'), employee.phone ?? 'N/A'),
            _buildInfoItem(context, LanguageService.get('account_status'), employee.accountStatus ?? 'N/A'),
            _buildInfoItem(context, LanguageService.get('preferred_language'), employee.preferredLanguage ?? 'N/A'),
          ]),

          SizedBox(height: AppSizes.h20),
          _buildSectionHeader(context, LanguageService.get('employee_details')),
          SizedBox(height: AppSizes.h10),
          _buildInfoCard(context, [
            _buildInfoItem(context, LanguageService.get('role'), employee.role ?? 'N/A'),
            _buildInfoItem(context, LanguageService.get('type'), employee.employeeType ?? 'N/A'),
            _buildInfoItem(context, LanguageService.get('status'), employee.employmentStatus ?? 'N/A'),
            _buildInfoItem(context, LanguageService.get('shift_timing'), employee.shift ?? 'N/A'),
          //   if (employee.team != null && employee?.team!.isNotEmpty)
          //     _buildInfoItem(context, "Team", employee.team!),
          //   _buildInfoItem(context, "Joined", model.formatDate(employee.createdAt)),
          ]),

          SizedBox(height: AppSizes.h20),
          _buildSectionHeader(context, LanguageService.get('permissions')),
          SizedBox(height: AppSizes.h10),
          _buildPermissionsCard(context, employee),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Employee employee) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: AppSizes.h20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.v16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary,
            child: Text(
              _getInitials(employee.name ?? ''),
              style: TextStyle(
                fontSize: 30,
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: AppSizes.h10),
          Text(
            employee.name ?? 'N/A',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.h5),
          Text(
            employee.role ?? 'N/A',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.h5),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.w10,
              vertical: AppSizes.h5,
            ),
            decoration: BoxDecoration(
              color: employee.accountStatus == 'active'
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.v20),
            ),
            child: Text(
              employee.accountStatus?.toUpperCase() ?? 'N/A',
              style: TextStyle(
                color: employee.accountStatus == 'active'
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.w16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.v12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.h6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsCard(BuildContext context, Employee employee) {
    // Helper function to extract permissions
    List<Widget> buildPermissionItems(Map<String, dynamic> section, String sectionName) {
      List<Widget> items = [];

      section.forEach((key, value) {
        if (value is bool) {
          items.add(_buildPermissionItem(context, '$sectionName - ${_formatPermissionName(key)}', value));
        } else if (value is String) {
          items.add(_buildInfoItem(context, '$sectionName - ${_formatPermissionName(key)}', value));
        }
      });

      return items;
    }

    List<Widget> permissionWidgets = [];

    // Account Access
    if (employee.permissions?.accountAccess != null) {
      permissionWidgets.add(_buildInfoItem(
          context,
          LanguageService.get('account_access'),
          employee.permissions!.accountAccess!
      ));
    }

    // Add all permission sections
    if (employee.permissions?.ticketManagement != null) {
      permissionWidgets.addAll(buildPermissionItems(employee.permissions!.ticketManagement!.toJson(), "Ticket Management"));
    }

    if (employee.permissions?.machineManagement != null) {
      permissionWidgets.addAll(buildPermissionItems(employee.permissions!.machineManagement!.toJson(), "Machine Management"));
    }

    if (employee.permissions?.customerInteraction != null) {
      permissionWidgets.addAll(buildPermissionItems(employee.permissions!.customerInteraction!.toJson(), "Customer Interaction"));
    }

    if (employee.permissions?.financialAccess != null) {
      permissionWidgets.addAll(buildPermissionItems(employee.permissions!.financialAccess!.toJson(), "Financial Access"));
    }

    if (employee.permissions?.userManagement != null) {
      permissionWidgets.addAll(buildPermissionItems(employee.permissions!.userManagement!.toJson(), "User Management"));
    }

    if (employee.permissions?.reportAccess != null) {
      permissionWidgets.addAll(buildPermissionItems(employee.permissions!.reportAccess!.toJson(), "Report Access"));
    }

    if (employee.permissions?.communicationTools != null) {
      permissionWidgets.addAll(buildPermissionItems(employee.permissions!.communicationTools!.toJson(), "Communication Tools"));
    }

    return _buildInfoCard(context, permissionWidgets);
  }

  Widget _buildPermissionItem(BuildContext context, String label, bool value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.h6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 24,
            height: 24,
            child: value
                ? Icon(Icons.check_circle, color: Colors.green)
                : Icon(Icons.cancel, color: Colors.red.withOpacity(0.6)),
          )
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';

    List<String> nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
    } else {
      return name.substring(0, 1).toUpperCase();
    }
  }

  String _formatPermissionName(String name) {
    // Convert camelCase to Title Case with Spaces
    final result = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
          (Match match) => ' ${match.group(0)}',
    );

    return result.substring(0, 1).toUpperCase() + result.substring(1);
  }
}