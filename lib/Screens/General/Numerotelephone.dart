import 'package:flutter/material.dart';

class Numerotelephone extends StatefulWidget {
  const Numerotelephone({super.key});

  @override
  State<Numerotelephone> createState() => _NumerotelephoneState();
}

class _NumerotelephoneState extends State<Numerotelephone> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Numéro de téléphone"),),
    );
  }
}
