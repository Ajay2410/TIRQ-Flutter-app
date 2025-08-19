import 'package:flutter/material.dart';
import 'package:manager/core/utils/helpers/helpers.dart';
import 'package:manager/features/Messages/chat/chat.view.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import '../../../core/models/employee.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../routes/routes.dart';
import '../../../services/language.service.dart';
import 'contacts_list.vm.dart';

class ContactsListView extends StatefulWidget {
  const ContactsListView({super.key});

  @override
  State<ContactsListView> createState() => _ContactsListViewState();
}

class _ContactsListViewState extends State<ContactsListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ContactsListViewModel>.reactive(
      viewModelBuilder: () => ContactsListViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.textOnPrimary,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primary,
          iconTheme: IconThemeData(color: AppColors.white),
          title: Text(
            'Contacts',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.white,
            indicatorWeight: 3,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
            tabs: [
              Tab(
                text: LanguageService.get("departmental"),
                icon: Icon(Icons.business, size: 20),
              ),
              Tab(
                text:  LanguageService.get("external"),
                icon: Icon(Icons.public, size: 20),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // _buildSearchBar(context, model),
            Expanded(
              child: model.isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : TabBarView(
                controller: _tabController,
                children: [
                  // Departmental Tab - Show Employees
                  _buildEmployeeList(
                    context,
                    model,
                    model.employees,
                    LanguageService.get("no_employees_found"),
                    LanguageService.get("organization_employees_will_appear_here"),
                    Icons.business,
                  ),
                  // External Tab - Show External Chats
                  _buildExternalChatList(
                    context,
                    model,
                    model.externalChatRooms,
                    LanguageService.get("no_external_conversations"),
                    LanguageService.get("external_organization_appear_here"),
                    Icons.public,
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.createGroupChat);
          },
          backgroundColor: AppColors.primary,
          child: Icon(Icons.add, color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildEmployeeList(
      BuildContext context,
      ContactsListViewModel model,
      List<Employee> employees,
      String emptyTitle,
      String emptySubtitle,
      IconData emptyIcon,
      ) {
    if (employees.isEmpty) {
      return _buildEmptyState(context, emptyTitle, emptySubtitle, emptyIcon);
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      onRefresh: model.refreshEmployees,
      child: ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return _buildEmployeeItem(context, model, employee);
        },
      ),
    );
  }

  Widget _buildExternalChatList(
      BuildContext context,
      ContactsListViewModel model,
      List<ChatViewAttributes> chats,
      String emptyTitle,
      String emptySubtitle,
      IconData emptyIcon,
      ) {
    if (chats.isEmpty) {
      return _buildEmptyState(context, emptyTitle, emptySubtitle, emptyIcon);
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      onRefresh: model.refreshExternalChats,
      child: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chatRoom = chats[index];
          return _buildExternalChatItem(context, model, chatRoom);
        },
      ),
    );
  }

  Widget _buildEmployeeItem(BuildContext context, ContactsListViewModel model, Employee employee) {
    return InkWell(
      onTap: () => model.createIndividualChat(employee),
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: AppSizes.h12,
            horizontal: AppSizes.w16
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.lightGray, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Avatar
            _buildEmployeeAvatar(employee),
            SizedBox(width: AppSizes.w12),
            // Employee details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Employee name
                  Text(
                    _getEmployeeName(employee),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSizes.h4),
                  // Employee designation/department
                  if (_getEmployeeDesignation(employee).isNotEmpty)
                    Text(
                      _getEmployeeDesignation(employee),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: AppSizes.h4),
                  // Employee status
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.w8,
                        vertical: AppSizes.h2
                    ),
                    decoration: BoxDecoration(
                      color: _getEmployeeStatusColor(employee).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.v12),
                    ),
                    child: Text(
                      _getEmployeeStatus(employee),
                      style: TextStyle(
                        color: _getEmployeeStatusColor(employee),
                        fontSize: AppSizes.v12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Online indicator or action icon
            Icon(
              Icons.chat_bubble_outline,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExternalChatItem(BuildContext context, ContactsListViewModel model, ChatViewAttributes chatRoom) {
    // Format date for last message timestamp
    final lastMessageTime = chatRoom.ticket?.createdAt!=null?DateTime.parse(chatRoom.ticket!.createdAt!):chatRoom.createdAt;
    final formatter = DateFormat('MMM d • h:mm a');
    final differenceInMinutes = formatter.format(lastMessageTime);

    return InkWell(
      onTap: () => model.navigateToChat(chatRoom),
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: AppSizes.h12,
            horizontal: AppSizes.w16
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.lightGray, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar or Organization icon
            _buildChatAvatar(chatRoom),
            SizedBox(width: AppSizes.w12),
            // Chat details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with name and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _getChatTitle(chatRoom),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        differenceInMinutes,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.h4),
                  // Last message preview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _getLastMessagePreview(chatRoom),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.w8,
                            vertical: AppSizes.h2
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(chatRoom.ticket?.status??chatRoom.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.v12),
                        ),
                        child: Text(
                          chatRoom.ticket?.status!=null?formatStatus(chatRoom.ticket!.status!):chatRoom.status,
                          style: TextStyle(
                            color: _getStatusColor(chatRoom.ticket?.status??chatRoom.status),
                            fontSize: AppSizes.v12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.v24),
            decoration: BoxDecoration(
              color: AppColors.lightGray.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: AppSizes.h16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.h8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildEmployeeAvatar(Employee employee) {
    return CircleAvatar(
      radius: AppSizes.v24,
      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
      child: Text(
        _getEmployeeName(employee).substring(0, 1).toUpperCase(),
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChatAvatar(ChatViewAttributes chatRoom) {
    // If there's a single organization or employee, show their avatar
    // Otherwise show a group avatar
    if (chatRoom.participants.length == 1) {
      return CircleAvatar(
        radius: AppSizes.v24,
        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
        child: Text(
          chatRoom.participants[0].name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      // Group chat avatar
      return CircleAvatar(
        radius: AppSizes.v24,
        backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
        child: Icon(
          Icons.people,
          color: AppColors.secondary,
        ),
      );
    }
  }

  // Helper methods for employees
  String _getEmployeeName(Employee employee) {
    return employee.fullName ?? "Unknown Employee";
  }

  String _getEmployeeDesignation(Employee employee) {
    return employee.role ?? "";
  }

  String _getEmployeeStatus(Employee employee) {
    // You can add status logic here based on your employee model
    return "Active";
  }

  Color _getEmployeeStatusColor(Employee employee) {
    final status = _getEmployeeStatus(employee).toLowerCase();
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'inactive':
        return AppColors.gray;
      case 'busy':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  // Helper methods for external chats
  String _getChatTitle(ChatViewAttributes chatRoom) {
    if (chatRoom.organization?.name?.isNotEmpty==true) {
      return chatRoom.organization!.name!;
    } else if (chatRoom.ticket?.ticketId!=null) {
      return chatRoom.ticket!.ticketId!;
    } else {
      return "Chat #${chatRoom.id.substring(0, 6)}";
    }
  }

  String _getLastMessagePreview(ChatViewAttributes chatRoom) {
    // This would come from the actual last message
    if (chatRoom.ticket?.ticketId!=null) {
      return chatRoom.ticket!.ticketId!;
    }else if (chatRoom.participants.isNotEmpty) {
      return chatRoom.participants.map((org) => org.name).join(", ");
    }
    // For now we'll use placeholder text
    return "This is a placeholder for the last message in this conversation...";
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'closed':
        return AppColors.gray;
      case 'onhold':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  String formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'inprogress':
        return 'In Progress';
      case 'onhold':
        return 'On Hold';
      case 'active':
        return 'Active';
      case 'pending':
        return 'Pending';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }
}