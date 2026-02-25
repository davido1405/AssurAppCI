import 'dart:convert';

import 'package:assurappci/Models/Pharmacie.dart';
import 'package:http/http.dart';

class Pharmacierespository {
  //Récupérer toute les pharmacies
  Future<List<Pharmacie>?>recupererPharmacie()async{
    final url=Uri.parse("http://10.0.2.2:4000/api/pharmacie");
    final reponse=await get(url,headers: {'Content-Type':'application/json'});

    if(reponse.statusCode==200){
      final Map<String,dynamic>corpsReponse=jsonDecode(reponse.body);
      List<dynamic>pharmacies=corpsReponse['data'];
      List<Pharmacie>listePharmacies=pharmacies.map((pharmacies)=>Pharmacie.fromJson(pharmacies)).toList();

      return listePharmacies;
    }
  }

  //Rechercher une pharmacie
  Future<List<Pharmacie>?>rechercherPharmacieFiltre(List<String>filtre) async{

    //Chercher comment gérer ça(les filtres multiple
    final url=Uri.parse("http://10.0.2.2:4000/api/pharmacie?");
    final reponse=await get(url,headers: {'Content-Type':'application/json'});

      if(reponse.statusCode==200) {
        final Map<String, dynamic>corpsReponse = jsonDecode(reponse.body);
        List<dynamic>pharmacies = corpsReponse['data'];
        List<Pharmacie>listePharmacies = pharmacies.map((pharmacies) =>
            Pharmacie.fromJson(pharmacies)).toList();

        return listePharmacies;
      }
  }

  //Ajouter une pharmacie
Future<String?>ajouterPharmacie(String codeGerant,String nomPharmacie,String photoPharmacie,String numeroPharmacie,String emailPharmacie,double latitudePharmacie,double longitudePharmacie,String adresseFournit,List<String>assurancesAcceptees) async{
    final url=Uri.parse("http://10.0.2.2:4000/api/pharmacie/ajouterPharmacie");
    final reponse=await post(url,headers: {'Content-Type':'application/json'},body: jsonEncode(
        {
          "code_gerant": codeGerant,
          "nom_pharmacie": nomPharmacie,
          "photo_pharmacie": photoPharmacie,
          "numero_pharmacie": numeroPharmacie,
          "email_pharmacie": emailPharmacie,
          "latitudePharmacie": latitudePharmacie,
          "longitudePharmacie": longitudePharmacie,
          "adresse_fournit": adresseFournit,
          "liste_assurance_accepte":assurancesAcceptees
    }));

    if(reponse.statusCode==200){
      return "Pharmacie ajoutée avec succès !";
    }
}

//Ajouter assurance à la liste d'assurance acceptées
Future<String?> ajouterAssuranceAcceptees(String codePharmacie,List<String>assurance) async{
    final url=Uri.parse("http://10.0.2.2:4000/api/pharmacie/ajouterassurance");
    final reponse=await post(url,headers: {'Content-Type':'application/json'},body: jsonEncode(
        {
          "codePharmacie": codePharmacie,
          "liste_assurance": assurance
        }));

    if(reponse.statusCode==200){
      return "Assurance(s) ajoutée(s) avec succès à la liste des assurances acceptées";
    }
}

//Récupérer le profil d'une pharmacie
Future<Pharmacie?>recupererProfilPharmacie(String codeGerant) async{
    final url=Uri.parse("http://10.0.2.2:4000/api/pharmacie/profilpharmacie");
    final reponse=await post(url,headers: {'Content-Type':'application/json'},body: jsonEncode(
        {
          "codeGerant":codeGerant
        }));

    if(reponse.statusCode==200){
      final Map<String,dynamic>corpsReponse=jsonDecode(reponse.body);
      Pharmacie profilPharmacie=Pharmacie.fromJson(corpsReponse['data']);

      return profilPharmacie;
    }
}
}