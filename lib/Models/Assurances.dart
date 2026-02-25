class Assurances {
  late int idAssurance;
  late String nomAssurance;
  late int statutAssurance;

  Assurances({required this.idAssurance,required this.nomAssurance,required this.statutAssurance});

  factory Assurances.fromJson(Map<String,dynamic>json){
    return Assurances(idAssurance: json['id_assurance'], nomAssurance: json['nom_assurance'], statutAssurance: json['id_statut']);
  }
}