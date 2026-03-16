// Services/fcm_service.dart

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:assurappci/Services/notifications_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static const String _baseUrl = "http://10.0.2.2:4000/api";

  static Future<void> initialize() async {
    print('=== INITIALISATION FCM ===');

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('❌ Permission refusée');
      return;
    }

    print('✅ Permission accordée');

    String? token = await getToken();

    if (token != null) {
      print('✅ Token obtenu');
      await _saveTokenLocally(token);
    }

    _setupMessageHandlers();

    _messaging.onTokenRefresh.listen((newToken) {
      print('🔄 Token rafraîchi');
      _saveTokenLocally(newToken);
    });
  }

  static Future<String?> getToken() async {
    try {
      String? token = await _messaging.getToken();
      return token;
    } catch (e) {
      print('❌ Erreur token: $e');
      return null;
    }
  }

  static Future<void> _saveTokenLocally(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      print('💾 Token sauvegardé');
    } catch (e) {
      print('❌ Erreur sauvegarde: $e');
    }
  }

  static Future<String?> getSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('fcm_token');
    } catch (e) {
      print('❌ Erreur lecture: $e');
      return null;
    }
  }

  static void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📬 Message reçu (foreground)');
      print('Titre: ${message.notification?.title}');

      if (message.notification != null) {
        NotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: message.notification!.title ?? 'Notification',
          body: message.notification!.body ?? '',
          payload: jsonEncode(message.data), // ✅ Passer les données
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 Notification cliquée (background)');
      _handleNotificationClick(message);
    });

    _checkInitialMessage();
  }

  static Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      print('📱 App ouverte via notification');
      _handleNotificationClick(initialMessage);
    }
  }

  static void _handleNotificationClick(RemoteMessage message) {
    print('=== CLIC NOTIFICATION ===');
    print('Type: ${message.data['type']}');
    // TODO: Navigation
  }

  static Future<bool> sendTokenToServer(String codeUtilisateur) async {
    String? token = await getSavedToken();

    if (token == null) {
      print('❌ Aucun token');
      return false;
    }

    try {
      print('📤 Envoi token...');

      final url = Uri.parse("$_baseUrl/utilisateur/fcm-token");
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fcm_token': token,
          'code_utilisateur': codeUtilisateur,
          'device_type': 'android',
        }),
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ Token envoyé');
          return true;
        }
      }

      return false;

    } catch (e) {
      print('❌ Erreur: $e');
      return false;
    }
  }

  static Future<bool> removeTokenFromServer(String codeUtilisateur) async {
    String? token = await getSavedToken();

    if (token == null) return false;

    try {
      final url = Uri.parse("$_baseUrl/utilisateur/fcm-token");
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fcm_token': token,
          'code_utilisateur': codeUtilisateur,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Token supprimé');

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('fcm_token');

        return true;
      }

      return false;

    } catch (e) {
      print('❌ Erreur: $e');
      return false;
    }
  }
}