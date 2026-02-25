import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Session {
  late String codeUtilisateur;
  late String nomUtilisateur;
  late String prenomUtilisateur;
  late String numeroUtilisateur;
  late String typeUtilisateur;
  late String nomAssuranceUtilisateur;
  late String adresseUtilisateurFournit;


  String? jwt;

  Session({required this.codeUtilisateur,required this.nomUtilisateur,required this.prenomUtilisateur,required this.numeroUtilisateur,required this.typeUtilisateur,required this.nomAssuranceUtilisateur,required this.adresseUtilisateurFournit,required this.jwt});
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      codeUtilisateur: json['code_utilisateur'],
      nomUtilisateur: json['nom_utilisateur'],        // ✅
      prenomUtilisateur: json['prenom_utilisateur'],  // ✅
      numeroUtilisateur: json['numeros_utilisateur'], // ✅ attention au 's'
      typeUtilisateur: json['type_utilisateur'],      // ✅
      nomAssuranceUtilisateur: json['assurance_utilisateur'], // ✅
      adresseUtilisateurFournit: json['adresse_utilisateur'], // ✅
      jwt: json['jwt_tokens'],                        // ✅
    );
  }


}

