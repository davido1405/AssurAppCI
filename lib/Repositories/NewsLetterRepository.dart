import 'dart:convert';

import 'package:assurappci/Models/Newsletter.dart';
import 'package:http/http.dart';

class Newsletterrepository {
  //Récupérer liste des abonnements
  Future<List<Newsletter>?>recupererAbonnements(String codeUtilisateur)async{
    final url=Uri.parse("http://10.0.2.2:4000/api/newsLetters/abonnement");
    final reponse=await get(url,headers: {"Content-Type":"multipart/form-data"});

    if(reponse.statusCode==200){
      final Map<String,dynamic>corpsReponse=jsonDecode(reponse.body);
      List<dynamic>donnees=corpsReponse['data'];
      List<Newsletter>listeAbonnements=donnees.map((donnees)=>Newsletter.fromJson(donnees)).toList();

      return listeAbonnements;
    }
  }
  //S'abonner à une pharmacie
Future<String?> sabonnerPharmacie(String codePharmacie,String codeUtilisateur) async{
    final url=Uri.parse("http://10.0.2.2:4000/api/newsLetters/sabonner");
    final reponse=await post(url,headers: {"Content-Type":"multipart/form-data"},body: jsonEncode(
        {
          "codePharmacie":codePharmacie,
          "codeUtilisateur":codeUtilisateur
        }));

    if(reponse.statusCode==200){
      final Map<String,dynamic>donnees=jsonDecode(reponse.body);
      return donnees['message'];
    }
}

//Supprimer un abonnement
Future<String?>desactiverAbonnement(String codePharmacie,String codeUtilisateur)async{
  final url=Uri.parse("http://10.0.2.2:4000/api/newsLetters/supprimerabonnement");
  final reponse=await post(url,headers: {'Content-Type':'application/json'},body: jsonEncode(
      {
        "codePharmacie":codePharmacie,
        "codeUtilisateur":codeUtilisateur
      }));

  if(reponse.statusCode==200){
    final Map<String,dynamic>donnees=jsonDecode(reponse.body);
    return donnees['message'];
  }
}
}