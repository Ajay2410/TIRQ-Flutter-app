import 'package:flutter/material.dart';
import 'package:manager/features/Messages/chat/chat.view.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import '../../../resources/app_resources/app_resources.dart';
import 'chat_list.vm.dart';

class ArchivedChatList extends StatefulWidget {
  const ArchivedChatList({super.key});

  @override
  State<ArchivedChatList> createState() => _ArchivedChatListState();
}

class _ArchivedChatListState extends State<ArchivedChatList>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });

    if (_isSearchVisible) {
      _animationController.forward();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    } else {
      _animationController.reverse();
      _searchController.clear();
      _searchFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatListViewModel>.reactive(
      viewModelBuilder: () => ChatListViewModel(),
      onViewModelReady: (model) => model.loadArchivedChats(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primary,
          iconTheme: IconThemeData(color: AppColors.white),
          title: Text(
            LanguageService.get("archived_messages"),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _toggleSearch,
              icon: Icon(
                _isSearchVisible ? Icons.close : Icons.search,
                color: AppColors.white,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: _isSearchVisible ? _buildSearchBar(context, model) : const SizedBox.shrink(),
            ),
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

  Widget _buildSearchBar(BuildContext context, ChatListViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.w20, vertical: AppSizes.h16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          // Add search functionality if needed
        },
        decoration: InputDecoration(
          hintText: LanguageService.get("search_archived_conversations"),
          hintStyle: TextStyle(color: AppColors.gray),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          fillColor: AppColors.lightGray.withValues(alpha: 0.3),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: AppSizes.h12, horizontal: AppSizes.w16),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: AppColors.gray),
            onPressed: () {
              _searchController.clear();
            },
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
              LanguageService.get("no_archived_conversations"),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.h8),
            Text(
              LanguageService.get("archived_conversations_appear_here"),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatListViewModel model, ChatViewAttributes chatRoom) {
    final lastMessageTime = chatRoom.ticket?.completedDate ?? chatRoom.createdAt;
    final formatter = DateFormat('MMM dd, yyyy • h:mm a');
    final formattedTime = formatter.format(lastMessageTime);

    return InkWell(
      onTap: () => model.navigateToChat(chatRoom),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSizes.h12, horizontal: AppSizes.w16),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(bottom: BorderSide(color: AppColors.lightGray, width: 1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChatAvatar(chatRoom),
            SizedBox(width: AppSizes.w12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    _getLastMessagePreview(chatRoom),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSizes.h4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.w8, vertical: AppSizes.h2),
                    decoration: BoxDecoration(
                      color: AppColors.gray.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.v12),
                    ),
                    child: Text(
                      LanguageService.get("archived"),
                      style: TextStyle(
                        color: AppColors.gray,
                        fontSize: AppSizes.v12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatAvatar(ChatViewAttributes chatRoom) {
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

  String _getChatTitle(ChatViewAttributes chatRoom) {
    if (chatRoom.organization?.name?.isNotEmpty == true) {
      return chatRoom.organization!.name!;
    } else if (chatRoom.ticket?.ticketId != null) {
      return chatRoom.ticket!.ticketId!;
    } else {
      return "${LanguageService.get("chat")} #${chatRoom.id.substring(0, 6)}";
    }
  }

  String _getLastMessagePreview(ChatViewAttributes chatRoom) {
    if (chatRoom.ticket?.ticketId != null) {
      return chatRoom.ticket!.ticketId!;
    } else if (chatRoom.participants.isNotEmpty) {
      return chatRoom.participants.map((org) => org.name).join(", ");
    }
    return LanguageService.get("placeholder_last_message");
  }
}