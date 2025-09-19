import 'dart:async';

import 'package:flutter/material.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:stacked/stacked.dart';

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

class MessageModel {
  final String id;
  final String content;
  final String? translatedContent;
  final DateTime timestamp;
  final bool isSentByMe;
  final String senderName;
  final String senderProfilePic;
  final MessageType messageType;
  final String status;

  MessageModel({
    required this.id,
    required this.content,
    this.translatedContent,
    required this.timestamp,
    required this.isSentByMe,
    required this.senderName,
    required this.senderProfilePic,
    required this.messageType,
    required this.status,
  });
}

class ChatViewModel extends ReactiveViewModel {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // State variables
  bool _isSendingMessage = false;

  // Messages list
  final List<MessageModel> _messages = [];
  List<MessageModel> get messages => _messages;

  // Getters
  bool get isSendingMessage => _isSendingMessage;

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

      // Add message to local list immediately for better UX
      final tempMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: messageText,
        timestamp: DateTime.now(),
        isSentByMe: true,
        senderName: 'You',
        senderProfilePic: '',
        messageType: MessageType.text,
        status: 'sending',
      );

      _messages.insert(0, tempMessage);
      notifyListeners();

      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));

      // Update message status to sent
      final messageIndex = _messages.indexWhere((m) => m.id == tempMessage.id);
      if (messageIndex != -1) {
        _messages[messageIndex] = MessageModel(
          id: tempMessage.id,
          content: tempMessage.content,
          timestamp: tempMessage.timestamp,
          isSentByMe: true,
          senderName: tempMessage.senderName,
          senderProfilePic: tempMessage.senderProfilePic,
          messageType: tempMessage.messageType,
          status: 'sent',
        );
      }

      AppLogger.info('Message sent successfully');
    } catch (e) {
      AppLogger.error('Error sending message: $e');

      // Update message status to failed
      final messageIndex = _messages.indexWhere((m) => m.status == 'sending');
      if (messageIndex != -1) {
        _messages[messageIndex] = MessageModel(
          id: _messages[messageIndex].id,
          content: _messages[messageIndex].content,
          timestamp: _messages[messageIndex].timestamp,
          isSentByMe: true,
          senderName: _messages[messageIndex].senderName,
          senderProfilePic: _messages[messageIndex].senderProfilePic,
          messageType: _messages[messageIndex].messageType,
          status: 'failed',
        );
      }
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  /// Send a file attachment
  Future<void> sendAttachment({
    required String fileUrl,
    required MessageType messageType,
    required String fileName,
  }) async {
    try {
      _isSendingMessage = true;
      notifyListeners();

      // Add message to local list
      final tempMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: fileName,
        timestamp: DateTime.now(),
        isSentByMe: true,
        senderName: 'You',
        senderProfilePic: '',
        messageType: messageType,
        status: 'sending',
      );

      _messages.insert(0, tempMessage);
      notifyListeners();

      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));

      // Update message status
      final messageIndex = _messages.indexWhere((m) => m.id == tempMessage.id);
      if (messageIndex != -1) {
        _messages[messageIndex] = MessageModel(
          id: tempMessage.id,
          content: tempMessage.content,
          timestamp: tempMessage.timestamp,
          isSentByMe: true,
          senderName: tempMessage.senderName,
          senderProfilePic: tempMessage.senderProfilePic,
          messageType: tempMessage.messageType,
          status: 'sent',
        );
      }

      AppLogger.info('Attachment sent successfully');
    } catch (e) {
      AppLogger.error('Error sending attachment: $e');

      // Update message status to failed
      final messageIndex = _messages.indexWhere((m) => m.status == 'sending');
      if (messageIndex != -1) {
        _messages[messageIndex] = MessageModel(
          id: _messages[messageIndex].id,
          content: _messages[messageIndex].content,
          timestamp: _messages[messageIndex].timestamp,
          isSentByMe: true,
          senderName: _messages[messageIndex].senderName,
          senderProfilePic: _messages[messageIndex].senderProfilePic,
          messageType: _messages[messageIndex].messageType,
          status: 'failed',
        );
      }
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  /// Add a sample message for demonstration
  void addSampleMessage() {
    final sampleMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'Hello! This is a sample message.',
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      isSentByMe: false,
      senderName: 'Contact',
      senderProfilePic: '',
      messageType: MessageType.text,
      status: 'sent',
    );

    _messages.add(sampleMessage);
    notifyListeners();
  }

  @override
  void dispose() {
    // Dispose controllers
    messageController.dispose();
    scrollController.dispose();

    super.dispose();
  }
}
