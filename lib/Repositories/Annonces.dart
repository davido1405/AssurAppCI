// Repositories/AnnoncesRepository.dart

import 'dart:convert';
import 'package:assurappci/Models/Annonce.dart';
import 'package:http/http.dart' as http;

class AnnoncesRepository {
  final String baseUrl = "http://10.0.2.2:4000/api";

  /// Envoyer une annonce
  Future<Map<String, dynamic>?> envoyerAnnonce(String titre, String contenu, String codePharmacien, String typeAnnonce,) async {
    try {
      final url = Uri.parse("$baseUrl/annonces/envoyer");

      print('=== ENVOI ANNONCE ===');
      print('URL: $url');

      final result = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "titre": titre,
          "contenu": contenu,
          "code_gerant": codePharmacien,
          "type_annonce": typeAnnonce,
        }),
      );

      print('Status: ${result.statusCode}');

      if (result.statusCode == 200) {
        final corpsReponse = jsonDecode(result.body);
        return corpsReponse['data'];
      }

      return null;
    } catch (e) {
      print('❌ Erreur envoyerAnnonce: $e');
      return null;
    }
  }

  /// Récupérer toutes les annonces d'une pharmacie
  Future<Map<String,dynamic>> recupererAnnonces(String code_utilisateur) async {
    try {
      final url = Uri.parse("$baseUrl/annonces/pharmacie?code_gerant=$code_utilisateur");

      print('=== RÉCUPÉRATION ANNONCES ===');
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
          return {"total_annonces":corpsReponse['total_annonces'],"annonces":donnees.map((d) => Annonce.fromJson(d)).toList()};
        }
      }

      return {};
    } catch (e) {
      print('❌ Erreur recupererAnnonces: $e');
      return {};
    }
  }

  /// Supprimer une annonce
  Future<bool> supprimerAnnonce(int idAnnonce) async {
    try {
      final url = Uri.parse("$baseUrl/annonces?id_annonce=$idAnnonce");

      final result = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      return result.statusCode == 200;
    } catch (e) {
      print('❌ Erreur supprimerAnnonce: $e');
      return false;
    }
  }
}