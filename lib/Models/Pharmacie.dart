import 'dart:convert';

class Pharmacie {
  final String codePharmacie;
  final String nomPharmacie;
  final String? photoPharmacie;
  final String numeroPharmacie;
  final String? emailPharmacie;
  final double? longitude;
  final double? latitude;
  final String? horrairesOuverture;
  final String? adresseFournit;
  final String? libelleStatut;
  final bool estDeGarde; // ✅ Renommé de statut_garde en estDeGarde
  final List<String> assuranceAcceptees;
  final String? villePharmacie;
  final String? distance;
  final DateTime? derniereMajGarde; // ✅ Ajouté pour le statut de garde

  Pharmacie({
    required this.codePharmacie,
    required this.nomPharmacie,
    this.photoPharmacie,
    required this.numeroPharmacie,
    this.emailPharmacie,
    this.longitude,
    this.latitude,
    this.horrairesOuverture,
    this.adresseFournit,
    this.libelleStatut,
    required this.estDeGarde,
    required this.assuranceAcceptees,
    this.villePharmacie,
    this.distance,
    this.derniereMajGarde,
  });

  factory Pharmacie.fromJson(Map<String, dynamic> json) {
    return Pharmacie(
      codePharmacie: json['code_pharmacie']?.toString() ?? '',
      nomPharmacie: json['nom_pharmacie']?.toString() ?? '',
      photoPharmacie: json['photo_pharmacie']?.toString(),
      numeroPharmacie: json['numeros_pharmacie']?.toString() ?? '',
      emailPharmacie: json['email_pharmacie']?.toString(),

      // ✅ Parse longitude et latitude de manière sûre
      longitude: _parseDouble(json['longitude']),
      latitude: _parseDouble(json['latitude']),

      adresseFournit: json['adresse_fournit']?.toString(),
      libelleStatut: json['libelle_statut']?.toString(),
      horrairesOuverture: json['horraires_ouverture']?.toString(),

      // ✅ Parse assurances de manière robuste
      assuranceAcceptees: _parseAssurances(json['assurances_acceptees'] ?? json['assurance_acceptees']),

      villePharmacie: json['nom_ville']?.toString() ?? json['ville_pharmacie']?.toString(),
      distance: json['distance']?.toString(),

      // ✅ Parse statut de garde de manière robuste
      estDeGarde: _parseBool(json['statut_garde'] ?? json['est_de_garde']),

      // ✅ Parse date de mise à jour
      derniereMajGarde: _parseDateTime(json['derniere_maj_garde']),
    );
  }

  // ✅ Méthode helper pour parser double depuis différents types
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('⚠️ Erreur parsing double: $value');
        return null;
      }
    }

    return null;
  }

  // ✅ Méthode helper pour parser bool depuis différents types
  static bool _parseBool(dynamic value) {
    if (value == null) return false;

    if (value is bool) return value;

    if (value is int) return value != 0; // 0 = false, autre = true

    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == '1' || lower == 'true') return true;
      if (lower == '0' || lower == 'false') return false;
    }

    return false;
  }

  // ✅ Méthode helper pour parser les assurances
  static List<String> _parseAssurances(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value.map((e) => e.toString().trim()).toList();
    }

    if (value is String) {
      if (value.isEmpty) return [];
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    return [];
  }

  // ✅ Méthode helper pour parser DateTime de manière sûre
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('⚠️ Erreur parsing date: $value');
        return null;
      }
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'code_pharmacie': codePharmacie,
      'nom_pharmacie': nomPharmacie,
      'photo_pharmacie': photoPharmacie,
      'numeros_pharmacie': numeroPharmacie,
      'email_pharmacie': emailPharmacie,
      'longitude': longitude,
      'latitude': latitude,
      'adresse_fournit': adresseFournit,
      'libelle_statut': libelleStatut,
      'horraires_ouverture': horrairesOuverture,
      'assurance_acceptees': assuranceAcceptees.join(', '),
      'ville_pharmacie': villePharmacie,
      'distance': distance,
      'est_de_garde': estDeGarde,
      'statut_garde': estDeGarde ? 1 : 0, // Pour compatibilité backend
      'derniere_maj_garde': derniereMajGarde?.toIso8601String(),
    };
  }

  // ✅ Copie avec modifications
  Pharmacie copyWith({
    String? codePharmacie,
    String? nomPharmacie,
    String? photoPharmacie,
    String? numeroPharmacie,
    String? emailPharmacie,
    double? longitude,
    double? latitude,
    String? horrairesOuverture,
    String? adresseFournit,
    String? libelleStatut,
    bool? estDeGarde,
    List<String>? assuranceAcceptees,
    String? villePharmacie,
    String? distance,
    DateTime? derniereMajGarde,
  }) {
    return Pharmacie(
      codePharmacie: codePharmacie ?? this.codePharmacie,
      nomPharmacie: nomPharmacie ?? this.nomPharmacie,
      photoPharmacie: photoPharmacie ?? this.photoPharmacie,
      numeroPharmacie: numeroPharmacie ?? this.numeroPharmacie,
      emailPharmacie: emailPharmacie ?? this.emailPharmacie,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      horrairesOuverture: horrairesOuverture ?? this.horrairesOuverture,
      adresseFournit: adresseFournit ?? this.adresseFournit,
      libelleStatut: libelleStatut ?? this.libelleStatut,
      estDeGarde: estDeGarde ?? this.estDeGarde,
      assuranceAcceptees: assuranceAcceptees ?? this.assuranceAcceptees,
      villePharmacie: villePharmacie ?? this.villePharmacie,
      distance: distance ?? this.distance,
      derniereMajGarde: derniereMajGarde ?? this.derniereMajGarde,
    );
  }

  @override
  String toString() {
    return 'Pharmacie(code: $codePharmacie, nom: $nomPharmacie, ville: $villePharmacie, garde: $estDeGarde)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pharmacie && other.codePharmacie == codePharmacie;
  }

  @override
  int get hashCode => codePharmacie.hashCode;
}