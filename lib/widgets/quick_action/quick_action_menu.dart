import 'package:flutter/material.dart';
import 'package:manager/core/models/hive/user/user.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/features/machines/add_machine/add_machine.view.dart';
import 'package:manager/features/tickets/add_ticket/add_ticket.view.dart';
import '../../features/home/organization_home/organization_home.vm.dart';
import '../../resources/app_resources/app_resources.dart';
import '../../routes/routes.dart';

/// Shows the quick action menu as a list at the right side of the screen
void showRightSideActionList(
  BuildContext context,
  OrganizationHomeViewModel model,
) {
  final Size screenSize = MediaQuery.of(context).size;
  final double menuWidth = screenSize.width * 0.53;
  // Get the safe area padding to adjust the position
  final EdgeInsets safePadding = MediaQuery.of(context).padding;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Quick Actions",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => Container(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation),
        child: Padding(
          // Add padding to the top based on safe area
          padding: EdgeInsets.only(top: AppSizes.h25),
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              height: screenSize.height * 0.45,
              width: menuWidth,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.v10),
                  bottomLeft: Radius.circular(AppSizes.v10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(-2, 0),
                  ),
                ],
              ),
              child: RightSideActionList(model: model),
            ),
          ),
        ),
      );
    },
  );
}

/// The right side action list widget that displays quick actions
class RightSideActionList extends StatelessWidget {
  final OrganizationHomeViewModel model;

  const RightSideActionList({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.w10,
              vertical: AppSizes.h2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: AppColors.primary, // Changed to primary
                    fontSize: AppSizes.v20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppColors.primary,
                  ), // Changed to primary
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(
            color: AppColors.primary.withOpacity(0.2),
          ), // Changed to primary
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: AppSizes.h8),
              children: [
                _buildListActionItem(
                  context: context,
                  icon: Icons.person_add,
                  label: 'Add Employee',
                  onTap: () {
                    Navigator.pop(context);
                    model.showScanQrOptionsForEmployee();
                  },
                ),
                if (getUser().organizationType == OrganizationType.manufacturer)
                  _buildListActionItem(
                    context: context,
                    icon: Icons.build,
                    label: 'Add Machine',
                    onTap: () {
                      Navigator.pop(context);
                      model.navigateToRoute(
                        Routes.addMachine,
                        null,
                        parameters: AddMachineViewAttributes().toMap(),
                      );
                    },
                  ),
                if (getUser().organizationType == OrganizationType.processor)
                  _buildListActionItem(
                    context: context,
                    icon: Icons.confirmation_number,
                    label: 'Create Ticket',
                    onTap: () {
                      Navigator.pop(context);
                      model.navigateToRoute(
                        Routes.addTicket,
                        AddTicketViewAttributes(),
                      );
                    },
                  ),
                _buildListActionItem(
                  context: context,
                  icon: Icons.task,
                  label: 'Create Task',
                  onTap: () {
                    Navigator.pop(context);
                    // model.navigateToRoute(Routes.tasks);
                  },
                ),

                _buildListActionItem(
                  context: context,
                  icon: Icons.handshake,
                  label:
                      getUser().organizationType ==
                              OrganizationType.manufacturer
                          ? 'Add Customer'
                          : 'Add Manufacturer',
                  onTap: () {
                    Navigator.pop(context);
                    model.showScanQrOptionsForPartner();
                  },
                ),
                _buildListActionItem(
                  context: context,
                  icon: Icons.person,
                  label: 'Edit Profile',
                  onTap: () {
                    Navigator.pop(context);
                    // model.navigateToRoute(Routes.createOrEditOrg);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a list action item with icon and label
  Widget _buildListActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(AppSizes.v8),
        decoration: BoxDecoration(
          color: AppColors.primary, // Changed to primary
          borderRadius: BorderRadius.circular(AppSizes.v8),
        ),
        child: Icon(
          icon,
          color: AppColors.white,
          size: AppSizes.v24,
        ), // Changed to white
      ),
      title: Text(
        label,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: AppSizes.v16,
        ), // Changed to primary
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSizes.w16,
        vertical: AppSizes.h4,
      ),
      hoverColor: AppColors.primary.withOpacity(0.1),
    );
  }
}

