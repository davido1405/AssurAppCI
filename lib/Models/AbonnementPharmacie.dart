// Models/AbonnementPharmacie.dart

class Forfait {
  final int idForfait;
  final String nomForfait;
  final double prix;
  final int dureeJours;
  final String? description;
  final List<Fonctionnalite> fonctionnalites;

  Forfait({
    required this.idForfait,
    required this.nomForfait,
    required this.prix,
    required this.dureeJours,
    this.description,
    required this.fonctionnalites,
  });

  factory Forfait.fromJson(Map<String, dynamic> json) {
    return Forfait(
      idForfait: json['id_forfait'],
      nomForfait: json['nom_forfait'],
      prix: double.parse(json['prix'].toString()),
      dureeJours: json['duree_jours'],
      description: json['description'],
      fonctionnalites: (json['fonctionnalites'] as List?)
          ?.map((f) => Fonctionnalite.fromJson(f))
          .toList() ??
          [],
    );
  }
}

class Fonctionnalite {
  final String nom;
  final String code;
  final int? limite;

  Fonctionnalite({
    required this.nom,
    required this.code,
    this.limite,
  });

  factory Fonctionnalite.fromJson(Map<String, dynamic> json) {
    return Fonctionnalite(
      nom: json['nom'],
      code: json['code'],
      limite: json['limite'],
    );
  }
}

class AbonnementPharmacie {
  final int idAbonnement;
  final String codePharmacier;
  final int idForfait;
  final String nomForfait;
  final double prix;
  final DateTime dateDebut;
  final DateTime dateFin;
  final double? montantPaye;
  final String? libelleStatut;
  final int? joursRestants;

  AbonnementPharmacie({
    required this.idAbonnement,
    required this.codePharmacier,
    required this.idForfait,
    required this.nomForfait,
    required this.prix,
    required this.dateDebut,
    required this.dateFin,
    this.montantPaye,
    this.libelleStatut,
    this.joursRestants,
  });

  factory AbonnementPharmacie.fromJson(Map<String, dynamic> json) {
    return AbonnementPharmacie(
      idAbonnement: json['id_abonnement'] ?? 0,
      codePharmacier: json['code_pharmacie'] ?? '',
      idForfait: json['id_forfait'] ?? 1,
      nomForfait: json['nom_forfait'] ?? 'Gratuit',
      prix: json['prix'] != null ? double.parse(json['prix'].toString()) : 0.0,
      dateDebut: json['date_debut'] != null
          ? DateTime.parse(json['date_debut'])
          : DateTime.now(),
      dateFin: json['date_fin'] != null
          ? DateTime.parse(json['date_fin'])
          : DateTime.now().add(Duration(days: 365)),
      montantPaye: json['montant_paye'] != null
          ? double.parse(json['montant_paye'].toString())
          : null,
      libelleStatut: json['libelle_statut'],
      joursRestants: json['jours_restants'],
    );
  }
}

class AccesFonctionnalite {
  final bool acces;
  final String? raison;
  final int? limite;
  final int? utilise;
  final int? restant;

  AccesFonctionnalite({
    required this.acces,
    this.raison,
    this.limite,
    this.utilise,
    this.restant,
  });

  factory AccesFonctionnalite.fromJson(Map<String, dynamic> json) {
    return AccesFonctionnalite(
      acces: json['acces'] ?? false,
      raison: json['raison'],
      limite: json['limite'],
      utilise: json['utilise'],
      restant: json['restant'],
    );
  }
}

class HistoriqueAbonnement {
  final int idAbonnement;
  final String nomForfait;
  final double prix;
  final DateTime dateDebut;
  final DateTime dateFin;
  final double? montantPaye;
  final String? libelleStatut;
  final String? modePaiement;

  HistoriqueAbonnement({
    required this.idAbonnement,
    required this.nomForfait,
    required this.prix,
    required this.dateDebut,
    required this.dateFin,
    this.montantPaye,
    this.libelleStatut,
    this.modePaiement,
  });

  factory HistoriqueAbonnement.fromJson(Map<String, dynamic> json) {
    return HistoriqueAbonnement(
      idAbonnement: json['id_abonnement'],
      nomForfait: json['nom_forfait'],
      prix: double.parse(json['prix'].toString()),
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      montantPaye: json['montant_paye'] != null
          ? double.parse(json['montant_paye'].toString())
          : null,
      libelleStatut: json['libelle_statut'],
      modePaiement: json['mode_paiement'],
    );
  }
}

class StatistiqueUtilisation {
  final String nomFonctionnalite;
  final int nbUtilisations;
  final int? limite;

  StatistiqueUtilisation({
    required this.nomFonctionnalite,
    required this.nbUtilisations,
    this.limite,
  });

  factory StatistiqueUtilisation.fromJson(Map<String, dynamic> json) {
    return StatistiqueUtilisation(
      nomFonctionnalite: json['nom_fonctionnalite'],
      nbUtilisations: json['nb_utilisations'],
      limite: json['limite'],
    );
  }
}

class LimiteFonctionnalite {
  final String nomFonctionnalite;
  final int? limite;
  final int utilise;
  final int? restant;

  LimiteFonctionnalite({
    required this.nomFonctionnalite,
    this.limite,
    required this.utilise,
    this.restant,
  });

  factory LimiteFonctionnalite.fromJson(Map<String, dynamic> json) {
    return LimiteFonctionnalite(
      nomFonctionnalite: json['nom_fonctionnalite'],
      limite: json['limite'],
      utilise: json['utilise'],
      restant: json['restant'],
    );
  }
}

class ComparaisonForfait {
  final String nomForfait;
  final double prix;
  final List<String> avantages;
  final List<String> limitations;

  ComparaisonForfait({
    required this.nomForfait,
    required this.prix,
    required this.avantages,
    required this.limitations,
  });

  factory ComparaisonForfait.fromJson(Map<String, dynamic> json) {
    return ComparaisonForfait(
      nomForfait: json['nom_forfait'],
      prix: double.parse(json['prix'].toString()),
      avantages: List<String>.from(json['avantages']),
      limitations: List<String>.from(json['limitations']),
    );
  }
}