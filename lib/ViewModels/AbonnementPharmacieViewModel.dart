// ViewModels/AbonnementPharmacieViewModel.dart

import 'package:flutter/foundation.dart';
import 'package:assurappci/Models/AbonnementPharmacie.dart';
import 'package:assurappci/Repositories/AbonnementPharmacieRepository.dart';

class Abonnementpharmacieviewmodel extends ChangeNotifier {
  final Abonnementpharmacierepository _abonnementpharmacie;

  Abonnementpharmacieviewmodel(this._abonnementpharmacie);

  // ===== ÉTAT =====
  List<Forfait> _forfaits = [];
  AbonnementPharmacie? _abonnementActif;
  List<HistoriqueAbonnement> _historique = [];
  Map<String, AccesFonctionnalite> _accesFonctionnalites = {};
  Map<String, StatistiqueUtilisation> _statistiques = {};

  bool _chargementEnCours = false;
  String? _errorMessage;

  // ===== GETTERS =====
  List<Forfait> get forfaits => _forfaits;
  AbonnementPharmacie? get abonnementActif => _abonnementActif;
  List<HistoriqueAbonnement> get historique => _historique;
  Map<String, AccesFonctionnalite> get accesFonctionnalites => _accesFonctionnalites;
  Map<String, StatistiqueUtilisation> get statistiques => _statistiques;
  bool get chargementEnCours => _chargementEnCours;
  String? get errorMessage => _errorMessage;

  // Getter pour le nom du forfait actuel
  String get nomForfaitActuel => _abonnementActif?.nomForfait ?? 'Gratuit';

  // Getter pour le prix du forfait actuel
  double get prixForfaitActuel => _abonnementActif?.prix ?? 0.0;

  // Getter pour les jours restants
  int get joursRestants => _abonnementActif?.joursRestants ?? 0;

  // ===== MÉTHODES =====

