import 'package:assurappci/Constants/Couleurs.dart';
import 'package:assurappci/Models/Assurances.dart';
import 'package:assurappci/Models/TempSession.dart';
import 'package:assurappci/Screens/Auth/Connexion.dart';
import 'package:assurappci/Screens/Auth/DefinirCodePin.dart';
import 'package:assurappci/ViewModels/AssuranceViewModel.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Inscription extends StatefulWidget {
  const Inscription({super.key});

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gestionnairePharmacie;
    Future.microtask(() => recupererAssurance());
  }

  TextEditingController nom = TextEditingController();
  TextEditingController prenom = TextEditingController();
  TextEditingController numero = TextEditingController();
  TextEditingController adresse = TextEditingController();

  TextEditingController ville = TextEditingController();

  bool gestionnairePharmacie = false;

  String? _typeChoisi;

  List<Assurances> typeAssurance = [];

  Future<void> recupererAssurance() async {
    final assu = context.read<AssuranceViewModel>();
    await assu.init();

    if (assu.errorMessage == null) {
      setState(() {
        typeAssurance =
            assu.assurances; // on récupère directement la liste du ViewModel
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.lightGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: ScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Logo GoPharma
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Image.asset(
                      "assets/images/Logo avec nom.png",width: 300.w,height: 125.h,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.h),
              Center(
                child: Text(
                  "Inscription",
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Créez votre compte GoPharma",
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              //Information de base
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 0.5)],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(18.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.person_circle_fill,
                              size: 30.r,
                              color: Couleurs.darkGreen,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              "Informations de base",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        Text(
                          "Nom",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 10.h),
                        TextField(
                          controller: nom,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hint: Text("Nom"),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "Prénom",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 10.h),
                        TextField(
                          controller: prenom,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hint: Text("Prénom"),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "Numéro",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 10.h),
                        TextField(
                          controller: numero,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixText: "+225 ",
                            hint: Text("Numéro de téléphone"),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "Ville",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextField(
                          controller: ville,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hint: Text("Ville de résidence"),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "Adresse",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 10.h),
                        TextField(
                          controller: adresse,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.location_on_outlined,
                              color: Colors.grey[500],
                            ),
                            hint: Text("Adresse"),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //Assurance
              Padding(
                padding: EdgeInsets.all(15.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 0.5)],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.shield_lefthalf_fill,
                              color: Couleurs.darkGreen,
                              size: 30.r,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              "Assurance",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "Veuillez sélectionner votre assurance",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 10.h),
                        //Sélectionner le type d'assurance
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 15.h,
                            ),
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          hint: Text(
                            "Sélectionner votre assurance",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          initialValue: _typeChoisi,
                          items: typeAssurance.map<DropdownMenuItem<String>>((
                            Assurances assurance,
                          ) {
                            return DropdownMenuItem<String>(
                              value: assurance.nomAssurance,
                              // ← le champ nom de ton Model Assurances
                              child: Text(assurance.nomAssurance),
                            );
                          }).toList(),
                          onChanged: (String? nouvelleValeur) {
                            setState(() {
                              _typeChoisi = nouvelleValeur;
                            });
                          },
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "Laissez vide si pas assurance",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Couleurs.accentOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              //Option gestionnaire de pharmacie
              CheckboxListTile(
                title: Text(
                  "Je suis gestionnaire de pharmacie",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                value: gestionnairePharmacie,
                onChanged: (bool? nouvelleValeur) {
                  if (mounted) {
                    setState(() {
                      gestionnairePharmacie = nouvelleValeur!;
                    });
                    if (gestionnairePharmacie) {
                      print("Gestionnaire de pharmacie");
                    }
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),

              SizedBox(height: 12.h),

              //Bouton d'action
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!(nom.text.isEmpty ||
                              prenom.text.isEmpty ||
                              numero.text.isEmpty ||
                              ville.text.isEmpty ||
                              adresse.text.isEmpty)) {
                            final tempSession = Tempsession(
                              nom: nom.text,
                              prenom: prenom.text,
                              numero: numero.text,
                              assurance: _typeChoisi ?? 'Aucune assurance',
                              ville: ville.text,
                              adresse: adresse.text,
                              type_utilisateur: gestionnairePharmacie == true
                                  ? "Gestionnaire de pharmacie"
                                  : "Utilisateur classique",
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Definircodepin(tempsession: tempSession),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Couleurs.darkGreen,
                        ),
                        child: Text(
                          "S'inscrire",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              //Page de connexion
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Déjà un compte?"),
                    SizedBox(width: 10.w),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Connexion()),
                        );
                      },
                      child: Text(
                        "Connexion",
                        style: TextStyle(
                          color: Couleurs.accentOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
