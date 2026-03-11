import 'package:flutter/material.dart';

class Newsletter extends StatefulWidget {
  const Newsletter({super.key});

  @override
  State<Newsletter> createState() => _NewsletterState();
}

class _NewsletterState extends State<Newsletter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Merde"),),
    );
  }
}