  // Récupérer tous les forfaits disponibles
  Future<List<Forfait>?> chargerForfaits() async {
    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('=== CHARGEMENT FORFAITS ===');

      final result = await _abonnementpharmacie.recupererForfaits();

      if (result != null && result['success'] == true) {
        final data = result['data'] as List<dynamic>;

        _forfaits = data.map((json) => Forfait.fromJson(json)).toList();

        print('✅ ${_forfaits.length} forfaits chargés');
        _errorMessage = null;

        return _forfaits;
      } else {
        _errorMessage = result?['message'] ?? 'Erreur de chargement des forfaits';
        print('❌ Erreur: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'Erreur: $e';
      print('❌ Exception chargerForfaits: $e');
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }
  }

  // Récupérer l'abonnement actif d'une pharmacie
  Future<void> chargerAbonnementActif(String codePharmacier) async {
    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('=== CHARGEMENT ABONNEMENT ACTIF ===');
      print('Code pharmacie: $codePharmacier');

      final result = await _abonnementpharmacie.recupererAbonnementActif(codePharmacier);

      if (result != null && result['success'] == true) {
        _abonnementActif = AbonnementPharmacie.fromJson(result['data']);

        print('✅ Abonnement actif: ${_abonnementActif?.nomForfait}');
        _errorMessage = null;
      } else {
        _errorMessage = result?['message'] ?? 'Erreur de chargement';
        print('❌ Erreur: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'Erreur: $e';
      print('❌ Exception chargerAbonnementActif: $e');
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }
  }

  // Vérifier l'accès à une fonctionnalité
  Future<AccesFonctionnalite?> verifierAccesFonctionnalite({required String codePharmacier, required String codeFonctionnalite,}) async {
    try {
      print('=== VÉRIFICATION ACCÈS ===');
      print('Fonctionnalité: $codeFonctionnalite');

      final result = await _abonnementpharmacie.verifierAccesFonctionnalite(
        codePharmacier: codePharmacier,
        codeFonctionnalite: codeFonctionnalite,
      );

      if (result != null && result['success'] == true) {
        final acces = AccesFonctionnalite.fromJson(result['data']);

        // Sauvegarder dans le cache
        _accesFonctionnalites[codeFonctionnalite] = acces;
        notifyListeners();

        print(acces.acces ? '✅ Accès autorisé' : '❌ Accès refusé: ${acces.raison}');

        return acces;
      } else if (result != null && result['upgrade_required'] == true) {
        // Accès refusé, upgrade requis
        final acces = AccesFonctionnalite(
          acces: false,
          raison: result['message'] ?? 'Fonctionnalité non disponible',
        );

        _accesFonctionnalites[codeFonctionnalite] = acces;
        notifyListeners();

        return acces;
      }

      return null;
    } catch (e) {
      print('❌ Exception verifierAccesFonctionnalite: $e');
      return null;
    }
  }

  // Souscrire à un forfait
  Future<bool> souscrireForfait({required String codePharmacier, required String nomForfait, required String modePaiement, String? referencePaiement,}) async {
    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('=== SOUSCRIPTION FORFAIT ===');
      print('ID Forfait: $nomForfait');
      print('Mode paiement: $modePaiement');

      final result = await _abonnementpharmacie.souscrireForfait(
        code_gerant: codePharmacier,
        nomForfait: nomForfait,
        modePaiement: modePaiement,
        referencePaiement: referencePaiement,
      );

      if (result != null && result['success'] == true) {
        print('✅ Souscription réussie');

        // Recharger l'abonnement actif
        await chargerAbonnementActif(codePharmacier);

        _errorMessage = null;
        return true;
      } else {
        _errorMessage = result?['message'] ?? 'Erreur de souscription';
        print('❌ Erreur: $_errorMessage');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur: $e';
      print('❌ Exception souscrireForfait: $e');
      return false;
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }
  }

  // Charger l'historique des abonnements
  Future<void> chargerHistorique(String codePharmacier) async {
    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('=== CHARGEMENT HISTORIQUE ===');

      final result = await _abonnementpharmacie.historiqueAbonnements(codePharmacier);

      if (result != null && result['success'] == true) {
        final data = result['data'] as List<dynamic>;

        _historique = data.map((json) => HistoriqueAbonnement.fromJson(json)).toList();

        print('✅ ${_historique.length} abonnements dans l\'historique');
        _errorMessage = null;
      } else {
        _errorMessage = result?['message'] ?? 'Erreur de chargement';
        print('❌ Erreur: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'Erreur: $e';
      print('❌ Exception chargerHistorique: $e');
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }
  }

  // Annuler un abonnement
  Future<bool> annulerAbonnement({required String codePharmacier, required int idAbonnement, String? motif,}) async {
    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('=== ANNULATION ABONNEMENT ===');
      print('ID Abonnement: $idAbonnement');

      final result = await _abonnementpharmacie.annulerAbonnement(
        codePharmacier: codePharmacier,
        idAbonnement: idAbonnement,
        motif: motif,
      );

      if (result != null && result['success'] == true) {
        print('✅ Abonnement annulé');

        // Recharger l'abonnement actif et l'historique
        await chargerAbonnementActif(codePharmacier);
        await chargerHistorique(codePharmacier);

        _errorMessage = null;
        return true;
      } else {
        _errorMessage = result?['message'] ?? 'Erreur d\'annulation';
        print('❌ Erreur: $_errorMessage');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur: $e';
      print('❌ Exception annulerAbonnement: $e');
      return false;
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }
  }

  // Initier un paiement
  Future<Map<String, dynamic>?> initierPaiement({required String codePharmacier, required int idForfait, required String modePaiement, required double montant, String? numeroTelephone,}) async {
    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('=== INITIER PAIEMENT ===');
      print('Montant: $montant');
      print('Mode: $modePaiement');

      final result = await _abonnementpharmacie.initierPaiement(
        codePharmacier: codePharmacier,
        idForfait: idForfait,
        modePaiement: modePaiement,
        montant: montant,
        numeroTelephone: numeroTelephone,
      );

      if (result != null && result['success'] == true) {
        print('✅ Paiement initié');
        _errorMessage = null;
        return result;
      } else {
        _errorMessage = result?['message'] ?? 'Erreur de paiement';
        print('❌ Erreur: $_errorMessage');
        return result;
      }
    } catch (e) {
      _errorMessage = 'Erreur: $e';
      print('❌ Exception initierPaiement: $e');
      return null;
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }
  }

  // Vérifier le statut d'un paiement
  Future<Map<String, dynamic>?> verifierStatutPaiement(String referencePaiement) async {
    try {
      print('=== VÉRIFICATION STATUT PAIEMENT ===');
      print('Référence: $referencePaiement');

      final result = await _abonnementpharmacie.verifierStatutPaiement(referencePaiement);

      if (result != null) {
        print('Statut: ${result['statut']}');
        return result;
      }

      return null;
    } catch (e) {
      print('❌ Exception verifierStatutPaiement: $e');
      return null;
    }
  }

  // Charger les statistiques d'utilisation
  Future<void> chargerStatistiquesUtilisation(String codePharmacier) async {
    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('=== CHARGEMENT STATISTIQUES ===');

      final result = await _abonnementpharmacie.statistiquesUtilisation(codePharmacier);

      if (result != null && result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;

        _statistiques.clear();
        data.forEach((key, value) {
          _statistiques[key] = StatistiqueUtilisation.fromJson(value);
        });

        print('✅ Statistiques chargées');
        _errorMessage = null;
      } else {
        _errorMessage = result?['message'] ?? 'Erreur de chargement';
        print('❌ Erreur: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'Erreur: $e';
      print('❌ Exception chargerStatistiquesUtilisation: $e');
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }
  }

  // Charger les limites du forfait actuel
  Future<Map<String, LimiteFonctionnalite>?> chargerLimitesForfait(String codePharmacier) async {
    try {
      print('=== CHARGEMENT LIMITES ===');

      final result = await _abonnementpharmacie.limitesForfait(codePharmacier);

      if (result != null && result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;

        final limites = <String, LimiteFonctionnalite>{};
        data.forEach((key, value) {
          limites[key] = LimiteFonctionnalite.fromJson(value);
        });

        print('✅ Limites chargées');
        return limites;
      }

      return null;
    } catch (e) {
      print('❌ Exception chargerLimitesForfait: $e');
      return null;
    }
  }

  // Demander un remboursement
  Future<bool> demanderRemboursement({required String codePharmacier, required int idAbonnement, required String motif,}) async {
    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('=== DEMANDE REMBOURSEMENT ===');

      final result = await _abonnementpharmacie.demanderRemboursement(
        codePharmacier: codePharmacier,
        idAbonnement: idAbonnement,
        motif: motif,
      );

      if (result != null && result['success'] == true) {
        print('✅ Demande envoyée');
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = result?['message'] ?? 'Erreur de remboursement';
        print('❌ Erreur: $_errorMessage');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur: $e';
      print('❌ Exception demanderRemboursement: $e');
      return false;
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }
  }

  // Comparer les forfaits
  Future<List<ComparaisonForfait>?> comparerForfaits() async {
    try {
      print('=== COMPARAISON FORFAITS ===');

      final result = await _abonnementpharmacie.comparerForfaits();

      if (result != null && result['success'] == true) {
        final data = result['data'] as List<dynamic>;

        final comparaison = data.map((json) => ComparaisonForfait.fromJson(json)).toList();

        print('✅ Comparaison effectuée');
        return comparaison;
      }

      return null;
    } catch (e) {
      print('❌ Exception comparerForfaits: $e');
      return null;
    }
  }

  // Vérifier si un upgrade est nécessaire pour une fonctionnalité
  bool necessiteUpgrade(String codeFonctionnalite) {
    if (_accesFonctionnalites.containsKey(codeFonctionnalite)) {
      return !_accesFonctionnalites[codeFonctionnalite]!.acces;
    }
    return false;
  }

  // Obtenir la raison du refus d'accès
  String? raisonRefus(String codeFonctionnalite) {
    if (_accesFonctionnalites.containsKey(codeFonctionnalite)) {
      return _accesFonctionnalites[codeFonctionnalite]!.raison;
    }
    return null;
  }

  // Réinitialiser le ViewModel
  void reset() {
    _forfaits = [];
    _abonnementActif = null;
    _historique = [];
    _accesFonctionnalites.clear();
    _statistiques.clear();
    _chargementEnCours = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Effacer les erreurs
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Rafraîchir toutes les données
  Future<void> rafraichirTout(String codePharmacier) async {
    await Future.wait([
      chargerForfaits(),
      chargerAbonnementActif(codePharmacier),
      chargerHistorique(codePharmacier),
    ]);
  }
}