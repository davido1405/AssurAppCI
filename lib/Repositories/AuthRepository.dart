import 'dart:convert';

import 'package:assurappci/Models/Session.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Authrepository {

  //S'inscrir
  Future<Session?> Inscription(String nomUtilisateur, String prenomUtilisateur ,String numeroUtilisateur ,String codePinUtilisateur, String type_utilisateur, String assuranceUtilisateur, String adresseUtilisateur) async {
    final url=Uri.parse("/api/utilisateur/inscription");
    final reponse=await post(url,headers: {"content-Type":"application/json"},body: jsonEncode(
        {
          "nomUtilisateur": nomUtilisateur,
          "prenomUtilisateur": prenomUtilisateur,
          "numeroUtilisateur": numeroUtilisateur,
          "codePinUtilisateur": codePinUtilisateur,
          "type_utilisateur": type_utilisateur,
          "assuranceUtilisateur": assuranceUtilisateur,
          "adresseUtilisateur": adresseUtilisateur
        }));
    if(reponse.statusCode==200){
      final Map<String,dynamic>corpsReponse=jsonDecode(reponse.body);

      Session nouvelleSession=Session.fromJson(corpsReponse['data']);

      return nouvelleSession;
    }
  }
  //Se connecter
  Future<Session?> Connexion(String numero,String codePine) async{
    final url=Uri.parse("http://10.0.2.2:4000/api/utilisateur/connexion");
    final reponse=await http.post(url,headers: {'Content-Type':'application/json'},body: jsonEncode({
      "numeroUtilisateur":numero,
      "codePinUtilisateur":codePine
    }));

    if(reponse.statusCode==200){
      final Map<String,dynamic> corpsReponse=jsonDecode(reponse.body);
      Session nouvelleSession=Session.fromJson(corpsReponse['data']);

      final prefs=await SharedPreferences.getInstance();
      await prefs.setString("code_utilisateur", corpsReponse['data']['code_utilisateur']);
      if(prefs.getString("numero")==null){
        prefs.setString("numero", numero);
      }
      return nouvelleSession;
    }
  }

  //Récupéré le profil utilisateur
  Future<Session?> recupererProfil(String codeUtilisateur) async{
    final url=Uri.parse("http://10.0.2.2:4000/api/utilisateur/profilutilisateur");
    final reponse=await post(url,headers: {'Content-Type':'application/json'},body: jsonEncode(
        {
          "codeUtilisateur":codeUtilisateur
        }));
    if(reponse.statusCode==200){
      final Map<String,dynamic>corpsReponse=jsonDecode(reponse.body);
      Session profilUtilisateur=Session.fromJson(corpsReponse['data']);
      return profilUtilisateur;
    }
  }

  // Sauvegarder le code utilisateur
  Future<void> sauvegarderCodeUtilisateur(String code) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("code_utilisateur", code);
  }

  Future<String?> recupererCodeUtilisateur() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('code_utilisateur');
  }

  //Sauvegarder le numéro dans les sharedPreferences
  Future<void> sauvegarderNumero(String numero) async{
    final prefs=await SharedPreferences.getInstance();
    prefs.setString("numero_utilisateur", numero.toString());
  }

  //Récupérer le numéro dans les sharedPreferences
  Future<String?>recupererNumero()async{
    final prefs=await SharedPreferences.getInstance();

    return prefs.getString('numero_utilisateur');
  }

  Future<void> secureJwt(String jwt) async {
    final secureKey= FlutterSecureStorage();
    await secureKey.write(key: 'jwt_token', value: jwt);
  }

  Future<String?>getSecureJwt()async{
    final secureKey=FlutterSecureStorage();
    return await secureKey.read(key: 'jwt_token');
  }

  Future<void>removeToken()async {
    final removeSecure=FlutterSecureStorage();
    removeSecure.delete(key: 'jwt_token');
  }

}