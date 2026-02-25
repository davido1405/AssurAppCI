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
  String? get numeroSauvegarde=> _numeroSauvegarde;

  // ---- 4. Initialisation ----
  Future<void> init() async {
    final jwt = await _repository.getSecureJwt();
    final codeUtilisateur = await _repository.recupererCodeUtilisateur();

    if (jwt != null && codeUtilisateur != null) {
      _session = (await _repository.recupererProfil(codeUtilisateur)) as Session?;
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
    String numero="0575006528";
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
        await _repository.secureJwt(_session!.jwt!);
      }
    } catch (e) {
      _errorMessage = 'Connexion échouée, vérifiez vos informations.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> inscription(String nom, String prenom, String numero, String codePin, String typeUtilisateur, String assurance, String adresse) async {
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
      _session = (await _repository.Inscription(nom, prenom, numero, codePin, typeUtilisateur, assurance, adresse)) as Session?;
      if (_session?.jwt != null) {
        await _repository.secureJwt(_session!.jwt!);
        await _repository.sauvegarderNumero(numero);
      }
    } catch (e) {
      _errorMessage = 'Inscription échouée, veuillez réessayer.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deconnexion() async {
    await _repository.removeToken();
    _session = null;
    notifyListeners();
  }
}