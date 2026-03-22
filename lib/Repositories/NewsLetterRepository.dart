import 'dart:convert';
import 'package:assurappci/Models/Newsletter.dart';
import 'package:http/http.dart' as http;

class NewsletterRepository {
  final String baseUrl = "http://10.0.2.2:4000/api";

  /// Récupérer liste des abonnements
  Future<List<Newsletter>?> recupererAbonnements(String codeUtilisateur) async {
    try {
      final url = Uri.parse("$baseUrl/newsLetters/abonnement");

      print('=== RÉCUPÉRATION ABONNEMENTS ===');
      print('URL: $url');

      final reponse = await http.post(
        url,
        headers: {"Content-Type": "application/json"},body: jsonEncode({
        'codeUtilisateur':codeUtilisateur
      })
      );

      print('Status: ${reponse.statusCode}');

      if (reponse.statusCode == 200) {
        final Map<String, dynamic> corpsReponse = jsonDecode(reponse.body);

        if (corpsReponse['success'] == true && corpsReponse['data'] != null) {
          List<dynamic> donnees = corpsReponse['data'];
          return donnees.map((d) => Newsletter.fromJson(d)).toList();
        }
      }

      return [];
    } catch (e) {
      print('❌ Erreur recupererAbonnements: $e');
      return [];
    }
  }

  /// S'abonner à une pharmacie
  Future<String?> sabonnerPharmacie(String codePharmacie, String codeUtilisateur) async {
    try {
      final url = Uri.parse("$baseUrl/newsletters/sabonner");

      final reponse = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "codePharmacie": codePharmacie,
          "codeUtilisateur": codeUtilisateur,
        }),
      );

      if (reponse.statusCode == 200) {
        final Map<String, dynamic> donnees = jsonDecode(reponse.body);
        return donnees['message'];
      }

      return null;
    } catch (e) {
      print('❌ Erreur sabonnerPharmacie: $e');
      return null;
    }
  }

  /// Désactiver un abonnement
  Future<String?> desactiverAbonnement(String codePharmacie, String codeUtilisateur,) async {
    try {
      final url = Uri.parse("$baseUrl/newsLetters/supprimerabonnement");

      final reponse = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "codePharmacie": codePharmacie,
          "codeUtilisateur": codeUtilisateur,
        }),
      );

      if (reponse.statusCode == 200) {
        final Map<String, dynamic> donnees = jsonDecode(reponse.body);
        return donnees['message'];
      }

      return null;
    } catch (e) {
      print('❌ Erreur desactiverAbonnement: $e');
      return null;
    }
  }
}