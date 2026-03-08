import 'package:flutter/material.dart';

class Newsletters extends StatefulWidget {
  const Newsletters({super.key});

  @override
  State<Newsletters> createState() => _NewslettersState();
}

class _NewslettersState extends State<Newsletters> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Annonces pharmacies abonnées"),),
      body: SafeArea(child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
        children: [

        ],
      ),)),
    );
  }
}
