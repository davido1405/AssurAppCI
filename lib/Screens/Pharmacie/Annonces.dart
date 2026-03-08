import 'package:flutter/material.dart';

class Annonces extends StatefulWidget {
  const Annonces({super.key});

  @override
  State<Annonces> createState() => _AnnoncesState();
}

class _AnnoncesState extends State<Annonces> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Annonces")
      ],
    );
  }
}
