// Repositories/AbonnementPharmacieRepository.dart

import 'package:dio/dio.dart';

class Abonnementpharmacierepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "http://10.0.2.2:4000/api",
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
  ));

  // ===== RÉCUPÉRER TOUS LES FORFAITS DISPONIBLES =====
  Future<Map<String, dynamic>?> recupererForfaits() async {
    try {
      print('=== RÉCUPÉRATION FORFAITS ===');

      Response response = await _dio.get('/abonnements/forfaits');

      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }

      return null;
    } on DioException catch (e) {
      print('❌ DioException recupererForfaits: ${e.message}');
      if (e.response != null) {
        print('Response: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      print('❌ Exception recupererForfaits: $e');
      return null;
    }
  }

  // ===== RÉCUPÉRER L'ABONNEMENT ACTIF D'UNE PHARMACIE =====
  Future<Map<String, dynamic>?> recupererAbonnementActif(String codePharmacier) async {
    try {
      print('=== RÉCUPÉRATION ABONNEMENT ACTIF ===');
      print('Code pharmacie: $codePharmacier');

      Response response = await _dio.get('/abonnements/actif?code_pharmacie=$codePharmacier');

      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }

      return null;
    } on DioException catch (e) {
      print('❌ DioException recupererAbonnementActif: ${e.message}');
      if (e.response != null) {
        print('Response: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      print('❌ Exception recupererAbonnementActif: $e');
      return null;
    }
  }

  // ===== VÉRIFIER L'ACCÈS À UNE FONCTIONNALITÉ =====
  Future<Map<String, dynamic>?> verifierAccesFonctionnalite({required String codePharmacier, required String codeFonctionnalite,}) async {
    try {
      print('=== VÉRIFICATION ACCÈS FONCTIONNALITÉ ===');
      print('Code pharmacie: $codePharmacier');
      print('Code fonctionnalité: $codeFonctionnalite');

      Response response = await _dio.post(
        '/abonnements/verifier-acces',
        data: {
          'code_pharmacie': codePharmacier,
          'code_fonctionnalite': codeFonctionnalite,
        },
      );

      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }

      return null;
    } on DioException catch (e) {
      print('❌ DioException verifierAccesFonctionnalite: ${e.message}');

      if (e.response != null) {
        print('Response: ${e.response?.data}');

        // Si l'accès est refusé (403), retourner quand même la réponse
        if (e.response?.statusCode == 403) {
          return e.response?.data as Map<String, dynamic>?;
        }
      }

      return null;
    } catch (e) {
      print('❌ Exception verifierAccesFonctionnalite: $e');
      return null;
    }
  }

  // ===== SOUSCRIRE À UN FORFAIT =====
  Future<Map<String, dynamic>?> souscrireForfait({required String code_gerant, required String nomForfait, required String modePaiement, String? referencePaiement,}) async {
    try {
      print('=== SOUSCRIPTION FORFAIT ===');
      print('Code pharmacie: $code_gerant');
      print('ID Forfait: $nomForfait');
      print('Mode paiement: $modePaiement');

      Response response = await _dio.post(
        '/abonnements/souscrire',
        data: {
          'code_gerant': code_gerant,
          'nom_forfait': nomForfait,
          'mode_paiement': modePaiement,
          'reference_paiement': referencePaiement,
        },
      );

      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>?;
      }

      return null;
    } on DioException catch (e) {
      print('❌ DioException souscrireForfait: ${e.message}');

      if (e.response != null) {
        print('Response: ${e.response?.data}');

        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Erreur de souscription',
        };
      }

      return {
        'success': false,
        'message': 'Erreur de connexion',
      };
    } catch (e) {
      print('❌ Exception souscrireForfait: $e');
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  // ===== RÉCUPÉRER L'HISTORIQUE DES ABONNEMENTS =====
  Future<Map<String, dynamic>?> historiqueAbonnements(String codePharmacier) async {
    try {
      print('=== HISTORIQUE ABONNEMENTS ===');
      print('Code pharmacie: $codePharmacier');

      Response response = await _dio.get('/abonnements/historique/$codePharmacier');

      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }

      return null;
    } on DioException catch (e) {
      print('❌ DioException historiqueAbonnements: ${e.message}');
      if (e.response != null) {
        print('Response: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      print('❌ Exception historiqueAbonnements: $e');
      return null;
    }
  }

  // ===== ANNULER UN ABONNEMENT =====
  Future<Map<String, dynamic>?> annulerAbonnement({required String codePharmacier, required int idAbonnement, String? motif,}) async {
    try {
      print('=== ANNULATION ABONNEMENT ===');
      print('Code pharmacie: $codePharmacier');
      print('ID Abonnement: $idAbonnement');

      Response response = await _dio.put(
        '/abonnements/annuler',
        data: {
          'code_pharmacie': codePharmacier,
          'id_abonnement': idAbonnement,
          'motif': motif,
        },
      );

      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }

      return null;
    } on DioException catch (e) {
      print('❌ DioException annulerAbonnement: ${e.message}');

      if (e.response != null) {
        print('Response: ${e.response?.data}');

        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Erreur d\'annulation',
        };
      }

      return {
        'success': false,
        'message': 'Erreur de connexion',
      };
    } catch (e) {
      print('❌ Exception annulerAbonnement: $e');
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  // ===== INITIER UN PAIEMENT (Wave, Orange Money, etc.) =====
  Future<Map<String, dynamic>?> initierPaiement({required String codePharmacier, required int idForfait, required String modePaiement, required double montant, String? numeroTelephone,}) async {
    try {
      print('=== INITIER PAIEMENT ===');
      print('Code pharmacie: $codePharmacier');
      print('Montant: $montant');
      print('Mode: $modePaiement');

      Response response = await _dio.post(
        '/abonnements/paiement/initier',
        data: {
          'code_pharmacie': codePharmacier,
          'id_forfait': idForfait,
          'mode_paiement': modePaiement,
          'montant': montant,
          'numero_telephone': numeroTelephone,
        },
      );

      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>?;
      }

      return null;
    } on DioException catch (e) {
      print('❌ DioException initierPaiement: ${e.message}');

      if (e.response != null) {
        print('Response: ${e.response?.data}');

        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Erreur de paiement',
        };
      }

      return {
        'success': false,
        'message': 'Erreur de connexion',
      };
    } catch (e) {
      print('❌ Exception initierPaiement: $e');
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  // ===== VÉRIFIER LE STATUT D'UN PAIEMENT =====
  Future<Map<String, dynamic>?> verifierStatutPaiement(String referencePaiement) async {
    try {
      print('=== VÉRIFICATION STATUT PAIEMENT ===');
      print('Référence: $referencePaiement');

      Response response = await _dio.get(
        '/abonnements/paiement/statut/$referencePaiement',
      );

      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }

      return null;
    } on DioException catch (e) {
      print('❌ DioException verifierStatutPaiement: ${e.message}');
      if (e.response != null) {
        print('Response: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      print('❌ Exception verifierStatutPaiement: $e');
      return null;
    }
  }

  // ===== RÉCUPÉRER LES STATISTIQUES D'UTILISATION =====
  Future<Map<String, dynamic>?> statistiquesUtilisation(String codePharmacier) async {
    try {
      print('=== STATISTIQUES UTILISATION ===');
      print('Code pharmacie: $codePharmacier');

      Response response = await _dio.get(
        '/abonnements/utilisation/$codePharmacier',
      );

      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }

      return null;
    } on DioException catch (e) {
      print('❌ DioException statistiquesUtilisation: ${e.message}');
      if (e.response != null) {
        print('Response: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      print('❌ Exception statistiquesUtilisation: $e');
      return null;
    }
  }

  // ===== RÉCUPÉRER LES LIMITES DU FORFAIT ACTUEL =====
  Future<Map<String, dynamic>?> limitesForfait(String codePharmacier) async {
    try {
      print('=== LIMITES FORFAIT ===');
      print('Code pharmacie: $codePharmacier');

      Response response = await _dio.get(
        '/abonnements/limites/$codePharmacier',
      );

      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }

      return null;
    } on DioException catch (e) {
      print('❌ DioException limitesForfait: ${e.message}');
      if (e.response != null) {
        print('Response: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      print('❌ Exception limitesForfait: $e');
      return null;
    }
  }

  // ===== DEMANDER UN REMBOURSEMENT =====
  Future<Map<String, dynamic>?> demanderRemboursement({required String codePharmacier, required int idAbonnement, required String motif,}) async {
    try {
      print('=== DEMANDE REMBOURSEMENT ===');
      print('Code pharmacie: $codePharmacier');
      print('ID Abonnement: $idAbonnement');
      print('Motif: $motif');

      Response response = await _dio.post(
        '/abonnement/remboursement',
        data: {
          'code_pharmacie': codePharmacier,
          'id_abonnement': idAbonnement,
          'motif': motif,
        },
      );

      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>?;
      }

      return null;
    } on DioException catch (e) {
      print('❌ DioException demanderRemboursement: ${e.message}');

      if (e.response != null) {
        print('Response: ${e.response?.data}');

        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Erreur de remboursement',
        };
      }

      return {
        'success': false,
        'message': 'Erreur de connexion',
      };
    } catch (e) {
      print('❌ Exception demanderRemboursement: $e');
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  // ===== COMPARER LES FORFAITS =====
  Future<Map<String, dynamic>?> comparerForfaits() async {
    try {
      print('=== COMPARAISON FORFAITS ===');

      Response response = await _dio.get('/abonnements/comparaison');

      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }

      return null;
    } on DioException catch (e) {
      print('❌ DioException comparerForfaits: ${e.message}');
      if (e.response != null) {
        print('Response: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      print('❌ Exception comparerForfaits: $e');
      return null;
    }
  }
}