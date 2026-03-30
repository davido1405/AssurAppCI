// ViewModels/AuthViewModel.dart

import 'package:assurappci/Services/fcm_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/Session.dart';
import '../Repositories/AuthRepository.dart';

class AuthViewModel extends ChangeNotifier {

  // ---- 1. Dépendances ----
  final Authrepository _repository;
  AuthViewModel(this._repository);

  // ---- 2. État ----
  Session? _session;
  bool _isLoading = false;
  String? _errorMessage;
  String? _numeroSauvegarde;

  // ---- 3. Getters ----
  Session? get session => _session;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get estConnecte => _session != null;
  String? get numeroSauvegarde => _numeroSauvegarde;

  // ---- 4. Initialisation ----
  Future<void> init() async {
    final jwt = await _repository.getSecureJwt();
    final codeUtilisateur = await _repository.recupererCodeUtilisateur();

    _numeroSauvegarde = await _repository.recupererNumero();

    if (jwt != null && jwt.isNotEmpty &&
        codeUtilisateur != null && codeUtilisateur.isNotEmpty) {
      final profil = (await _repository.recupererProfil(codeUtilisateur)) as Session?;

      if (profil != null) {
        _session = profil;
      } else {
        print('Profil null, suppression du token');
        await _repository.removeToken();
        _session = null;
      }
    }
    notifyListeners();
  }

  // ---- 5. Actions ----
  Future<void> connexion(String codePin) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    //Récupérer le numéro
    //String? numero=await _repository.recupererNumero();
    String numero="+2250508091013";

    // Validation
    if (numero.length < 10) {
      _errorMessage = 'Veuillez vérifier votre numéro';
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (codePin.length < 6) {
      _errorMessage = 'Veuillez vérifier votre code pin';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _session = (await _repository.Connexion(numero, codePin)) as Session?;

      if (_session?.jwt != null) {
        await _repository.secureJwt(_session!.jwt);
        await _repository.sauvegarderNumero(numero);

        // ✅ CORRECTION: Utiliser les bonnes méthodes FCMService
        try {
          // Récupérer le token sauvegardé (déjà initialisé dans main.dart)
          String? token = await FCMService.getSavedToken();

          if (token != null) {
            print("📱 Token FCM: ${token.substring(0, 30)}...");

            // Envoyer au serveur
            bool success = await FCMService.sendTokenToServer(_session!.codeUtilisateur);

            if (success) {
              print("✅ Token FCM enregistré sur le serveur");
            } else {
              print("⚠️ Échec enregistrement token FCM");
            }
          } else {
            print("⚠️ Aucun token FCM disponible");
          }
        } catch (e) {
          print("❌ Erreur envoi token FCM: $e");
          // Ne pas bloquer la connexion si l'envoi du token échoue
        }
      }
    } catch (e) {
      _errorMessage = 'Connexion échouée, vérifiez vos informations.';
      print("❌ Erreur connexion: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> inscription(String nom, String prenom, String numero, String codePin, String typeUtilisateur, String assurance, String adresse, String villeUtilisateur,) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Validation
    if (nom.isEmpty) {
      _errorMessage = 'Veuillez vérifier votre nom';
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (prenom.isEmpty) {
      _errorMessage = 'Veuillez vérifier votre prénom';
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (numero.length < 10) {
      _errorMessage = 'Veuillez vérifier votre numéro';
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (codePin.length < 6) {
      _errorMessage = 'Veuillez vérifier votre code pin';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _session = (await _repository.Inscription(
        nom,
        prenom,
        numero,
        codePin,
        typeUtilisateur,
        assurance,
        adresse,
        villeUtilisateur,
      )) as Session?;

      if (_session?.jwt != null) {
        await _repository.secureJwt(_session!.jwt);
        await _repository.sauvegarderNumero(numero);

        // ✅ AJOUTER: Envoyer le token FCM après inscription aussi
        try {
          String? token = await FCMService.getSavedToken();

          if (token != null) {
            bool success = await FCMService.sendTokenToServer(_session!.codeUtilisateur);

            if (success) {
              print("✅ Token FCM enregistré après inscription");
            }
          }
        } catch (e) {
          print("❌ Erreur envoi token FCM après inscription: $e");
        }
      }

    } catch (e) {
      _errorMessage = 'Inscription échouée, veuillez réessayer.';
      print("❌ Erreur inscription: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deconnexion() async {
    // ✅ AJOUTER: Supprimer le token du serveur avant déconnexion
    if (_session?.codeUtilisateur != null) {
      try {
        await FCMService.removeTokenFromServer(_session!.codeUtilisateur);
        print("✅ Token FCM supprimé du serveur");
      } catch (e) {
        print("❌ Erreur suppression token FCM: $e");
      }
    }

    await _repository.removeToken();
    _session = null;
    notifyListeners();
  }
}