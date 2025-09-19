import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/core/models/chat_list_model.dart';
import 'package:manager/core/utils/failures.dart';
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

  List<ChatListModel> _chatRooms = [];
  List<ChatListModel> get chatRooms => _chatRooms;

  List<ChatListModel> _allChats = [];
  List<ChatListModel> get allChats => _allChats;

  List<ChatListModel> _archivedChatRooms = [];
  List<ChatListModel> get archivedChatRooms => _archivedChatRooms;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StreamSubscription? _refreshSubscription;

  // Filter methods for different chat types based on ticket type
  List<ChatListModel> getTicketChats() {
    return _allChats.where((chat) {
      return chat.ticket?.ticketType?.toLowerCase().contains("machine") == true;
    }).toList();
  }

  List<ChatListModel> getDepartmentalChats() {
    return _allChats.where((chat) {
      return chat.ticket?.type?.toLowerCase() == "online";
    }).toList();
  }

  List<ChatListModel> getExternalChats() {
    return _allChats.where((chat) {
      return chat.ticket?.type?.toLowerCase() != "online";
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

  // Archived filter methods - Note: These methods are not implemented as the API doesn't support archived chats yet
  List<ChatListModel> getArchivedTicketChats() {
    return [];
  }

  List<ChatListModel> getArchivedDepartmentalChats() {
    return [];
  }

  List<ChatListModel> getArchivedExternalChats() {
    return [];
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
  List<ChatListModel> getFilteredTicketChats() {
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

  List<ChatListModel> getFilteredDepartmentalChats() {
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

  List<ChatListModel> getFilteredExternalChats() {
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
    try {
      final result = await _chatService.getAllChats();

      result.fold(
        (failure) {
          AppLogger.error('Failed to get all chats: ${failure.message}');
          _allChats = [];

          Fluttertoast.showToast(
            msg:
                "${LanguageService.get("failed_to_load_chats")}: ${failure.message}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.error,
            textColor: AppColors.white,
          );
        },
        (response) {
          _allChats = response;
          AppLogger.info('Successfully loaded ${response.length} chats');

          AppLogger.info(
            'Chat types distribution: '
            'Total chats: ${response.length}',
          );
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching all chats: $e');
      _allChats = [];

      Fluttertoast.showToast(
        msg: LanguageService.get("error_loading_chats"),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
    } finally {
      if (_chatService.isRefreshing) {
        _chatService.resetRefreshFlag();
      }
    }

    notifyListeners();
  }

  Future<void> loadArchivedChats() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Note: Archived chats are not supported by the API yet
      // final result = await _chatService.getArchivedChatRooms();
      final result = Right<Failure, List<ChatListModel>>([]);

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

  void navigateToChat(ChatListModel chatRoom) async {
    await _navigationService.navigateTo(Routes.chat, arguments: chatRoom);
    init();
  }

  void navigateToArchivedChats() {
    _navigationService.navigateTo(Routes.archivedChats);
  }

  // Helper methods for search functionality
  String _getChatTitle(ChatListModel chat) {
    if (chat.ticket?.ticketNumber != null) {
      return "Ticket #${chat.ticket!.ticketNumber!}";
    } else if (chat.chatWith?.fullName != null) {
      return chat.chatWith!.fullName!;
    }
    return "${LanguageService.get("chat")} #${chat.id?.substring(0, 6) ?? 'unknown'}";
  }

  String _getLastMessagePreview(ChatListModel chat) {
    if (chat.ticket?.problem != null) {
      return chat.ticket!.problem!;
    } else if (chat.chatWith?.fullName != null) {
      return "Chat with ${chat.chatWith!.fullName!}";
    }
    return LanguageService.get("no_messages_yet");
  }

  bool hasUnreadMessages(ChatListModel chat) {
    return (chat.id?.hashCode ?? 0) % 3 == 0;
  }

  int getUnreadMessageCount(ChatListModel chat) {
    if (hasUnreadMessages(chat)) {
      return ((chat.id?.hashCode ?? 0) % 10) + 1;
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
