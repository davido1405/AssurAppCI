// Repositories/NotificationsRepository.dart

import 'dart:convert';
import 'package:assurappci/Models/Notifications.dart';
import 'package:http/http.dart' as http;

class NotificationsRepository {
  final String baseUrl = "http://10.0.2.2:4000/api";

  ///Compter les notifications
  Future<int>compterNotification(String code_utilisateur)async{
    try {
      final url = Uri.parse("$baseUrl/notifications?code_utilisateur=$code_utilisateur");

      print('=== DECOMPTE NOTIFICATIONS ===');
      print('URL: $url');

      final result = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('Status: ${result.statusCode}');

      if (result.statusCode == 200) {
        final corpsReponse = jsonDecode(result.body);

        if (corpsReponse['success'] == true && corpsReponse['data'] != null) {
          List<dynamic> donnees = corpsReponse['data'];
          List<Notifications>notifications= donnees.map((d) => Notifications.fromJson(d)).toList();
          print(notifications);
          int nombreNotif=notifications.where((n)=>n.statutLecture=="Non lu").length;
          return nombreNotif;
        }
      }

      return 0;
    } catch (e) {
      print('❌ Erreur decompte notification: $e');
      return 0;
    }
  }
  /// Récupérer toutes les notifications d'un utilisateur
  Future<List<Notifications>?> recupererNotifications(String codeUtilisateur,) async {
    try {
      final url = Uri.parse("$baseUrl/notifications?code_utilisateur=$codeUtilisateur");

      print('=== RÉCUPÉRATION NOTIFICATIONS ===');
      print('URL: $url');

      final result = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('Status: ${result.statusCode}');

      if (result.statusCode == 200) {
        final corpsReponse = jsonDecode(result.body);

        if (corpsReponse['success'] == true && corpsReponse['data'] != null) {
          List<dynamic> donnees = corpsReponse['data'];
          List<Notifications>notifications= donnees.map((d) => Notifications.fromJson(d)).toList();
          print(notifications);
          return notifications.toList();
        }
      }

      return [];
    } catch (e) {
      print('❌ Erreur recupererNotifications: $e');
      return [];
    }
  }

  /// Marquer une notification comme lue
  Future<bool> marquerCommeLu(int idNotification,String code_utilisateur) async {
    try {
      final url = Uri.parse("$baseUrl/notifications/lireNotifications?id_annonce=$idNotification");

      final result = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},body: jsonEncode({
        "code_utilisateur":code_utilisateur
      })
      );

      if (result.statusCode == 200) {
        final corpsReponse = jsonDecode(result.body);
        return corpsReponse['success'] == true;
      }

      return false;
    } catch (e) {
      print('❌ Erreur marquerCommeLu: $e');
      return false;
    }
  }

  /// Supprimer une notification
  Future<bool> supprimerNotification(int idNotification,String code_utilisateur) async {
    try {
      final url = Uri.parse("$baseUrl/notifications?id_annonce=$idNotification");

      final result = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},body: jsonEncode({
        "code_utilisateur":code_utilisateur
      })
      );

      return result.statusCode == 200;
    } catch (e) {
      print('❌ Erreur supprimerNotification: $e');
      return false;
    }
  }

  ///
}