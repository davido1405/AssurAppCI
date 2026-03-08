import 'dart:convert';

import 'package:assurappci/Models/Newsletter.dart';
import 'package:http/http.dart';

class Newsletterrepository {
  //Récupérer liste des abonnements
  Future<List<Newsletter>?> recupererAbonnements(String codeUtilisateur) async {
    final url = Uri.parse("http://10.0.2.2:4000/api/newsLetters/abonnement");
    final reponse = await post(
        url,
        headers: {"Content-Type": "application/json"}, // ← application/json pas multipart
        body: jsonEncode({"codeUtilisateur": codeUtilisateur}) // ← envoie le code
    );

    if (reponse.statusCode == 200) {
      final Map<String, dynamic> corpsReponse = jsonDecode(reponse.body);
      List<dynamic> donnees = corpsReponse['data'];
      return donnees.map((d) => Newsletter.fromJson(d)).toList();
    }
  }
  //S'abonner à une pharmacie
Future<String?> sabonnerPharmacie(String codePharmacie,String codeUtilisateur) async{
    final url=Uri.parse("http://10.0.2.2:4000/api/newsLetters/sabonner");
    final reponse=await post(url,headers: {"Content-Type":"application/json"},body: jsonEncode(
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