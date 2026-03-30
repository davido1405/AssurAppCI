class Horairesouverture {
  late  String lundi_vendredi;
  late String samedi;
  late String dimanche;

  Horairesouverture({required this.lundi_vendredi, required this.samedi,required this.dimanche});
  
  factory Horairesouverture.fromJson(Map<String,dynamic>json){
    return Horairesouverture(lundi_vendredi: json['lundi_vendredi'], samedi: json['samedi'], dimanche: json['dimanche']);
  }
}