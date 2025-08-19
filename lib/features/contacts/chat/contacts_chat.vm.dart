import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/services/chat.service.dart';
import 'package:manager/services/file_picker.service.dart';
import 'package:manager/services/file_upload.service.dart';
import 'package:manager/widgets/dialogs/resolve_request_confirmation/resolve_request_dialog.view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/models/ticket.dart';
import '../../../core/storage/storage.dart';
import '../../../core/utils/failures.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../routes/routes.dart';
import '../../../services/dialogs.service.dart';
import '../../../services/ticket.service.dart';
import 'contacts_chat.view.dart';

enum MessageType {
  text,
  image,
  audio,
  video, document;

  @override
  String toString() {
    return name;
  }
}

class ChatViewModel extends ReactiveViewModel {
  late ChatViewAttributes chatAttributes;
  final TextEditingController messageController = TextEditingController();

  final _chatService = locator<ChatService>();
  final _ticketService = locator<TicketService>();
  final _navigatorService = locator<NavigationService>();

  final _dialogService = locator<DialogService>();


  final _filePickerService = FilePickerService();
  final _fileUploadService = FileUploadService();

  Ticket? ticket;

  // Firebase references
  late DatabaseReference _chatReference;
  StreamSubscription<DatabaseEvent>? _chatSubscription;

  // Messages list
  final List<MessageModel> _messages = [];
  List<MessageModel> get messages => _messages;

  // Current user info
  String get currentUserId {
    return getUser().id ?? '';
  }

  String get currentUserName {
    return getUser().name ?? '';
  }


