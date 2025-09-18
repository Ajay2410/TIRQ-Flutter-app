import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/features/Messages/chat/chat.view.dart';
import 'package:manager/services/chat.service.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/services/stage.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/utils/app_logger.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../routes/routes.dart';

class ChatListViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _chatService = locator<ChatService>();
  final _stageService = locator<StageService>();

  List<ChatViewAttributes> _chatRooms = [];
  List<ChatViewAttributes> get chatRooms => _chatRooms;

  List<ChatViewAttributes> _archivedChatRooms = [];
  List<ChatViewAttributes> get archivedChatRooms => _archivedChatRooms;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StreamSubscription? _refreshSubscription;

  // Filter methods for different chat types based on chatRoomType
  List<ChatViewAttributes> getTicketChats() {
    return _chatRooms.where((chat) {
      return chat.chatRoomType?.toLowerCase() == "ticket";
    }).toList();
  }

  List<ChatViewAttributes> getDepartmentalChats() {
    return _chatRooms.where((chat) {
      return chat.chatRoomType?.toLowerCase() == "withinorg";
    }).toList();
  }

  List<ChatViewAttributes> getExternalChats() {
    return _chatRooms.where((chat) {
      final roomType = chat.chatRoomType?.toLowerCase();
      return roomType != "ticket" && roomType != "withinorg";
    }).toList();
  }

  void navigateToHome() {
    _stageService.updateSelectedBottomNavIndex(0);
  }

  // Count methods for badges
  int get ticketChatsCount => getTicketChats().length;
  int get departmentalChatsCount => getDepartmentalChats().length;
  int get externalChatsCount => getExternalChats().length;
  int get totalChatsCount => _chatRooms.length;

  // Archived filter methods
  List<ChatViewAttributes> getArchivedTicketChats() {
    return _archivedChatRooms
        .where((chat) => chat.chatRoomType?.toLowerCase() == "ticket")
        .toList();
  }

  List<ChatViewAttributes> getArchivedDepartmentalChats() {
    return _archivedChatRooms
        .where((chat) => chat.chatRoomType?.toLowerCase() == "withinorg")
        .toList();
  }

  List<ChatViewAttributes> getArchivedExternalChats() {
    return _archivedChatRooms.where((chat) {
      final roomType = chat.chatRoomType?.toLowerCase();
      return roomType != "ticket" && roomType != "withinorg";
    }).toList();
  }

  // Archived count methods
  int get archivedTicketChatsCount => getArchivedTicketChats().length;
  int get archivedDepartmentalChatsCount =>
      getArchivedDepartmentalChats().length;
  int get archivedExternalChatsCount => getArchivedExternalChats().length;
  int get totalArchivedChatsCount => _archivedChatRooms.length;

  // Search functionality
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Filtered search results for each tab
  List<ChatViewAttributes> getFilteredTicketChats() {
    final tickets = getTicketChats();
    if (_searchQuery.isEmpty) return tickets;

    return tickets
        .where(
          (chat) =>
              _getChatTitle(chat).toLowerCase().contains(_searchQuery) ||
              _getLastMessagePreview(chat).toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  List<ChatViewAttributes> getFilteredDepartmentalChats() {
    final departmental = getDepartmentalChats();
    if (_searchQuery.isEmpty) return departmental;

    return departmental
        .where(
          (chat) =>
              _getChatTitle(chat).toLowerCase().contains(_searchQuery) ||
              _getLastMessagePreview(chat).toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  List<ChatViewAttributes> getFilteredExternalChats() {
    final external = getExternalChats();
    if (_searchQuery.isEmpty) return external;

    return external
        .where(
          (chat) =>
              _getChatTitle(chat).toLowerCase().contains(_searchQuery) ||
              _getLastMessagePreview(chat).toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  void init() async {
    _isLoading = true;
    notifyListeners();

    await getChatRooms();

    _isLoading = false;
    notifyListeners();

    _refreshSubscription = _chatService.refreshStream.listen((trigger) {
      if (trigger && !_chatService.isRefreshing) {
        AppLogger.highlight("Received refresh trigger, refreshing chats list");
        getChatRooms();
      }
    });
  }

  Future<void> getChatRooms() async {
    // try {
    //   final result = await _chatService.getChatRooms();

    //   result.fold(
    //     (failure) {
    //       AppLogger.error('Failed to get chat rooms: ${failure.message}');
    //       _chatRooms = [];

    //       Fluttertoast.showToast(
    //         msg:
    //             "${LanguageService.get("failed_to_load_chats")}: ${failure.message}",
    //         toastLength: Toast.LENGTH_SHORT,
    //         gravity: ToastGravity.BOTTOM,
    //         backgroundColor: AppColors.error,
    //         textColor: AppColors.white,
    //       );
    //     },
    //     (response) {
    //       _chatRooms = response;
    //       AppLogger.info('Successfully loaded ${response.length} chat rooms');

    //       AppLogger.info(
    //         'Chat types distribution: '
    //         'Tickets: ${ticketChatsCount}, '
    //         'Departmental: ${departmentalChatsCount}, '
    //         'External: ${externalChatsCount}',
    //       );

    //       final roomTypes = <String, int>{};
    //       for (final chat in _chatRooms) {
    //         final type = chat.chatRoomType ?? 'null';
    //         roomTypes[type] = (roomTypes[type] ?? 0) + 1;
    //       }
    //       AppLogger.info('ChatRoomType distribution: $roomTypes');
    //     },
    //   );
    // } catch (e) {
    //   AppLogger.error('Error fetching chat rooms: $e');
    //   _chatRooms = [];

    //   Fluttertoast.showToast(
    //     msg: LanguageService.get("error_loading_chats"),
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //     backgroundColor: AppColors.error,
    //     textColor: AppColors.white,
    //   );
    // } finally {
    //   if (_chatService.isRefreshing) {
    //     _chatService.resetRefreshFlag();
    //   }
    // }

    // Set empty chat rooms since API is disabled
    _chatRooms = [];
    if (_chatService.isRefreshing) {
      _chatService.resetRefreshFlag();
    }

    notifyListeners();
  }

  Future<void> loadArchivedChats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _chatService.getArchivedChatRooms();

      result.fold(
        (failure) {
          AppLogger.error(
            'Failed to get archived chat rooms: ${failure.message}',
          );
          _archivedChatRooms = [];

          Fluttertoast.showToast(
            msg: LanguageService.get("failed_to_load_archived_chats"),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.error,
            textColor: AppColors.white,
          );
        },
        (response) {
          _archivedChatRooms = response;
          AppLogger.info(
            'Successfully loaded ${response.length} archived chat rooms',
          );
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching archived chat rooms: $e');
      _archivedChatRooms = [];

      Fluttertoast.showToast(
        msg: LanguageService.get("error_loading_archived_chats"),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  void navigateToChat(ChatViewAttributes chatRoom) async {
    await _navigationService.navigateTo(Routes.chat, arguments: chatRoom);
    init();
  }

  void navigateToArchivedChats() {
    _navigationService.navigateTo(Routes.archivedChats);
  }

  // Helper methods for search functionality
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
    if (chatRoom.chatRoomType?.toLowerCase() == "ticket" &&
        chatRoom.ticket?.description != null) {
      return chatRoom.ticket!.description!;
    } else if (chatRoom.participants.isNotEmpty) {
      return chatRoom.participants
          .map((participant) => participant.name)
          .join(", ");
    }
    return LanguageService.get("no_messages_yet");
  }

  bool hasUnreadMessages(ChatViewAttributes chatRoom) {
    return chatRoom.id.hashCode % 3 == 0;
  }

  int getUnreadMessageCount(ChatViewAttributes chatRoom) {
    if (hasUnreadMessages(chatRoom)) {
      return (chatRoom.id.hashCode % 10) + 1;
    }
    return 0;
  }

  Future<void> refreshChatType(String chatType) async {
    AppLogger.info('Refreshing chats for type: $chatType');
    await getChatRooms();
  }

  @override
  void dispose() {
    _refreshSubscription?.cancel();
    super.dispose();
  }
}
