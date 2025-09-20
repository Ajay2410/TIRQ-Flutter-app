import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:stacked/stacked.dart';

import '../../core/locator.dart';
import '../../core/models/hive/user/user.dart';
import '../../resources/app_resources/app_resources.dart';
import '../../services/chat.service.dart';
import '../../services/language.service.dart';
import '../../services/socket_service.dart';
import 'model/chat_message_model.dart';

enum MessageType {
  text,
  image,
  audio,
  video,
  document,
  location,
  link;

  @override
  String toString() {
    return name;
  }
}

class ChatViewModel extends ReactiveViewModel {
  final _chatService = locator<ChatService>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final SocketService _socketService = SocketService();

  // State variables
  bool _isSendingMessage = false;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Messages list
  final List<ChatMessageModel> _messages = [];
  List<ChatMessageModel> get messages => _messages.toList();

  // Getters
  bool get isSendingMessage => _isSendingMessage;

  User userData = getUser();
  String roomId = "default_room";

  /// Handle new incoming messages
  void _handleNewMessage(dynamic data) {
    print(" New message received: $data");
    if (data is Map<String, dynamic>) {
      final message = ChatMessageModel.fromJson(data);

      if(message.sender.id == userData.id) {
        message.isSentByMe = true;
      } else {
        message.isSentByMe = false;
      }

      _messages.add(message);
      notifyListeners();
      _scrollToBottom();
    }
  }

  Future<void> fetchInitialData({required String? roomId1}) async {
    _isLoading = true;
    notifyListeners();

    roomId = roomId1 ?? roomId;
    await Future.wait([
      initializeSocket(),
      getAllChatMessages(),
    ]);

    _isLoading = false;
    notifyListeners();
  }


  /// Socket implementation
  Future<void> initializeSocket() async {
    // Initialize socket connection
    _socketService.initializeSocket(
      serverUrl: 'https://triq.onrender.com/',
      queryParams: {'userId': userData.id ?? 'default_user', 'roomId': roomId},
      extraHeaders: {'Authorization': "${userData.token}"},
    );

    // Register user
    _socketService.registerUser(userData.id ?? 'default_user');

    // Join room
    _socketService.joinRoom(roomId);

    // Listen for incoming messages
    _socketService.onNewMessage(_handleNewMessage);
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  /// Fetch all messages
  Future<void> getAllChatMessages() async {
    try {
      final result = await _chatService.getAllChatMessages(roomId: roomId);

      result.fold(
            (failure) {
          AppLogger.error('Failed to get all chats: ${failure.message}');
          _messages.clear();

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

              final result = response.map((element) {
                element.isSentByMe = element.sender.id == userData.id;
                return element;
              }).toList();

              _messages.clear();
              _messages.addAll(result);
          AppLogger.info('Chat Messages loaded ${response.length} messages');
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching chat rooms: $e');
    }
  }

  /// Send a text message
  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) {
      AppLogger.warning('Cannot send empty message');
      return;
    }

    try {
      _isSendingMessage = true;
      notifyListeners();

      final messageText = messageController.text.trim();
      messageController.clear();

      // Send message via socket
      _socketService.sendMessage(
        roomId: roomId,
        content: messageText,
      );

      AppLogger.info('Message sent locally for immediate display.');
    } catch (e) {
      AppLogger.error('Error sending message: $e');
      // Optionally, update the temporary message to show a 'failed' state.
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  // NOTE: The 'sendAttachment' and 'addSampleMessage' methods are now broken
  // because they use the old MessageModel. They need to be updated or removed.

  /// Send a file attachment
  Future<void> sendAttachment({
    required String fileUrl,
    required MessageType messageType,
    required String fileName,
  }) async {
    // This method is broken and needs to be updated for ChatMessageModel
  }

  @override
  void dispose() {
    // Clean up socket listeners
    _socketService.off('newMessage');
    _socketService.dispose();

    // Dispose controllers
    messageController.dispose();
    scrollController.dispose();

    super.dispose();
  }
}
