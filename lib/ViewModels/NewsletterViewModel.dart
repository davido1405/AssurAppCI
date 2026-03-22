import 'package:assurappci/Models/Newsletter.dart';
import 'package:assurappci/Repositories/NewsLetterRepository.dart';
import 'package:flutter/foundation.dart';

class Newsletterviewmodel extends ChangeNotifier {
  // 1. Dépendances
  final NewsletterRepository _newsletterrepository;
  Newsletterviewmodel(this._newsletterrepository);

  // 2. État
  List<Newsletter> _newsLetter = [];
  bool _chargementEnCours = false;
  String? _errorMessage;

  // 3. Getters
  List<Newsletter> get newsLetter => _newsLetter;
  bool get chargementEnCours => _chargementEnCours;
  String? get errorMessage => _errorMessage;

  // 4. Initialisation
  Future<void> init(String codeUtilisateur) async {
    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _newsLetter = await _newsletterrepository.recupererAbonnements(codeUtilisateur) ?? [];
    } catch (e) {
      _errorMessage = 'Impossible de charger les abonnements.';
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }
  }

  // 5. Actions

  Future<void> sabonner(String codePharmacie, String codeUtilisateur) async {
    _errorMessage = null;

    try {
      await _newsletterrepository.sabonnerPharmacie(codePharmacie, codeUtilisateur);
      // Recharger la liste après abonnement
      await init(codeUtilisateur);
    } catch (e) {
      _errorMessage = "Abonnement échoué.";
      notifyListeners();
    }
  }

  Future<void> desabonner(String codePharmacie, String codeUtilisateur) async {
    _errorMessage = null;

    try {
      await _newsletterrepository.desactiverAbonnement(codePharmacie, codeUtilisateur);
      // Recharger la liste après désabonnement
      await init(codeUtilisateur);
    } catch (e) {
      _errorMessage = "Désabonnement échoué.";
      notifyListeners();
    }
  }
}