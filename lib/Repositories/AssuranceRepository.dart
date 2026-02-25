import 'dart:convert';

import 'package:assurappci/Models/Assurances.dart';
import 'package:http/http.dart';

class AssuranceRepository {
  //Récupérer liste des assurnces

  Future<List<Assurances>?>recupererAssurances()async{
    final url=Uri.parse("http://10.0.2.2:4000/api/assurance");
    final reponse=await get(url,headers: {'Content-Type':'application/json'});

    if(reponse.statusCode==200){
      final Map<String,dynamic>corpsReponse=jsonDecode(reponse.body);
      List<dynamic>donnee=corpsReponse['data'];
      List<Assurances>listeAssurance=donnee.map((donnee)=>Assurances.fromJson(donnee)).toList();

      return listeAssurance;
    }
  }

}