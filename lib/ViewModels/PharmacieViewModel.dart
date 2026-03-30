// ViewModels/PharmacieViewModel.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:assurappci/Models/Pharmacie.dart';
import 'package:assurappci/Repositories/PharmacieRespository.dart';

class PharmacieViewModel extends ChangeNotifier {

  // ===== 1. DÉPENDANCES =====
  final Pharmacierespository _pharmacierespository;

  PharmacieViewModel(this._pharmacierespository);

  // ===== 2. ÉTAT =====
  List<Pharmacie> _pharmacies = [];
  Pharmacie? _pharmacie;
  bool _chargementEnCours = false;
  String? _errorMessage;

  // ===== 3. GETTERS =====
  List<Pharmacie> get pharmacies => _pharmacies;
  Pharmacie? get pharmacie => _pharmacie;  // ✅ Getter pour pharmacie unique
  bool get chargementEnCours => _chargementEnCours;
  String? get errorMessage => _errorMessage;

  // ===== 4. INITIALISATION (RÉCUPÉRER TOUTES LES PHARMACIES) =====
  Future<List<Pharmacie>> init() async {
    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pharmacies = await _pharmacierespository.recupererPharmacie() ?? [];
      print('✅ ${_pharmacies.length} pharmacies récupérées');
    } catch (e) {
      print('❌ Erreur init: $e');
      _errorMessage = 'Erreur lors du chargement des pharmacies';
      _pharmacies = [];
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }

    return _pharmacies;
  }

  // ===== RÉCUPÉRER PROFIL D'UNE PHARMACIE =====
  Future<Pharmacie?> recupererProfilPharmacie(String codePharmacie) async {
    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pharmacie = await _pharmacierespository.recupererProfilPharmacie(codePharmacie);

      if (_pharmacie != null) {
        print('✅ Profil pharmacie récupéré: ${_pharmacie!.nomPharmacie}');
      } else {
        print('⚠️ Aucun profil trouvé pour: $codePharmacie');
        _errorMessage = 'Profil pharmacie introuvable';
      }
    } catch (e) {
      print('❌ Erreur recupererProfilPharmacie: $e');
      _errorMessage = "Impossible de récupérer le profil de la pharmacie";
      _pharmacie = null;
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }

    return _pharmacie;
  }

  // ===== RECHERCHER DES PHARMACIES =====
  Future<List<Pharmacie>> rechercherPharmacie(String? terme, double? latitude, double? longitude,) async {
    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final resultats = await _pharmacierespository.rechercherPharmacieTerme(
        terme,
        latitude,
        longitude,
      );

      _pharmacies = resultats ?? [];

      print('✅ ${_pharmacies.length} pharmacies trouvées');
    } catch (e) {
      print('❌ Erreur rechercherPharmacie: $e');
      _errorMessage = "Une erreur s'est produite, veuillez réessayer";
      _pharmacies = [];
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }

    return _pharmacies;
  }

  // ===== UPLOAD PHOTO SEULE =====
  Future<void> uploadPhotoPharmacier(String codePharmacier, File photo) async {
    print('=== ViewModel: uploadPhotoPharmacier ===');
    print('Code pharmacie: $codePharmacier');
    print('Photo: ${photo.path}');

    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _pharmacierespository.uploadPhotoPharmacier(
        codePharmacier,
        photo,
      );

      if (result != null && result['success'] == true) {
        print('✅ Photo uploadée avec succès');
        _errorMessage = null;
      } else {
        print('❌ Échec upload photo');
        _errorMessage = result?['message'] ?? 'Erreur lors de l\'upload';
      }
    } catch (e) {
      print('❌ Exception uploadPhotoPharmacier: $e');
      _errorMessage = 'Erreur: $e';
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }
  }

  // ===== AJOUTER UNE PHARMACIE =====
  Future<void> ajouterPharmacie(File image,String codeGerant, String nomPharmacie, String numeroPharmacie, String emailPharmacie, double? latitudePharmacie, double? longitudePharmacie, String villePharmacie, String adresseFournit, String horairesEnSemaine,String horairesSamedi,String horairesDimanche, List<String> assurancesAcceptees,) async {
    print('=== ViewModel: ajouterPharmacie ===');
    print('Gérant: $codeGerant');
    print('Nom: $nomPharmacie');
    print('Ville: $villePharmacie');
    print('Assurances: $assurancesAcceptees');

    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _pharmacierespository.ajouterPharmacie(
         image,
        codeGerant,
        nomPharmacie,
        numeroPharmacie,
        emailPharmacie,
        latitudePharmacie,
        longitudePharmacie,
        villePharmacie,
        adresseFournit,
        horairesEnSemaine,
        horairesSamedi,
        horairesDimanche,
        assurancesAcceptees,
      );

      // ✅ Gérer le résultat
      if (result != null && result['success'] == true) {
        print('✅ Pharmacie ajoutée avec succès');
        print('Message: ${result['message']}');
        _errorMessage = null;
      } else {
        print('❌ Échec ajout pharmacie');
        _errorMessage = result?['message'] ?? 'Erreur lors de l\'ajout';
        print('Erreur: $_errorMessage');
      }
    } catch (e) {
      print('❌ Exception ajouterPharmacie: $e');
      _errorMessage = 'Erreur: $e';
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }
  }

  // ===== METTRE À JOUR UNE PHARMACIE =====
  Future<void> mettreAJourPharmacie(String codePharmacier, Map<String, dynamic> modifications, File? photo,) async {
    print('=== ViewModel: mettreAJourPharmacie ===');
    print('Code pharmacie: $codePharmacier');
    print('Modifications: $modifications');
    print('Photo: ${photo?.path ?? "Aucune"}');

    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _pharmacierespository.mettreAJourPharmacie(
        codePharmacier,
        modifications,
        photo,
      );

      if (result != null && result['success'] == true) {
        print('✅ Pharmacie mise à jour avec succès');
        _errorMessage = null;
      } else {
        print('❌ Échec mise à jour');
        _errorMessage = result?['message'] ?? 'Erreur lors de la mise à jour';
      }
    } catch (e) {
      print('❌ Exception mettreAJourPharmacie: $e');
      _errorMessage = 'Erreur: $e';
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }
  }


  // ViewModels/PharmacieViewModel.dart

  Future<bool> mettreAJourStatutGarde(String codePharmacie, bool estDeGarde) async {
    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _pharmacierespository.mettreAJourStatutGarde(
        codePharmacie,
        estDeGarde,
      );

      if (result['success'] == true) {
        _chargementEnCours = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Erreur lors de la mise à jour';
        _chargementEnCours = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur: $e';
      _chargementEnCours = false;
      notifyListeners();
      return false;
    }
  }


  // ===== RÉINITIALISER LES ERREURS =====
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ===== RÉINITIALISER L'ÉTAT =====
  void reset() {
    _pharmacies = [];
    _pharmacie = null;
    _chargementEnCours = false;
    _errorMessage = null;
    notifyListeners();
  }
}