/// Legacy Quick Action Menu implementation (floating action button style)
/// This is kept for reference but replaced by the right side panel implementation
class QuickActionMenu extends StatelessWidget {
  final OrganizationHomeViewModel model;

  const QuickActionMenu({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "quick_action_menu_fab",
      backgroundColor: AppColors.white, // Changed to white
      child: Icon(Icons.add, color: AppColors.primary), // Changed to primary
      onPressed: () {
        _showQuickActionSheet(context);
      },
    );
  }

  void _showQuickActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionSheet(model: model),
    );
  }
}

/// Legacy Quick Action Sheet implementation
/// This is kept for reference but replaced by the RightSideActionList implementation
class QuickActionSheet extends StatelessWidget {
  final OrganizationHomeViewModel model;

  const QuickActionSheet({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white, // Changed to white
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.v20),
          topRight: Radius.circular(AppSizes.v20),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: AppSizes.h20,
        horizontal: AppSizes.w16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: AppColors.primary,
              ), // Changed to primary
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Wrap(
            spacing: AppSizes.w16,
            runSpacing: AppSizes.h16,
            alignment: WrapAlignment.center,
            children: [
              _buildActionItem(
                context: context,
                icon: Icons.person_add,
                label: 'Add\nEmployee',
                onTap: () {
                  Navigator.pop(context);
                  model.showScanQrOptionsForEmployee();
                },
              ),
              if (getUser().organizationType == OrganizationType.manufacturer)
                _buildActionItem(
                  context: context,
                  icon: Icons.build,
                  label: 'Add\nMachine',
                  onTap: () {
                    Navigator.pop(context);
                    model.navigateToRoute(
                      Routes.addMachine,
                      null,
                      parameters: AddMachineViewAttributes().toMap(),
                    );
                  },
                ),
              if (getUser().organizationType == OrganizationType.processor)
                _buildActionItem(
                  context: context,
                  icon: Icons.confirmation_number,
                  label: 'Create\nTicket',
                  onTap: () {
                    Navigator.pop(context);
                    model.navigateToRoute(
                      Routes.addTicket,
                      AddTicketViewAttributes(),
                    );
                  },
                ),
              _buildActionItem(
                context: context,
                icon: Icons.task,
                label: 'Create\nTask',
                onTap: () {
                  Navigator.pop(context);
                  // model.navigateToRoute(Routes.tasks);
                },
              ),
              if (getUser().organizationType == OrganizationType.manufacturer)
                _buildActionItem(
                  context: context,
                  icon: Icons.handshake,
                  label: 'Add\nCustomer',
                  onTap: () {
                    Navigator.pop(context);
                    model.showScanQrOptionsForPartner();
                  },
                ),
              _buildActionItem(
                context: context,
                icon: Icons.person,
                label: 'Edit\nProfile',
                onTap: () {
                  Navigator.pop(context);
                  // model.navigateToRoute(Routes.createOrEditOrg);
                },
              ),
            ],
          ),
          Spacer(),
          TextButton.icon(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.primary,
            ), // Changed to primary
            label: Text(
              'Back',
              style: TextStyle(color: AppColors.primary),
            ), // Changed to primary
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(height: AppSizes.h8),
        ],
      ),
    );
  }

  /// Build a grid action item for the original quick action menu
  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.v12),
      child: Container(
        width: AppSizes.w90,
        height: AppSizes.h100,
        padding: EdgeInsets.symmetric(
          vertical: AppSizes.h16,
          horizontal: AppSizes.w8,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary, // Changed to primary
          borderRadius: BorderRadius.circular(AppSizes.v12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.white,
              size: AppSizes.v24,
            ), // Changed to white
            SizedBox(height: AppSizes.h8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.white,
                fontSize: AppSizes.v12,
              ), // Changed to white
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
