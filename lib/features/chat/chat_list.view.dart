import 'package:flutter/material.dart';
import 'package:manager/features/chat/chat_list.vm.dart';
import 'package:manager/features/chat/chat_view.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:stacked/stacked.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import '../../resources/app_resources/app_resources.dart';

// Dummy chat data model
class DummyChatData {
  final String id;
  final String title;
  final String lastMessage;
  final String time;
  final String status;
  final String type;
  final int unreadCount;

  DummyChatData({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.time,
    required this.status,
    required this.type,
    required this.unreadCount,
  });
}

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isSearchVisible = false;
  int selectedTabIndex = 0;
  String _statusFilter = 'all';
  String _sortFilter = 'latest';

  // Dynamic border radius for segmented control
  BorderRadius _dynamicBorder = BorderRadius.only(topLeft: Radius.circular(AppSizes.v45), bottomLeft: Radius.circular(AppSizes.v45));

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
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

  PreferredSizeWidget _buildAppBar(BuildContext context, ChatListViewModel model) {
    return GradientAppBar(
      titleSpacing: 0,
      leading: IconButton(onPressed: () => model. navigateToHome(), icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white)),
      titleKey: 'messages',
      actions: [
        InkWell(onTap: _toggleSearch, child: Image.asset(AppImages.search, width: 23, height: 23, color: AppColors.white)),
        SizedBox(width: 15),
        InkWell(onTap: () => model.navigateToArchivedChats(), child: Image.asset(AppImages.archive, width: 23, height: 23, color: AppColors.white)),
        PopupMenuButton<String>(
          icon: Stack(
            children: [
              Image.asset(AppImages.filter, width: 23, height: 23, color: AppColors.white),
              if (_statusFilter != 'all' || (_sortFilter != 'latest' && _statusFilter == 'all'))
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                ),
            ],
          ),
          menuPadding: EdgeInsets.zero,
          offset: Offset(-10, 40),
          onSelected: (String value) {
            setState(() {
              if (value == 'in_progress' || value == 'on_hold') {
                // Toggle status filter - if same filter is selected, remove it
                if (_statusFilter == value) {
                  _statusFilter = 'all';
                } else {
                  _statusFilter = value;
                }
                // Reset sort filter when status filter changes
                _sortFilter = 'latest';
              } else if (value == 'latest' || value == 'oldest') {
                // Toggle sort filter - if same filter is selected, reset to default
                if (_sortFilter == value) {
                  _sortFilter = 'latest';
                } else {
                  _sortFilter = value;
                }
                // Reset status filter when sort filter changes
                _statusFilter = 'all';
              }
            });
          },
          itemBuilder:
              (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'in_progress',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        if (_statusFilter == 'in_progress') Icon(Icons.check, color: AppColors.primary, size: 20),
                        if (_statusFilter == 'in_progress') SizedBox(width: 8),
                        Text(
                          'In Progress',
                          style: TextStyle(
                            color: _statusFilter == 'in_progress' ? AppColors.primary : AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: _statusFilter == 'in_progress' ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuDivider(height: 0),
                PopupMenuItem<String>(
                  value: 'on_hold',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        if (_statusFilter == 'on_hold') Icon(Icons.check, color: AppColors.primary, size: 20),
                        if (_statusFilter == 'on_hold') SizedBox(width: 8),
                        Text(
                          'On Hold',
                          style: TextStyle(
                            color: _statusFilter == 'on_hold' ? AppColors.primary : AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: _statusFilter == 'on_hold' ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuDivider(height: 0),
                PopupMenuItem<String>(
                  value: 'latest',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        if (_sortFilter == 'latest' && _statusFilter == 'all') Icon(Icons.check, color: AppColors.primary, size: 20),
                        if (_sortFilter == 'latest' && _statusFilter == 'all') SizedBox(width: 8),
                        Text(
                          'Latest to Oldest',
                          style: TextStyle(
                            color: (_sortFilter == 'latest' && _statusFilter == 'all') ? AppColors.primary : AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: (_sortFilter == 'latest' && _statusFilter == 'all') ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuDivider(height: 0),
                PopupMenuItem<String>(
                  value: 'oldest',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        if (_sortFilter == 'oldest' && _statusFilter == 'all') Icon(Icons.check, color: AppColors.primary, size: 20),
                        if (_sortFilter == 'oldest' && _statusFilter == 'all') SizedBox(width: 8),
                        Text(
                          'Oldest to Latest',
                          style: TextStyle(
                            color: (_sortFilter == 'oldest' && _statusFilter == 'all') ? AppColors.primary : AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: (_sortFilter == 'oldest' && _statusFilter == 'all') ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: AppColors.white,
          shadowColor: AppColors.black.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatListViewModel>.reactive(
      viewModelBuilder: () => ChatListViewModel(),
      onViewModelReady: (model) => model.init(),
      builder:
          (context, model, child) => Scaffold(
            appBar: _buildAppBar(context, model),
            // appBar: AppBar(
            //   elevation: 0,
            //   backgroundColor: AppColors.primary,
            //   iconTheme: IconThemeData(color: AppColors.white),
            //   title: Text(
            //     LanguageService.get("messages"),
            //     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            //       color: AppColors.white,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            //   actions: [
            //     IconButton(
            //       onPressed: _toggleSearch,
            //       icon: Icon(
            //         _isSearchVisible ? Icons.close : Icons.search,
            //         color: AppColors.white,
            //       ),
            //     ),
            //     IconButton(
            //       icon: Icon(Icons.archive_outlined, color: AppColors.white),
            //       onPressed: () => model.navigateToArchivedChats(),
            //       tooltip: LanguageService.get("archived_messages"),
            //     ),
            //     IconButton(
            //       icon: Icon(Icons.add, color: AppColors.white),
            //       onPressed: () {
            //         Navigator.of(context).pushNamed(Routes.createGroupChat);
            //       },
            //       tooltip: LanguageService.get("create_new_chat"),
            //     ),
            //   ],
            // ),
            body: Container(
              color: AppColors.white,
              child: SafeArea(
                child: Column(
                  children: [
                    // Animated search bar
                    SlideTransition(position: _slideAnimation, child: _isSearchVisible ? _buildSearchBar(context, model) : const SizedBox.shrink()),
                    // Tab Bar
                    Container(
                      color: AppColors.white,
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.w20, vertical: AppSizes.h16),
                      child: CustomSlidingSegmentedControl<int>(
                        height: 40,
                        innerPadding: EdgeInsets.zero,
                        initialValue: selectedTabIndex,
                        decoration: BoxDecoration(
                          color: AppColors.lightGray.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(AppSizes.v45),
                        ),
                        padding: AppSizes.v4,
                        isStretch: true,
                        children: {
                          0: Text(
                            LanguageService.get("tickets"),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: selectedTabIndex == 0 ? AppColors.white : AppColors.black,
                            ),
                          ),
                          1: Text(
                            LanguageService.get("departmental"),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: selectedTabIndex == 1 ? AppColors.white : AppColors.black,
                            ),
                          ),
                          2: Text(
                            LanguageService.get("external"),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: selectedTabIndex == 2 ? AppColors.white : AppColors.black,
                            ),
                          ),
                        },
                        fromMax: true,
                        thumbDecoration: BoxDecoration(borderRadius: _dynamicBorder, color: AppColors.primary),
                        onValueChanged: (int value) {
                          setState(() {
                            selectedTabIndex = value;
                            // Update dynamic border radius based on selected segment
                            switch (value) {
                              case 0:
                                _dynamicBorder = BorderRadius.only(topLeft: Radius.circular(AppSizes.v45), bottomLeft: Radius.circular(AppSizes.v45));
                                break;
                              case 1:
                                _dynamicBorder = BorderRadius.circular(0);
                                break;
                              case 2:
                                _dynamicBorder = BorderRadius.only(
                                  topRight: Radius.circular(AppSizes.v45),
                                  bottomRight: Radius.circular(AppSizes.v45),
                                );
                                break;
                            }
                          });
                        },
                      ),
                    ),
                    // Tab Content
                    Expanded(
                      child: Container(
                        color: AppColors.scaffoldBackground,
                        child:
                            model.isLoading
                                ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                                : _buildFilteredChatList(context, model),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  List<DummyChatData> _getDummyChats() {
    return [
      DummyChatData(
        id: '1',
        title: 'Ticket #12345',
        lastMessage: 'The machine is working perfectly now. Thank you!',
        time: '2:30 PM',
        status: 'Resolved',
        type: 'ticket',
        unreadCount: 0,
      ),
      DummyChatData(
        id: '2',
        title: 'Engineering Team',
        lastMessage: 'Meeting scheduled for tomorrow at 10 AM',
        time: '1:45 PM',
        status: 'Active',
        type: 'departmental',
        unreadCount: 3,
      ),
      DummyChatData(
        id: '3',
        title: 'External Partner - ABC Corp',
        lastMessage: 'Please review the attached documents',
        time: '12:20 PM',
        status: 'Pending',
        type: 'external',
        unreadCount: 1,
      ),
      DummyChatData(
        id: '4',
        title: 'Ticket #12346',
        lastMessage: 'We are investigating the issue',
        time: '11:15 AM',
        status: 'In Progress',
        type: 'ticket',
        unreadCount: 2,
      ),
      DummyChatData(
        id: '5',
        title: 'Support Team',
        lastMessage: 'New update available for the system',
        time: '10:30 AM',
        status: 'Active',
        type: 'departmental',
        unreadCount: 0,
      ),
      DummyChatData(
        id: '6',
        title: 'Client - XYZ Industries',
        lastMessage: 'Thank you for the quick response',
        time: '9:45 AM',
        status: 'Resolved',
        type: 'external',
        unreadCount: 0,
      ),
      DummyChatData(
        id: '7',
        title: 'Ticket #12347',
        lastMessage: 'Issue has been escalated to senior support',
        time: '8:20 AM',
        status: 'Escalated',
        type: 'ticket',
        unreadCount: 5,
      ),
      DummyChatData(
        id: '8',
        title: 'Management Team',
        lastMessage: 'Monthly review meeting notes attached',
        time: 'Yesterday',
        status: 'Active',
        type: 'departmental',
        unreadCount: 0,
      ),
      DummyChatData(
        id: '9',
        title: 'Ticket #12348',
        lastMessage: 'Working on the solution',
        time: '10:30 AM',
        status: 'In Progress',
        type: 'ticket',
        unreadCount: 1,
      ),
      DummyChatData(
        id: '10',
        title: 'Support Team',
        lastMessage: 'Waiting for client response',
        time: '9:15 AM',
        status: 'On Hold',
        type: 'departmental',
        unreadCount: 0,
      ),
    ];
  }

  Widget _buildFilteredChatList(BuildContext context, ChatListViewModel model) {
    final allChats = _getDummyChats();
    List<DummyChatData> filteredChats;
    String emptyTitle;
    String emptySubtitle;
    IconData emptyIcon;

    // Filter by tab type
    switch (selectedTabIndex) {
      case 0: // Tickets
        filteredChats = allChats.where((chat) => chat.type == 'ticket').toList();
        emptyTitle = LanguageService.get("no_ticket_conversations");
        emptySubtitle = LanguageService.get("ticket_chats_appear_here");
        emptyIcon = Icons.support_agent;
        break;
      case 1: // Departmental
        filteredChats = allChats.where((chat) => chat.type == 'departmental').toList();
        emptyTitle = LanguageService.get("no_departmental_conversations");
        emptySubtitle = LanguageService.get("departmental_chats_appear_here");
        emptyIcon = Icons.business;
        break;
      case 2: // External
        filteredChats = allChats.where((chat) => chat.type == 'external').toList();
        emptyTitle = LanguageService.get("no_external_conversations");
        emptySubtitle = LanguageService.get("external_chats_appear_here");
        emptyIcon = Icons.public;
        break;
      default:
        filteredChats = allChats;
        emptyTitle = "No conversations";
        emptySubtitle = "No chats available";
        emptyIcon = Icons.chat;
    }

    // Apply status filter
    if (_statusFilter != 'all') {
      filteredChats =
          filteredChats.where((chat) {
            switch (_statusFilter) {
              case 'in_progress':
                return chat.status.toLowerCase() == 'in progress';
              case 'on_hold':
                return chat.status.toLowerCase() == 'on hold';
              default:
                return true;
            }
          }).toList();
    }

    // Apply sort filter
    if (_sortFilter == 'oldest') {
      filteredChats = filteredChats.reversed.toList();
    }

    if (filteredChats.isEmpty) {
      return _buildEmptyState(context, emptyTitle, emptySubtitle, emptyIcon);
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      onRefresh: () async {
        // Simulate refresh delay
        await Future.delayed(Duration(seconds: 1));
      },
      child: ListView.separated(
        separatorBuilder: (context, index) {
          return Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Divider(height: 0));
        },
        itemCount: filteredChats.length,
        itemBuilder: (context, index) {
          final chatRoom = filteredChats[index];
          return _buildChatItem(context, model, chatRoom);
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ChatListViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.w20, vertical: AppSizes.h16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), offset: const Offset(0, 2), blurRadius: 8)],
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.v12), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: AppSizes.h12, horizontal: AppSizes.w16),
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

  Widget _buildEmptyState(BuildContext context, String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.v24),
            decoration: BoxDecoration(color: AppColors.lightGray.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: Icon(icon, size: 80, color: AppColors.primary.withValues(alpha: 0.7)),
          ),
          SizedBox(height: AppSizes.h16),
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: AppSizes.h8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCountryFlag(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppSizes.v16)),
          alignment: Alignment.center,
          child: Text(
            "VG - Van Group".substring(0, 2).toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
          ),
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: ClipRRect(borderRadius: BorderRadius.circular(2), child: Image.asset(AppImages.flag, width: 17, height: 17, fit: BoxFit.cover)),
        ),
      ],
    );
  }

  Widget _buildChatItem(BuildContext context, ChatListViewModel model, DummyChatData chatRoom) {
    return InkWell(
      onTap: () {
        // Navigate to chat screen with dummy data
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ChatView(contactName: 'Leslie Alexander', contactNumber: '#12352344566', contactInitials: 'LA')),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSizes.h15, horizontal: AppSizes.w16),
        decoration: BoxDecoration(color: AppColors.white),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCountryFlag(context),
            SizedBox(width: AppSizes.w10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'VG - Van Group',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: AppSizes.w8, vertical: AppSizes.h2),
                        decoration: BoxDecoration(color: AppColors.redBack.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppSizes.v6)),
                        child: Text("On Hold", style: TextStyle(color: AppColors.redBack, fontSize: AppSizes.v12)),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text('${LanguageService.get("pending_since")} : ', style: TextStyle(fontSize: 11, color: AppColors.textGray)),
                            Text("3 hours 15Min", style: TextStyle(fontSize: 11, color: AppColors.black)),
                          ],
                        ),
                      ),
                      Text("#12352344566", style: TextStyle(fontSize: 10, color: AppColors.black, fontWeight: FontWeight.bold)),
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
}
