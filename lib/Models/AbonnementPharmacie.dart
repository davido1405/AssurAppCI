class Abonnementpharmacie {
  late int id_abonnement;
  late String date_debut_abonnement;
  late String date_fin_abonnement;

  Abonnementpharmacie({required this.id_abonnement, required this.date_debut_abonnement,required this.date_fin_abonnement});

  factory Abonnementpharmacie.fromJson(Map<String,dynamic>json){
    return Abonnementpharmacie(id_abonnement: json['id_abonnement'], date_debut_abonnement: json['date_debut_abonnement'], date_fin_abonnement: json['date_fin_abonnement']);
  }
}