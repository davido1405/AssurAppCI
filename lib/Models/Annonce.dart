// Models/Annonce.dart

class Annonce {
  final int idAnnonces;
  final String titre;
  final String contenu;
  final String datePublication;
  final String typeAnnonce;
  final int nombreVue;
  String? nomPharmacie;

  Annonce({
    required this.idAnnonces,
    required this.titre,
    required this.contenu,
    required this.datePublication,
    required this.typeAnnonce,
    required this.nombreVue,
    this.nomPharmacie,
  });

  factory Annonce.fromJson(Map<String, dynamic> json) {
    return Annonce(
      idAnnonces: json['id_annonce'] ?? 0,
      titre: json['titre'] ?? '',
      contenu: json['contenu'] ?? '',
      datePublication: json['date_publication'] ?? '', // ✅ Correction typo
      typeAnnonce: json['libelle_type_annonce'] ?? '',
      nombreVue: json['nombreVue'] ?? 0,
      nomPharmacie: json['nom_pharmacie'] ?? '',
    );
  }
}