  void holdTicket(String ticketId) async {
    if (_ticketService.isRefreshing) {
      Fluttertoast.showToast(
        msg: 'Please wait, tickets are being refreshed',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    final response = await _ticketService.holdTicket(
      id: ticketId,
      // If no specific time is provided, default to 1 hour from now
      nextPingTime: '1 Hour',
    );
    response.fold(
          (failure) {
        AppLogger.error(failure.message);
        Fluttertoast.showToast(
            msg: 'Failed to hold ticket: ${failure.message}');
      },
          (ticket) {
            getTicketById(chatAttributes.ticket?.id ?? '');
        Fluttertoast.showToast(
          msg: 'Ticket temporarily held',
          backgroundColor: AppColors.warning,
        );
      },
    );
  }

  void navigateToImageView(String imageUrl) async {
    _navigatorService.navigateTo(Routes.imageViewerView,arguments: imageUrl);
  }

  void pingTicket(String ticketId) async {
    if (_ticketService.isRefreshing) {
      Fluttertoast.showToast(
        msg: 'Please wait, tickets are being refreshed',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    final response = await _ticketService.pingTicket(id: ticketId);
    response.fold(
          (failure) {
        AppLogger.error(failure.message);
        Fluttertoast.showToast(msg: 'Failed to ping : ${failure.message}');
      },
          (ticket) {
            getTicketById(chatAttributes.ticket?.id ?? '');
        Fluttertoast.showToast(
          msg: 'Ticket pinged successfully',
          backgroundColor: AppColors.success,
        );
      },
    );
  }

  StreamSubscription? _refreshSubscription;
  init(ChatViewAttributes attributes) {
    AppLogger.debug('Initializing chat view model');
    chatAttributes = attributes;
    if(chatAttributes.ticket != null){
        getTicketById(chatAttributes.ticket?.id ?? '');
    }

    // Initialize Firebase chat reference using the chat room ID
    _chatReference = FirebaseDatabase.instance
        .ref()
        .child('chats')
        .child(chatAttributes.id)
        .child('messages');

    // Start listening to messages
    _startListeningToMessages();

    _refreshSubscription = _chatService.refreshStream.listen((trigger) {
      if (trigger && !_chatService.isRefreshing) {
        AppLogger.highlight("Received refresh trigger, refreshing chats list");
        if(chatAttributes.ticket != null){
          getTicketById(chatAttributes.ticket?.id ?? '');
        }
      }
    });
  }

  getTicketById(String id) async {
    if (id.isEmpty) {
      AppLogger.error('Ticket ID is empty');
      return;
    }

    setBusy(true);
    final response = await _ticketService.getTicketById(id: id);
    response.fold(
          (exception) {
        Fluttertoast.showToast(msg: exception.message.toString());
        AppLogger.error('Failed to get ticket: ${exception.message}');
      },
          (newTicket) {
        ticket = newTicket;
        AppLogger.debug('Successfully fetched ticket data: ${newTicket.title}');
        notifyListeners();
      },
    );
    if (_chatService.isRefreshing) {
      _chatService.resetRefreshFlag();
    }
    setBusy(false);
  }

  void _startListeningToMessages() {
    _chatSubscription = _chatReference.onChildAdded.listen((DatabaseEvent event) {
      final String messageId = event.snapshot.key ?? '';
      final messageData = event.snapshot.value as Map<dynamic, dynamic>?;

      if (messageData != null) {
        AppLogger.debug('New message received: $messageData');

        // Get current user organization ID
        String organizationId = getUser().organizationId ?? '';
        String senderId = messageData['senderId'] ?? '';

        // Extract content based on organization ID
        Map<dynamic, dynamic> contentMap = messageData['message']['content'] ?? {};

        // Get content in user's language
        String userContent = contentMap[organizationId]?.toString() ?? '';

        // Get original content if it's from another sender
        String? translatedContent;
        bool isSentByMe = senderId == currentUserId;

        // If message is not from current user, get both original and translated content
        if (!isSentByMe && contentMap.containsKey(senderId)) {
          String originalContent = contentMap[senderId]?.toString() ?? '';
          translatedContent = (organizationId != senderId) ? userContent : null;
          userContent = originalContent; // Show original content first
        }

        final message = MessageModel(
          id: messageId,
          content: userContent,
          translatedContent: translatedContent,
          timestamp: _parseTimestamp(messageData['timestamp']),
          isSentByMe: isSentByMe,
          senderName: _getSenderName(senderId),
          senderProfilePic: _getSenderPic(senderId),
          messageType: _parseMessageType(messageData['message']['messageType']),
          status: 'sent',
        );

        // Check if message already exists to prevent duplicates
        if (!_messages.any((m) => m.id == message.id) && userContent.isNotEmpty) {
          _messages.insert(0, message); // Insert at beginning for reverse list
          notifyListeners();
        }
      }
    }, onError: (error) {
      AppLogger.error('Error listening to messages: $error');
    });
  }

  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return DateTime.now();
  }

  String _getSenderName(String? senderId) {
    // If it's the current user, return their name
    if (senderId == currentUserId) {
      return currentUserName;
    }

    // Try to find the sender in the participants list
    final participant = chatAttributes.participants.firstWhere(
            (emp) => emp.id == senderId,
        orElse: () => ChatParticipant(
          id: '',
          name: 'Unknown',
          email: '',
          phone: '',
          profilePhoto: '',
        )
    );

    return participant.name;
  }

  String _getSenderPic(String? senderId) {
    // Try to find the sender in the participants list
    final participant = chatAttributes.participants.firstWhere(
            (emp) => emp.id == senderId,
        orElse: () => ChatParticipant(
          id: '',
          name: 'Unknown',
          email: '',
          phone: '',
          profilePhoto: '',
        )
    );

    return participant.profilePhoto;
  }

  MessageType _parseMessageType(dynamic typeString) {
    if (typeString is String) {
      switch (typeString) {
        case 'image': return MessageType.image;
        case 'audio': return MessageType.audio;
        case 'video': return MessageType.video;
        case 'text':
        default: return MessageType.text;
      }
    }
    return MessageType.text;
  }

  bool _isSendingMessage = false;
  bool get isSendingMessage => _isSendingMessage;

  // Upload progress tracking
  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  // Send a text message
  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    try {
      _isSendingMessage = true;
      notifyListeners();

      // Prepare message data
      final messageData = {
        'content': messageController.text.trim(),
        'messageType': MessageType.text.toString().split('.').last,
      };

      // Clear text field immediately for better UX
      String messageText = messageController.text.trim();
      messageController.clear();

      // Save message to Firebase
      await _chatService.sendMessage(roomId: chatAttributes.id, message: messageData);


      _isSendingMessage = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error sending message: $e');

      // Update message status to failed
      final index = _messages.indexWhere((msg) => msg.status == 'sending');
      if (index != -1) {
        _messages[index] = MessageModel(
          id: _messages[index].id,
          content: _messages[index].content,
          timestamp: _messages[index].timestamp,
          isSentByMe: true,
          senderName: currentUserName,
          senderProfilePic: '',
          messageType: MessageType.text,
          status: 'failed',
        );
      }

      _isSendingMessage = false;
      notifyListeners();

      Fluttertoast.showToast(
        msg: "Failed to send message. Please try again.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  String? _selectedRescheduleOption;
  String? get selectedRescheduleOption => _selectedRescheduleOption;

  updateRescheduleOption(String? value){
    _selectedRescheduleOption = value;
    AppLogger.debug('Selected Reschedule Option: $value');
    notifyListeners();
  }

  Future reopenTicket(String ticketId) async {
    final response = await _chatService.getChatViewAttributesForTicket(ticketId: ticketId);
    response.fold(
          (failure) {
        AppLogger.error(failure.message);
        Fluttertoast.showToast(msg: failure.message);
      },
          (attributes) {
            if(chatAttributes.ticket != null){
              getTicketById(chatAttributes.ticket?.id ?? '');
            }
      },
    );
  }

  Future holdTicketWithDuration(String ticketId, String holdDuration) async {

    final response = await _ticketService.holdTicket(
        id: ticketId, nextPingTime: holdDuration);
    response.fold(
          (failure) {
        AppLogger.error(failure.message);
        Fluttertoast.showToast(
            msg: 'Failed to Reschedule ticket: ${failure.message}');
      },
          (ticket) {
            if(chatAttributes.ticket != null){
              getTicketById(chatAttributes.ticket?.id ?? '');
            }
            Fluttertoast.showToast(
          msg: 'Ticket Reschedule for $holdDuration',
          backgroundColor: AppColors.warning,
        );
      },
    );
  }

  // Add this method to ChatViewModel class
  void resolveTicket(String ticketId) async {
    if (_ticketService.isRefreshing) {
      Fluttertoast.showToast(
        msg: 'Please wait, tickets are being refreshed',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    setBusy(true);
    notifyListeners();

    final dialogResponse  = await _dialogService.showCustomDialog<ResolveRequestResponse,ResolveRequestDialogAttributes>(
      variant: DialogType.resolveRequest,
      data: ResolveRequestDialogAttributes(
        title: 'Resolve Ticket',
        description: 'Is the issue completely resolved and do you want to close the ticket?',
        cancelText: 'Cancel',
        confirmText: 'Yes, Resolve',
      )
    );
    if (dialogResponse?.confirmed != true) {
      return;
    }

    final response = await _ticketService.resolveTicket(id: ticketId,closingRemark: dialogResponse!.data!.remarks);
    response.fold(
          (failure) {
        AppLogger.error(failure.message);
        Fluttertoast.showToast(
          msg: 'Failed to resolve ticket: ${failure.message}',
          backgroundColor: AppColors.error,
        );
      },
          (ticket) {
        Fluttertoast.showToast(
          msg: 'Ticket resolved successfully',
          backgroundColor: AppColors.success,
        );

        _navigatorService.back();

        // Navigate back to the chat list and refresh
        // Navigator.of(navigatorKey.currentContext!).pop();
        // If you have a chat list view model that needs to be refreshed
        // you could use a service locator to access it and refresh it
        // final chatListViewModel = locator<ChatListViewModel>();
        // chatListViewModel.refreshChats();
      },
    );

    setBusy(false);
    notifyListeners();
  }

  Future  requestResolveTicket(String ticketId) async {
    if (_ticketService.isRefreshing) {
      Fluttertoast.showToast(
        msg: 'Please wait, tickets are being refreshed',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    setBusy(true);
    notifyListeners();

    final response = await _ticketService.requestResolveTicket(id: ticketId);
    response.fold(
          (failure) {
        AppLogger.error(failure.message);
        Fluttertoast.showToast(
          msg: 'Failed to request resolution of ticket: ${failure.message}',
          backgroundColor: AppColors.error,
        );
      },
          (ticket) {
        Fluttertoast.showToast(
          msg: 'Request sent successfully',
          backgroundColor: AppColors.success,
        );

        // _navigatorService.back();

        // Navigate back to the chat list and refresh
        // Navigator.of(navigatorKey.currentContext!).pop();
        // If you have a chat list view model that needs to be refreshed
        // you could use a service locator to access it and refresh it
        // final chatListViewModel = locator<ChatListViewModel>();
        // chatListViewModel.refreshChats();
      },
    );

    setBusy(false);
    notifyListeners();
  }

  // Future<Either<Failure, File>> pickDocument({List<String>? allowedExtensions}) async {
  //   try {
  //     final result = await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //       allowedExtensions: allowedExtensions ?? ['pdf', 'doc', 'docx', 'txt'],
  //     );
  //
  //     if (result != null && result.files.single.path != null) {
  //       return Right(File(result.files.single.path!));
  //     } else {
  //       return Left(Failure('No document selected'));
  //     }
  //   } catch (e) {
  //     return Left(Failure('Error picking document: $e'));
  //   }
  // }

  Future<void> pickAndSendDocument() async {
    try {
      _isSendingMessage = true;
      _uploadProgress = 0.0;
      notifyListeners();

      // Pick document
      final result = await _filePickerService.pickDocument();

      final documentFile = result.fold(
            (failure) {
          AppLogger.error('Failed to pick document: ${failure.message}');
          _isSendingMessage = false;
          notifyListeners();
          return null;
        },
            (file) => file,
      );

      if (documentFile == null) {
        _isSendingMessage = false;
        notifyListeners();
        return;
      }

      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      _messages.insert(0, MessageModel(
        id: tempId,
        content: 'Uploading document...',
        timestamp: DateTime.now(),
        isSentByMe: true,
        senderName: currentUserName,
        senderProfilePic: '',
        messageType: MessageType.document,
        status: 'sending',
      ));
      notifyListeners();

      final uploadResult = await _fileUploadService.uploadFileWithProgress(
        documentFile,
            (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );

      final fileUrl = uploadResult.fold(
            (failure) {
          AppLogger.error('Failed to upload document: ${failure.message}');
          final index = _messages.indexWhere((msg) => msg.id == tempId);
          if (index != -1) {
            _messages[index] = MessageModel(
              id: tempId,
              content: 'Failed to upload document',
              timestamp: DateTime.now(),
              isSentByMe: true,
              senderName: currentUserName,
              senderProfilePic: '',
              messageType: MessageType.text,
              status: 'failed',
            );
          }

          _isSendingMessage = false;
          notifyListeners();
          return null;
        },
            (url) => url,
      );

      if (fileUrl == null) {
        _isSendingMessage = false;
        notifyListeners();
        return;
      }

      final messageData = {
        'content': fileUrl,
        'messageType': MessageType.document.toString().split('.').last,
      };

      await _chatService.sendMessage(roomId: chatAttributes.id, message: messageData);
      _messages.removeWhere((msg) => msg.id == tempId);

      _isSendingMessage = false;
      _uploadProgress = 0.0;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Unexpected error: $e');
      _isSendingMessage = false;
      notifyListeners();
    }
  }



  // Pick and send an image
  Future<void> pickAndSendImage({bool fromCamera = false}) async {
    try {
      _isSendingMessage = true;
      _uploadProgress = 0.0;
      notifyListeners();

      // Pick image using file picker service
      final result = fromCamera
          ? await _filePickerService.takePhoto(imageQuality: 80)
          : await _filePickerService.pickImageFromGallery(imageQuality: 80);

      // Handle result
      final imageFile = result.fold(
            (failure) {
          AppLogger.error('Failed to pick image: ${failure.message}');
          _isSendingMessage = false;
          notifyListeners();
          return null;
        },
            (file) => file,
      );

      // If no image was selected, return
      if (imageFile == null) {
        _isSendingMessage = false;
        notifyListeners();
        return;
      }

      // Add a temporary message with status 'sending' for immediate feedback
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      _messages.insert(0, MessageModel(
        id: tempId,
        content: 'Uploading image...',
        timestamp: DateTime.now(),
        isSentByMe: true,
        senderName: currentUserName,
        senderProfilePic: '',
        messageType: MessageType.image,
        status: 'sending',
      ));
      notifyListeners();

      // Upload image with progress tracking
      final uploadResult = await _fileUploadService.uploadFileWithProgress(
        imageFile,
            (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );

      // Handle upload result
      final imageUrl = uploadResult.fold(
            (failure) {
          AppLogger.error('Failed to upload image: ${failure.message}');

          // Update message status to failed
          final index = _messages.indexWhere((msg) => msg.id == tempId);
          if (index != -1) {
            _messages[index] = MessageModel(
              id: tempId,
              content: 'Failed to upload image',
              timestamp: DateTime.now(),
              isSentByMe: true,
              senderName: currentUserName,
              senderProfilePic: '',
              messageType: MessageType.text,
              status: 'failed',
            );
          }

          _isSendingMessage = false;
          notifyListeners();
          return null;
        },
            (url) => url,
      );

      // If upload failed, return
      if (imageUrl == null) {
        _isSendingMessage = false;
        notifyListeners();
        return;
      }

      // Prepare message data with image URL
      final messageData = {
        'content': imageUrl,
        'messageType': MessageType.image.toString().split('.').last,
      };

      // Send the message with image URL
      await _chatService.sendMessage(roomId: chatAttributes.id, message: messageData);

      // Remove the temporary message
      _messages.removeWhere((msg) => msg.id == tempId);

      // Reset state
      _isSendingMessage = false;
      _uploadProgress = 0.0;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error sending image: $e');

      // Update any 'sending' messages to 'failed'
      final index = _messages.indexWhere((msg) => msg.status == 'sending');
      if (index != -1) {
        _messages[index] = MessageModel(
          id: _messages[index].id,
          content: 'Failed to send image',
          timestamp: _messages[index].timestamp,
          isSentByMe: true,
          senderName: currentUserName,
          senderProfilePic: '',
          messageType: MessageType.text,
          status: 'failed',
        );
      }

      _isSendingMessage = false;
      _uploadProgress = 0.0;
      notifyListeners();

      Fluttertoast.showToast(
        msg: "Failed to send image. Please try again.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    // Cancel the subscription when the view model is disposed
    _chatSubscription?.cancel();
    messageController.dispose();
    _refreshSubscription?.cancel();
    super.dispose();
  }
}

class MessageModel {
  final String id;
  final String content;
  final String? translatedContent; // Add field for translated content
  final DateTime timestamp;
  final bool isSentByMe;
  final String senderName;
  final String senderProfilePic;
  final MessageType messageType;
  final String status;

  MessageModel({
    required this.id,
    required this.content,
    this.translatedContent, // Optional translated content
    required this.timestamp,
    required this.isSentByMe,
    required this.senderName,
    required this.senderProfilePic,
    required this.messageType,
    required this.status,
  });
}