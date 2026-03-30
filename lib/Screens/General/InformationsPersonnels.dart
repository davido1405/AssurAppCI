import 'package:assurappci/Constants/Couleurs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Informationspersonnels extends StatefulWidget {
  const Informationspersonnels({super.key});

  @override
  State<Informationspersonnels> createState() => _InformationspersonnelsState();
}

class _InformationspersonnelsState extends State<Informationspersonnels> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.lightGreen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Couleurs.darkGreen,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
            SizedBox(width: 10.w),
            Text("Informations personnelle",style: TextStyle(
              color: Colors.white
            ),),
          ],
        ),
      ),
      body: Center(child: Text("Informations Personnels")),
    );
  }
}
