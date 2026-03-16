// Services/notifications_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Initialiser les notifications locales
  static Future<void> initialize() async {
    print('=== INITIALISATION NOTIFICATIONS ===');

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('📱 Notification cliquée');
        print('Payload: ${response.payload}');

        if (response.payload != null && response.payload!.isNotEmpty) {
          _handleNotificationClick(response.payload!);
        }
      },
    );

    await _createNotificationChannel();

    print('✅ Notifications initialisées');
  }

  /// Créer un canal de notification Android
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'assurappci_channel',
      'AssurAppCI',
      description: 'Notifications AssurAppCI',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(channel);
    }
  }

  /// Afficher une notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'assurappci_channel',
        'AssurAppCI',
        channelDescription: 'Notifications AssurAppCI',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(''),
      );

      const DarwinNotificationDetails iosPlatformChannelSpecifics =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
      );

      await _notificationsPlugin.show(
        id: id,
      );

      print('✅ Notification affichée: $title');

    } catch (e) {
      print('❌ Erreur affichage notification: $e');
    }
  }

  /// Gérer le clic sur une notification
  static void _handleNotificationClick(String payload) {
    try {
      print('=== CLIC NOTIFICATION ===');
      print('Payload: $payload');

      try {
        final data = jsonDecode(payload);
        final type = data['type'];

        print('Type: $type');

        switch (type) {
          case 'annonce':
            print('→ Naviguer vers pharmacie');
            break;
          case 'newsletter':
            print('→ Naviguer vers newsletters');
            break;
          default:
            print('→ Type non géré: $type');
        }
      } catch (e) {
        print('Payload non-JSON: $payload');
      }

    } catch (e) {
      print('❌ Erreur handling notification: $e');
    }
  }

  /// Annuler une notification spécifique
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  /// Annuler toutes les notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}