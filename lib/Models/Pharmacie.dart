import 'dart:convert';

class Pharmacie {
  late String codePharmacie;
  late String nomPharmacie;
  late String photoPharmacie;
  late String numeroPharmacie;
  late String emailPharmacie;
  late double longitude;
  late double latitude;
  late String adresseFournit;
  late String libelleStatut;
  late List<String> assuranceAcceptees;

  Pharmacie({required this.codePharmacie,required this.nomPharmacie,required this.photoPharmacie,required this.numeroPharmacie,required this.emailPharmacie,required this.longitude,required this.latitude,required this.adresseFournit,required this.libelleStatut,required this.assuranceAcceptees});

  factory Pharmacie.fromJson(Map<String, dynamic> json) {
    return Pharmacie(
      codePharmacie: json['code_pharmacie'] ?? '',
      nomPharmacie: json['nom_pharmacie'] ?? '',
      photoPharmacie: json['photo_pharmacie'] ?? '',
      numeroPharmacie: json['numeros_pharmacie'] ?? '',
      emailPharmacie: json['email_pharmacie'] ?? '',
      longitude: (json['longitude'] ?? 0).toDouble(), // ← toDouble() important
      latitude: (json['latitude'] ?? 0).toDouble(),   // ← toDouble() important
      adresseFournit: json['adresse_fournit'] ?? '',
      libelleStatut: json['libelle_statut'] ?? '',
      assuranceAcceptees: json['assurances_acceptees'] != null
          ? json['assurances_acceptees'].toString().split(',').map((e) => e.trim()).toList()
          : [], // ← si null retourne une liste vide
    );
  }
}