import 'package:flutter/material.dart';
import 'package:manager/core/utils/helpers/helpers.dart';
import 'package:manager/features/Messages/chat/chat.view.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../routes/routes.dart';
import 'chat_list.vm.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late TabController _tabController;
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    _tabController.dispose();
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
      onViewModelReady: (model) => model.init(),
      builder:
          (context, model, child) => Scaffold(
            backgroundColor: AppColors.textOnPrimary,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: AppColors.primary,
              iconTheme: IconThemeData(color: AppColors.white),
              title: Text(
                LanguageService.get("messages"),
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
                IconButton(
                  icon: Icon(Icons.archive_outlined, color: AppColors.white),
                  onPressed: () => model.navigateToArchivedChats(),
                  tooltip: LanguageService.get("archived_messages"),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: AppColors.white),
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.createGroupChat);
                  },
                  tooltip: LanguageService.get("create_new_chat"),
                ),
              ],
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
                    text: LanguageService.get("tickets"),
                    icon: Icon(Icons.support_agent, size: 20),
                  ),
                  Tab(
                    text: LanguageService.get("departmental"),
                    icon: Icon(Icons.business, size: 20),
                  ),
                  Tab(
                    text: LanguageService.get("external"),
                    icon: Icon(Icons.public, size: 20),
                  ),
                ],
              ),
            ),
            body: Column(
              children: [
                SlideTransition(
                  position: _slideAnimation,
                  child:
                      _isSearchVisible
                          ? _buildSearchBar(context, model)
                          : const SizedBox.shrink(),
                ),
                Expanded(
                  child:
                      model.isLoading
                          ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                          : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildChatList(
                                context,
                                model,
                                model.getFilteredTicketChats(),
                                LanguageService.get("no_ticket_conversations"),
                                LanguageService.get("ticket_chats_appear_here"),
                                Icons.support_agent,
                              ),
                              _buildChatList(
                                context,
                                model,
                                model.getFilteredDepartmentalChats(),
                                LanguageService.get(
                                  "no_departmental_conversations",
                                ),
                                LanguageService.get(
                                  "departmental_chats_appear_here",
                                ),
                                Icons.business,
                              ),
                              _buildChatList(
                                context,
                                model,
                                model.getFilteredExternalChats(),
                                LanguageService.get(
                                  "no_external_conversations",
                                ),
                                LanguageService.get(
                                  "external_chats_appear_here",
                                ),
                                Icons.public,
                              ),
                            ],
                          ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildChatList(
    BuildContext context,
    ChatListViewModel model,
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
      onRefresh: model.getChatRooms,
      child: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chatRoom = chats[index];
          return _buildChatItem(context, model, chatRoom);
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ChatListViewModel model) {
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
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          model.updateSearchQuery(value);
        },
        decoration: InputDecoration(
          hintText: LanguageService.get("search_conversations"),
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
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.gray),
                    onPressed: () {
                      _searchController.clear();
                      model.clearSearch();
                    },
                  )
                  : null,
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context,
    ChatListViewModel model,
    ChatViewAttributes chatRoom,
  ) {
    final lastMessageTime =
        chatRoom.ticket?.createdAt != null
            ? DateTime.parse(chatRoom.ticket!.createdAt!)
            : chatRoom.createdAt;
    final formatter = DateFormat('MMM d • h:mm a');
    final differenceInMinutes = formatter.format(lastMessageTime);

    return InkWell(
      onTap: () => model.navigateToChat(chatRoom),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSizes.h12,
          horizontal: AppSizes.w16,
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
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _getLastMessagePreview(chatRoom),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: AppSizes.w8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.w8,
                          vertical: AppSizes.h2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            chatRoom.ticket?.status ?? chatRoom.status,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.v12),
                        ),
                        child: Text(
                          chatRoom.ticket?.status != null
                              ? formatStatus(chatRoom.ticket!.status!)
                              : chatRoom.status,
                          style: TextStyle(
                            color: _getStatusColor(
                              chatRoom.ticket?.status ?? chatRoom.status,
                            ),
                            fontSize: AppSizes.v12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.h4),
                  _buildChatTypeIndicator(chatRoom),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatAvatar(ChatViewAttributes chatRoom) {
    Color avatarColor;
    IconData avatarIcon;

    switch (chatRoom.chatRoomType?.toLowerCase()) {
      case 'ticket':
        avatarColor = AppColors.error;
        avatarIcon = Icons.support_agent;
        break;
      case 'withinorg':
        avatarColor = AppColors.primary;
        avatarIcon = Icons.business;
        break;
      default:
        avatarColor = AppColors.success;
        avatarIcon = Icons.public;
        break;
    }

    if (chatRoom.participants.length == 1) {
      return Stack(
        children: [
          CircleAvatar(
            radius: AppSizes.v24,
            backgroundColor: avatarColor.withValues(alpha: 0.2),
            child: Text(
              chatRoom.participants[0].name.substring(0, 1).toUpperCase(),
              style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(avatarIcon, size: 12, color: avatarColor),
            ),
          ),
        ],
      );
    } else {
      return CircleAvatar(
        radius: AppSizes.v24,
        backgroundColor: avatarColor.withValues(alpha: 0.2),
        child: Icon(avatarIcon, color: avatarColor),
      );
    }
  }

  Widget _buildChatTypeIndicator(ChatViewAttributes chatRoom) {
    String typeLabel;
    Color typeColor;

    switch (chatRoom.chatRoomType?.toLowerCase()) {
      case 'ticket':
        typeLabel = LanguageService.get("ticket");
        typeColor = AppColors.error;
        break;
      case 'withinorg':
        typeLabel = LanguageService.get("department");
        typeColor = AppColors.primary;
        break;
      default:
        typeLabel = LanguageService.get("external");
        typeColor = AppColors.success;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w6,
        vertical: AppSizes.h2,
      ),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.v8),
        border: Border.all(color: typeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        typeLabel,
        style: TextStyle(
          color: typeColor,
          fontSize: AppSizes.v10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getChatTitle(ChatViewAttributes chatRoom) {
    if (chatRoom.chatRoomType?.toLowerCase() == "ticket" &&
        chatRoom.ticket?.ticketId != null) {
      return chatRoom.ticket!.ticketId!;
    } else if (chatRoom.chatRoomType?.toLowerCase() == "withinorg") {
      if (chatRoom.groupName?.isNotEmpty == true) {
        return chatRoom.groupName!;
      } else if (chatRoom.organization?.name?.isNotEmpty == true) {
        return chatRoom.organization!.name!;
      }
    } else if (chatRoom.groupName?.isNotEmpty == true) {
      return chatRoom.groupName!;
    } else if (chatRoom.organization?.name?.isNotEmpty == true) {
      return chatRoom.organization!.name!;
    }

    return "${LanguageService.get("chat")} #${chatRoom.id.substring(0, 6)}";
  }

  String _getLastMessagePreview(ChatViewAttributes chatRoom) {
    if (chatRoom.ticket?.description != null) {
      return chatRoom.ticket!.description!;
    } else if (chatRoom.participants.isNotEmpty) {
      return chatRoom.participants
          .map((participant) => participant.name)
          .join(", ");
    }
    return LanguageService.get("placeholder_last_message");
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
      case 'inprogress':
        return AppColors.info;
      default:
        return AppColors.info;
    }
  }

  String formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'inprogress':
        return LanguageService.get("in_progress");
      case 'onhold':
        return LanguageService.get("on_hold");
      case 'active':
        return LanguageService.get("active");
      case 'pending':
        return LanguageService.get("pending");
      case 'closed':
        return LanguageService.get("closed");
      default:
        return status;
    }
  }
}
