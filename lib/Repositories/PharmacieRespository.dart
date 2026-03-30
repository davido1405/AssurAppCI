// Repositories/PharmacieRepository.dart

import 'dart:convert';
import 'dart:io';

// ✅ Import HTTP pour certaines méthodes
import 'package:http/http.dart' as http;

// ✅ Import DIO pour d'autres méthodes
import 'package:dio/dio.dart';

// ✅ Import path
import 'package:path/path.dart' as path;

// ✅ Import du modèle
import 'package:assurappci/Models/Pharmacie.dart';

class Pharmacierespository {
  // ===== INSTANCE DIO =====
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:4000/api",
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
    ),
  );

  // ===== RÉCUPÉRER TOUTES LES PHARMACIES =====
  Future<List<Pharmacie>?> recupererPharmacie() async {
    try {
      final url = Uri.parse("http://10.0.2.2:4000/api/pharmacie");
      final reponse = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (reponse.statusCode == 200) {
        final Map<String, dynamic> corpsReponse = jsonDecode(reponse.body);
        List<dynamic> pharmacies = corpsReponse['data'];
        List<Pharmacie> listePharmacies = pharmacies
            .map((pharmacie) => Pharmacie.fromJson(pharmacie))
            .toList();
        return listePharmacies;
      }
      return null;
    } catch (e) {
      print('Erreur recupererPharmacie: $e');
      return null;
    }
  }

  /// Mettre à jour le statut de garde
  Future<Map<String, dynamic>> mettreAJourStatutGarde(
    String codePharmacie,
    bool estDeGarde,
  ) async {
    try {
      print('📤 Repository: Envoi statut garde');
      print('URL: http://10.0.2.2:4000/api/pharmacie/modifierstatutgarde');

      final url = Uri.parse(
        'http://10.0.2.2:4000/api/pharmacie/modifierstatutgarde',
      );

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code_pharmacie': codePharmacie,
          'est_de_garde': estDeGarde,
        }),
      );

      print('📥 Status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erreur serveur',
        };
      }
    } catch (e) {
      print('❌ Exception repository: $e');
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  // ===== RECHERCHER PHARMACIE PAR POSITION =====
  Future<List<Pharmacie>?> rechercherPharmaciePosition(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse("http://10.0.2.2:4000/api/pharmacie/rechercher")
          .replace(
            queryParameters: {
              'latitude': latitude.toString(),
              'longitude': longitude.toString(),
            },
          );

      final reponse = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (reponse.statusCode == 200) {
        final Map<String, dynamic> corpsReponse = jsonDecode(reponse.body);
        List<dynamic> pharmacies = corpsReponse['data'];
        List<Pharmacie> listePharmacies = pharmacies
            .map((pharmacie) => Pharmacie.fromJson(pharmacie))
            .toList();
        return listePharmacies;
      }
      return null;
    } catch (e) {
      print('Erreur rechercherPharmaciePosition: $e');
      return null;
    }
  }

  // ===== RECHERCHER PHARMACIE PAR TERME =====
  Future<List<Pharmacie>?> rechercherPharmacieTerme(
    String? terme_saisi,
    double? latitude,
    double? longitude,
  ) async {
    try {
      // Construction des query parameters
      final queryParams = <String, String>{};

      if (terme_saisi != null && terme_saisi.isNotEmpty) {
        queryParams['terme_saisi'] = terme_saisi;
      }
      if (latitude != null) {
        queryParams['latitude'] = latitude.toString();
      }
      if (longitude != null) {
        queryParams['longitude'] = longitude.toString();
      }

      // Construction de l'URL avec les query parameters
      final url = Uri.parse(
        "http://10.0.2.2:4000/api/pharmacie/rechercher",
      ).replace(queryParameters: queryParams);

      print('URL de recherche: $url');

      final reponse = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (reponse.statusCode == 200) {
        final Map<String, dynamic> corpsReponse = jsonDecode(reponse.body);
        List<dynamic> pharmacies = corpsReponse['data'];

        List<Pharmacie> listePharmacies = pharmacies
            .map((pharmacie) => Pharmacie.fromJson(pharmacie))
            .toList();

        return listePharmacies;
      } else {
        print('Erreur API: ${reponse.statusCode} - ${reponse.body}');
        return null;
      }
    } catch (e) {
      print('Erreur rechercherPharmacieTerme: $e');
      return null;
    }
  }

  // ===== AJOUTER UNE PHARMACIE (HTTP) =====
  Future<Map<String, dynamic>?> ajouterPharmacie(
    File? image,
    String codeGerant,
    String nomPharmacie,
    String numeroPharmacie,
    String emailPharmacie,
    double? latitudePharmacie,
    double? longitudePharmacie,
    String villePharmacie,
    String adresseFournit,
    String horairesEnSemaine,
    String horairesSamedi,
    String horairesDimanche,
    List<String> assurancesAcceptees,
  ) async {
    try {
      print('=== DÉBUT AJOUT PHARMACIE ===');

      final url = Uri.parse(
        "http://10.0.2.2:4000/api/pharmacie/ajouterPharmacie",
      );

      // ✅ Créer la requête multipart
      var requete = http.MultipartRequest("POST", url);

      // ✅ Ajouter tous les champs texte
      requete.fields['code_gerant'] = codeGerant;
      requete.fields['nom_pharmacie'] = nomPharmacie;
      requete.fields['numero_pharmacie'] = numeroPharmacie;
      requete.fields['email_pharmacie'] = emailPharmacie;
      requete.fields['ville_pharmacie'] = villePharmacie;
      requete.fields['adresse_fournit'] = adresseFournit;
      requete.fields['horaires_en_semaine'] = horairesEnSemaine;
      requete.fields['horaires_samedi'] = horairesSamedi;
      requete.fields['horaires_dimanche'] = horairesDimanche;
      requete.fields['latitudePharmacie'] =
          latitudePharmacie?.toString() ?? '0';
      requete.fields['longitudePharmacie'] =
          longitudePharmacie?.toString() ?? '0';
      requete.fields['liste_assurance_accepte'] = jsonEncode(
        assurancesAcceptees,
      );

      print('Champs envoyés: ${requete.fields}');

      // ✅ Ajouter la photo
      if (image != null) {
        var stream = http.ByteStream(image.openRead());
        var length = await image.length();

        var multipartFile = http.MultipartFile(
          'photo',
          stream,
          length,
          filename: path.basename(image.path),
        );

        requete.files.add(multipartFile);
        print('✅ Photo ajoutée: ${path.basename(image.path)} ($length bytes)');
      } else {
        print('⚠️ Aucune photo fournie');
      }

      // ✅ Envoyer la requête
      print('📤 Envoi de la requête...');
      var streamedResponse = await requete.send();

      // ✅ Lire la réponse
      var response = await http.Response.fromStream(streamedResponse);

      print('📥 Status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print('✅ Succès: $jsonResponse');
        return jsonResponse;
      } else {
        print('❌ Erreur ${response.statusCode}');

        // Essayer de parser le message d'erreur
        try {
          final errorResponse = jsonDecode(response.body);
          return {
            'success': false,
            'message':
                errorResponse['message'] ?? 'Erreur ${response.statusCode}',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Erreur ${response.statusCode}: ${response.body}',
          };
        }
      }
    } catch (e, stackTrace) {
      print('❌ Exception ajouterPharmacie: $e');
      print('Stack trace: $stackTrace');
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ===== AJOUTER ASSURANCES ACCEPTÉES =====
  Future<String?> ajouterAssuranceAcceptees(
    String codePharmacie,
    List<String> assurance,
  ) async {
    try {
      final url = Uri.parse(
        "http://10.0.2.2:4000/api/pharmacie/ajouterassurance",
      );

      final reponse = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "codePharmacie": codePharmacie,
          "liste_assurance": assurance,
        }),
      );

      if (reponse.statusCode == 200) {
        return "Assurance(s) ajoutée(s) avec succès à la liste des assurances acceptées";
      }
      return null;
    } catch (e) {
      print('Erreur ajouterAssuranceAcceptees: $e');
      return null;
    }
  }

  // ===== RÉCUPÉRER PROFIL PHARMACIE =====
  Future<Pharmacie?> recupererProfilPharmacie(String codeGerant) async {
    try {
      final url = Uri.parse(
        "http://10.0.2.2:4000/api/pharmacie/profilPharmacie",
      );

      final reponse = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"code_gerant": codeGerant}),
      );

      if (reponse.statusCode == 200) {
        final Map<String, dynamic> corpsReponse = jsonDecode(reponse.body);
        Pharmacie profilPharmacie = Pharmacie.fromJson(corpsReponse['data']);
        return profilPharmacie;
      }
      return null;
    } catch (e) {
      print('Erreur recupererProfilPharmacie: $e');
      return null;
    }
  }

  // ===== UPLOAD PHOTO SEULE (DIO) =====
  Future<Map<String, dynamic>?> uploadPhotoPharmacier(
    String codePharmacier,
    File photo_pharmacie,
  ) async {
    try {
      print('=== UPLOAD PHOTO SEULE ===');
      print('Code pharmacie: $codePharmacier');
      print('Photo: ${photo_pharmacie.path}');

      FormData formData = FormData.fromMap({
        'code_pharmacie': codePharmacier,
        'photo_pharmacie': await MultipartFile.fromFile(
          photo_pharmacie.path,
          filename: path.basename(photo_pharmacie.path),
        ),
      });

      Response response = await _dio.post(
        '/pharmacie/upload-photo',
        data: formData,
        onSendProgress: (sent, total) {
          print('Upload: ${(sent / total * 100).toStringAsFixed(0)}%');
        },
      );

      print('✅ Upload réussi: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      print('❌ DioException uploadPhotoPharmacier: ${e.message}');
      if (e.response != null) {
        print('Response: ${e.response?.data}');
      }
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Erreur upload',
      };
    } catch (e) {
      print('❌ Exception uploadPhotoPharmacier: $e');
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ===== METTRE À JOUR PHARMACIE (DIO) =====
  // Repositories/PharmacieRepository.dart

  Future<Map<String, dynamic>?> mettreAJourPharmacie(
    String codePharmacier,
    Map<String, dynamic> modifications,
    File? photo,
  ) async {
    try {
      print('=== MISE À JOUR PHARMACIE ===');

      Map<String, dynamic> formDataMap = {
        'code_pharmacie': codePharmacier, // ✅ OBLIGATOIRE
      };

      // Ajouter les champs modifiés
      if (modifications['nom_pharmacie'] != null) {
        formDataMap['nom_pharmacie'] = modifications['nom_pharmacie'];
      }

      if (modifications['ville_pharmacie'] != null) {
        formDataMap['ville_pharmacie'] = modifications['ville_pharmacie'];
      }

      if (modifications['adresse_fournit'] != null) {
        formDataMap['adresse_fournit'] = modifications['adresse_fournit'];
      }

      if (modifications['numeros_pharmacie'] != null) {
        formDataMap['numero_pharmacie'] = modifications['numeros_pharmacie'];
      }

      if (modifications['email_pharmacie'] != null) {
        formDataMap['email_pharmacie'] = modifications['email_pharmacie'];
      }

      if (modifications['horaireEnSemaine'] != null) {
        formDataMap['horaires_en_semaine'] = modifications['horaireEnSemaine'];
      }
      if (modifications['horaireSamedi'] != null) {
        formDataMap['horaires_samedi'] = modifications['horaireSamedi'];
      }
      if (modifications['horaireDimanche'] != null) {
        formDataMap['horaires_dimanche'] = modifications['horaireDimanche'];
      }else{

        formDataMap['horaires_dimanche'] = "Fermée";
      }
      // Assurances
      if (modifications['assurances'] != null) {
        formDataMap['liste_assurance_accepte'] = jsonEncode(
          modifications['assurances'],
        );
      }

      // Photo
      if (photo != null) {
        formDataMap['photo'] = await MultipartFile.fromFile(
          photo.path,
          filename: path.basename(photo.path),
        );
      }

      FormData formData = FormData.fromMap(formDataMap);

      // ✅ Utiliser la bonne route
      Response response = await _dio.put(
        '/pharmacie/modifierpharmacie', // ✅ Route correcte
        data: formData,
      );

      print('✅ Réponse: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('❌ Erreur: $e');
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }
}
