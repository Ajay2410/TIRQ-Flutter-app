import 'package:flutter/material.dart';
import 'package:manager/features/Messages/chat/chat.view.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import '../../../resources/app_resources/app_resources.dart';
import 'contacts_list.vm.dart';

class ArchivedChatList extends StatelessWidget {
  const ArchivedChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ContactsListViewModel>.reactive(
      viewModelBuilder: () => ContactsListViewModel(),
      onViewModelReady: (model) => model.loadArchivedChats(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primary,
          iconTheme: IconThemeData(color: AppColors.white),
          title: Text(
            'Archived Messages',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            _buildSearchBar(context),
            Expanded(
              child: model.isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : model.archivedChatRooms.isEmpty
                  ? _buildEmptyState(context)
                  : RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.white,
                onRefresh: model.loadArchivedChats,
                child: ListView.builder(
                  itemCount: model.archivedChatRooms.length,
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.w16),
                  itemBuilder: (context, index) {
                    final chatRoom = model.archivedChatRooms[index];
                    return _buildChatItem(context, model, chatRoom);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
              Icons.archive_outlined,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: AppSizes.h16),
          Text(
            "No archived conversations",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.h8),
          Text(
            "Archived conversations will appear here",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w20,
        vertical: AppSizes.h16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search archived conversations...',
          hintStyle: TextStyle(color: AppColors.gray),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          fillColor: AppColors.lightGray.withValues(alpha: 0.3),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: AppSizes.h12,
            horizontal: AppSizes.w16,
          ),
        ),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ContactsListViewModel model, ChatViewAttributes chatRoom) {
    // Format date for last message timestamp
    final lastMessageTime = chatRoom.ticket?.completedDate ?? chatRoom.createdAt; // Placeholder
    final formatter = DateFormat('MMM d • h:mm a');
    final formattedTime = formatter.format(lastMessageTime);

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
                        formattedTime,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.h4),
                  // Last message preview
                  Text(
                    _getLastMessagePreview(chatRoom),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSizes.h4),
                  // Status tag
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.w8,
                        vertical: AppSizes.h2
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.v12),
                    ),
                    child: Text(
                      "Archived",
                      style: TextStyle(
                        color: AppColors.gray,
                        fontSize: AppSizes.v12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // // Unarchive button
            // IconButton(
            //   icon: Icon(Icons.unarchive, color: AppColors.primary),
            //   onPressed: () => model.unarchiveChat(chatRoom.id),
            //   tooltip: 'Unarchive',
            // ),
          ],
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
        backgroundColor: AppColors.gray.withValues(alpha: 0.2),
        child: Text(
          chatRoom.participants[0].name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: AppColors.gray,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      // Group chat avatar
      return CircleAvatar(
        radius: AppSizes.v24,
        backgroundColor: AppColors.gray.withValues(alpha: 0.2),
        child: Icon(
          Icons.people,
          color: AppColors.gray,
        ),
      );
    }
  }

  // Helper methods
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
}