// Models/Notifications.dart

class Notifications {
  final int idNotification;
  final String titre;
  final String contenu;
  final String nomPharmacie;
  final String datePublication;
  final String statutLecture;
  final String libelleTypeAnnonce;
  final String photoPharmacie;

  Notifications({
    required this.idNotification,
    required this.titre,
    required this.contenu,
    required this.nomPharmacie,
    required this.datePublication,
    required this.statutLecture,
    required this.libelleTypeAnnonce,
    required this.photoPharmacie,
  });

  // ✅ Helper : Est-ce que la notification est lue ?
  bool get estLue => statutLecture.toLowerCase() == 'lu';

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      idNotification: json['id_annonce'] ?? 0,
      titre: json['titre'] ?? '',
      contenu: json['contenu'] ?? '',
      nomPharmacie: json['nom_pharmacie'] ?? '',
      datePublication: json['date_publication'] ?? '',
      statutLecture: json['libelle_statut'] ?? 'Non lu',
      libelleTypeAnnonce: json['libelle_type_annonce'] ?? '',
      photoPharmacie: json['photo_pharmacie'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_annonce': idNotification,
      'titre': titre,
      'contenu': contenu,
      'nom_pharmacie': nomPharmacie,
      'date_publication': datePublication,
      'libelle_statut': statutLecture,
      'libelle_type_annonce': libelleTypeAnnonce,
      'photo_pharmacie': photoPharmacie,
    };
  }

  Notifications copyWith({
    int? idNotification,
    String? titre,
    String? contenu,
    String? nomPharmacie,
    String? datePublication,
    String? statutLecture,
    String? libelleTypeAnnonce,
    String? photoPharmacie,
  }) {
    return Notifications(
      idNotification: idNotification ?? this.idNotification,
      titre: titre ?? this.titre,
      contenu: contenu ?? this.contenu,
      nomPharmacie: nomPharmacie ?? this.nomPharmacie,
      datePublication: datePublication ?? this.datePublication,
      statutLecture: statutLecture ?? this.statutLecture,
      libelleTypeAnnonce: libelleTypeAnnonce ?? this.libelleTypeAnnonce,
      photoPharmacie: photoPharmacie ?? this.photoPharmacie,
    );
  }

  @override
  String toString() {
    return 'Notification(id: $idNotification, titre: $titre, statut: $statutLecture)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notifications && other.idNotification == idNotification;
  }

  @override
  int get hashCode => idNotification.hashCode;
}