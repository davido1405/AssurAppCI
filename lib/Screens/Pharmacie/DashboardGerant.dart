import 'package:assurappci/Repositories/AbonnementPharmacieRepository.dart';
import 'package:assurappci/Screens/Auth/Connexion.dart';
import 'package:assurappci/Screens/General/Abonnements.dart';
import 'package:assurappci/Screens/General/Accueil.dart';
import 'package:assurappci/Screens/Pharmacie/AbonnementPharmacie.dart';
import 'package:assurappci/Screens/Pharmacie/AccueilPharmacie.dart';
import 'package:assurappci/Screens/Pharmacie/Annonces.dart';
import 'package:assurappci/Screens/Pharmacie/ProfilPharmacie.dart';
import 'package:assurappci/ViewModels/AbonnementPharmacieViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardGerant extends StatefulWidget {
  const DashboardGerant({super.key});

  @override
  State<DashboardGerant> createState() => _DashboardGerantState();
}

class _DashboardGerantState extends State<DashboardGerant> {

  String pageActive="accueil";

  void navigate(String newPage,String pageName){

    setState(() {
      pageActive=newPage;
    });

    Navigator.of(context).pop();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Espace pharmacie",style: TextStyle(
          color: Colors.white
        ),)),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      drawer: Drawer(
        surfaceTintColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepOrangeAccent
              ),
                child: Column(

                        )),
          actionPage(icone: pageActive=="accueil"? Icon(Icons.home):Icon(Icons.home_outlined),titre: "Accueil",onTap: ()=>navigate("accueil", "/AccueilPharmacie")),
          actionPage(icone: pageActive=="profilpharmacie"? Icon(Icons.local_hospital):Icon(Icons.local_hospital_outlined),titre: "Profil pharmacie",onTap: ()=>navigate("profilpharmacie","/ProfilPharmacie")),
          actionPage(icone: pageActive=="annonces"? Icon(Icons.send):Icon(Icons.send_outlined),titre: "Envoyer annonces",onTap: ()=>navigate("annonces","/Annonces")),
          actionPage(icone: pageActive=="abonnements"? Icon(Icons.bookmark):Icon(Icons.bookmark_outline),titre: "Abonnement",onTap: ()=>navigate("abonnements","/Abonnement")),
            Divider(indent: 15,endIndent: 15,),
            ListTile(leading: Icon(Icons.logout,color: Colors.red,),title: Text("Déconnexion"),onTap: ()=>Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Connexion()), (route)=>false),)

        ],),
      ),
      body: MultiProvider(providers: [
        ChangeNotifierProvider(create: (context)=>Abonnementpharmacieviewmodel(Abonnementpharmacierepository())),
      ],
      child: SafeArea(child: _chargerPages())),
      backgroundColor: Colors.grey[200],
    );
  }
  Widget _chargerPages(){
    switch(pageActive){
      case "accueil":
        return Accueilpharmacie();
      case "profilpharmacie":
        return Profilpharmacie();
      case "annonces":
        return Annonces();
      case "abonnements":
        return Abonnementpharmacie();
      default:
        return Accueilpharmacie();
    }
  }
}

Widget actionPage({required Icon icone,required String titre,required GestureTapCallback onTap}){
  return ListTile(
  leading: icone,
    title: Text(titre),
    onTap: onTap,
    minLeadingWidth: 2,
  );
}

