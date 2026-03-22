import 'package:assurappci/Models/Annonce.dart';
import 'package:assurappci/Models/Newsletter.dart';
import 'package:assurappci/Repositories/Annonces.dart';
import 'package:assurappci/Repositories/NewsLetterRepository.dart';
import 'package:flutter/foundation.dart';

class Annoncesviewmodel extends ChangeNotifier {
  // 1. Dépendances
  final AnnoncesRepository _annoncesRepository;
  Annoncesviewmodel(this._annoncesRepository);

  // 2. État
  List<Annonce> _annonces = [];
  int _total_annonces=0;
  bool _chargementEnCours = false;
  String? _errorMessage;

  // 3. Getters
  List<Annonce> get annonces => _annonces;
  bool get chargementEnCours => _chargementEnCours;
  int get total_annonces =>_total_annonces;
  String? get errorMessage => _errorMessage;

  // 4. Initialisation
  Future<void> init(String code_utilisateur) async {
    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final donne = await _annoncesRepository.recupererAnnonces(code_utilisateur);

      _annonces=donne['annonces'];
      _total_annonces=donne['total_annonces'];

    } catch (e) {
      _errorMessage = 'Impossible de charger les annonces.';
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }
  }

  // 5. Actions

}