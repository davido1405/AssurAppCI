import 'package:flutter/material.dart';

class Profilpharmacie extends StatefulWidget {
  const Profilpharmacie({super.key});

  @override
  State<Profilpharmacie> createState() => _ProfilpharmacieState();
}

class _ProfilpharmacieState extends State<Profilpharmacie> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(child: Column(children: [
        Text("Profil pharmacie"),
      ],)),
    );
  }
}
