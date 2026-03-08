import 'package:assurappci/Screens/Auth/Connexion.dart';
import 'package:assurappci/Screens/Auth/Inscription.dart';
import 'package:assurappci/Screens/General/Dashboard.dart';
import 'package:assurappci/Screens/Pharmacie/DashboardGerant.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

  @override
  void initState() {
    super.initState();
    // On vérifie la session dès que l'écran s'ouvre
    Future.microtask(() => _verifierSession());
  }

  Future<void> _verifierSession() async {
    // Le ViewModel vérifie s'il y a un JWT sauvegardé
    await context.read<AuthViewModel>().init();

    // La View navigue en fonction du résultat
    if (context.read<AuthViewModel>().estConnecte) {
      if(context.read<AuthViewModel>().session?.typeUtilisateur=="Gestionnaire de pharmacie"){
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DashboardGerant())
        );
      }else{
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Dashboard())
        );
      }
    } else {
      if(context.read<AuthViewModel>().numeroSauvegarde != null){
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Connexion())
        );
      }else{
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Inscription())
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Un loader pendant la vérification
        child: CircularProgressIndicator(),
      ),
    );
  }
}