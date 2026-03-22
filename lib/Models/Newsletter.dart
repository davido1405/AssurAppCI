// Models/Newsletter.dart

class Newsletter {
  final int idNewsletter;
  final String dateAbonnement;
  final String nomPharmacie;
  final String codePharmacie;
  final String statutAbonnement;

  Newsletter({
    required this.idNewsletter,
    required this.dateAbonnement,
    required this.nomPharmacie,
    required this.codePharmacie,
    required this.statutAbonnement,
  });

  factory Newsletter.fromJson(Map<String, dynamic> json) {
    return Newsletter(
      idNewsletter: json['id_newsletter'] ?? 0,
      dateAbonnement: json['date_abonnement'] ?? '',
      statutAbonnement: json['statut_abonnement'] ?? '',
      nomPharmacie: json['nom_pharmacie'] ?? '',
      codePharmacie: json['code_pharmacie'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_newsletter': idNewsletter,
      'date_abonnement': dateAbonnement,
      'statut_abonnement': statutAbonnement,
      'nom_pharmacie': nomPharmacie,
      'code_pharmacie': codePharmacie,
    };
  }
}