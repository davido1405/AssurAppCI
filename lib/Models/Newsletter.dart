class Newsletter {
  late int id_newLetter;
  late String dateAbonnement;
  late String nomPharmacie;
  late String statut_abonnement;

  Newsletter({required this.id_newLetter,required this.dateAbonnement, required this.nomPharmacie, required this.statut_abonnement});
  factory Newsletter.fromJson(Map<String,dynamic>json){
    return Newsletter(id_newLetter: json['id_newletter'], dateAbonnement: json['date_abonnement'], statut_abonnement: json['statut_abonnement'], nomPharmacie: json['nom_pharmacie']);
  }
}