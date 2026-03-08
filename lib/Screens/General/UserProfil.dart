import 'package:assurappci/Screens/Auth/Connexion.dart';
import 'package:assurappci/Screens/General/Adressefournit.dart';
import 'package:assurappci/Screens/General/InformationsPersonnels.dart';
import 'package:assurappci/Screens/General/Monassurance.dart';
import 'package:assurappci/Screens/General/Numerotelephone.dart';
import 'package:assurappci/Screens/Pharmacie/ProfilPharmacie.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Userprofil extends StatelessWidget {
  const Userprofil({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthViewModel>().session;

    final listeActions = [
      {
        "titre": "Informations personnelles",
        "icone": Icon(Icons.person_outline, color: Colors.deepOrangeAccent),
        "couleur": Colors.orangeAccent,
        "action": () => Navigator.push(context, MaterialPageRoute(builder: (context) => Informationspersonnels()))
      },
      {
        "titre": "Mon assurance",
        "icone": Icon(Icons.shield_outlined, color: Colors.blueAccent),
        "couleur": Colors.lightBlueAccent,
        "action": () => Navigator.push(context, MaterialPageRoute(builder: (context) => Monassurance()))
      },
      {
        "titre": "Adresse enregistrée",
        "icone": Icon(Icons.location_on_outlined, color: Colors.green),
        "couleur": Colors.lightGreenAccent,
        "action": () => Navigator.push(context, MaterialPageRoute(builder: (context) => Adressefournit()))
      },
      {
        "titre": "Numéro de téléphone",
        "icone": Icon(CupertinoIcons.phone, color: Colors.grey),
        "couleur": Colors.grey[400]!,
        "action": () => Navigator.push(context, MaterialPageRoute(builder: (context) => Numerotelephone()))
      },
    ];

    return Material(
      color: Colors.grey[100],
      child: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Carte profil
              Container(
                margin: EdgeInsets.all(10.w),
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r)
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50.w,
                          height: 50.h,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.deepOrangeAccent
                          ),
                          child: Center(child: Text(
                            session?.nomUtilisateur.substring(0, 1).toUpperCase() ?? 'U',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.sp),
                          )),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${session?.nomUtilisateur ?? ''} ${session?.prenomUtilisateur ?? ''}",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                            ),
                            Text(
                              session?.numeroUtilisateur ?? '',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      children: [
                        Expanded(child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(children: [
                            Text("12", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
                            Text("Abonnements", style: TextStyle(color: Colors.grey[400]))
                          ]),
                        )),
                        SizedBox(width: 10.w),
                        Expanded(child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(children: [
                            Text("24", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
                            Text("Recherches", style: TextStyle(color: Colors.grey[400]))
                          ]),
                        )),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 15.h,),

              // Liste des actions
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r)
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: listeActions.length,
                  itemBuilder: (context, index) {
                    final item = listeActions[index];
                    return ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            color: item['couleur'] as Color
                        ),
                        child: item['icone'] as Icon,
                      ),
                      title: Text(item['titre'] as String),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[500], size: 16),
                      onTap: ()=>(item['action'] as Function)(),  // ← appelé au tap
                    );
                  },
                  separatorBuilder: (context, index) => Divider(color: Colors.grey[200], thickness: 1),
                ),
              ),
              SizedBox(height: 15.h),
              // Déconnexion
              GestureDetector(
                onTap: () {
                  context.read<AuthViewModel>().deconnexion();
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (context) => Connexion()),
                          (route) => false
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  padding: EdgeInsets.all(15.w),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 10.w),
                      Text("Se déconnecter", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}