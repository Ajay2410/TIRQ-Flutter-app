import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:manager/core/models/hive/user/user.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/features/stage/stage.view.dart';
import 'package:manager/services/chat.service.dart';
import 'package:manager/services/stage.service.dart';
import 'package:manager/services/ticket.service.dart';
import 'package:manager/widgets/dialogs/ticket_resolve/ticket_resolve.view.dart';
import 'package:stacked_services/stacked_services.dart';

import '../core/locator.dart';
import '../core/utils/app_logger.dart';
import '../widgets/dialogs/confirmation/confirmation_dialog.view.dart';
import 'dialogs.service.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _ticketService = locator<TicketService>();
  final _chatService = locator<ChatService>();

  Future<void> init() async {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Configure foreground messaging
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Configure background/terminated state messaging
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle tap on notifications
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Initialize local notifications
    _initLocalNotifications();
  }

  void _initLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (
        NotificationResponse notificationResponse,
      ) {
        // Convert RemoteMessage handling to match NotificationResponse
        if (notificationResponse.payload != null) {
          // Handle notification tap with payload
          // You might want to parse the payload or use navigation service
          AppLogger.info(
            'Notification tapped with payload: ${notificationResponse.payload}',
          );
          _handleNotificationTap(notificationResponse);
        }
      },
    );
  }

  // Update _handleNotificationTap method
  void _handleNotificationTap(NotificationResponse details) {
    final payload = details.payload;
    if (payload != null) {
      locator<NavigationService>().navigateTo(
        payload,
        arguments: details.data['index'] ?? StageViewAttributes(selectedBottomNavIndex: 2),
      );
      AppLogger.info('Notification tapped: $details');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    AppLogger.info(
      'Received foreground message: ${message.notification?.title}',
    );
    if (message.data['event'] == NotificationEvents.ticketUpdated.name) {
      _ticketService.triggerRefresh();
      _chatService.triggerRefresh();
    }
    if (message.data['event'] == NotificationEvents.resolveRequest.name) {
      final stageService = locator<StageService>();
      final dialogService = locator<DialogService>();
      final ticketService = locator<TicketService>();
      if (getUser().organizationType == OrganizationType.processor) {
        dialogService.showCustomDialog(
          variant: DialogType.ticketResolve,
          data: TicketResolveDialogAttributes(
            ticketId: message.data['ticketId'],
            onResolvePressed: (ticketId) {
              ticketService.resolveTicket(id: ticketId);
            },
            onRejectPressed: (ticketId) {
              ticketService.rejectResolveTicket(id: ticketId);
            },
            closeDialog: () {},
          ),
        );
        // stageService.setCloseTicketDialogOpen(true, message.data['ticketId']);
      }
      else{
        dialogService.showCustomDialog(
          variant: DialogType.ticketClosed,
          data: ConfirmationDialogAttributes(
            title: "Ticket ${message.data['ticketId']} is closed by Customer",
            description: "Customer problem resolved and ticket has been closed",
            cancelText: "",
            confirmText: "Close",
              onCancelPressed: () {
                stageService.setCloseTicketDialogOpen(false, message.data['ticketId']);
              },
              onConfirmPressed: () {
                stageService.setCloseTicketDialogOpen(false, message.data['ticketId']);
              },

          ),
        );
      }
    }
    // Display local notification for foreground messages
    _showLocalNotification(message);
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    _flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: message.data['route'],
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // Handle notification tap when app is opened from background/terminated state
    final payload = message.data['route'];
    if (payload != null) {
      // Navigate to specific route based on payload
      // Example: navigationService.navigateTo(payload);
      AppLogger.info('App opened from notification: $payload');
    }
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp();
    AppLogger.info(
      'Handling background message: ${message.notification?.title}',
    );
  }

  // Get FCM Token
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Subscribe to topics
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Unsubscribe from topics
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}

enum NotificationEvents { ticketUpdated, resolveRequest }
