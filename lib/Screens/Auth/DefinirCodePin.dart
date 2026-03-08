import 'dart:math';

import 'package:assurappci/Models/TempSession.dart';
import 'package:assurappci/Screens/General/Dashboard.dart';
import 'package:assurappci/Screens/Pharmacie/DashboardGerant.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class Definircodepin extends StatefulWidget {
  final Tempsession tempsession;
  const Definircodepin({ super.key,required this.tempsession});

  @override
  State<Definircodepin> createState() => _DefinircodepinState();
}

class _DefinircodepinState extends State<Definircodepin> {
  @override
  void dispose(){
    pin.dispose();
    super.dispose();
  }

  Future<void>_sinscrire()async{
      final authViewModel=context.read<AuthViewModel>();

      await authViewModel.inscription(widget.tempsession.nom, widget.tempsession.prenom, widget.tempsession.numero, pin.text, widget.tempsession.type_utilisateur, widget.tempsession.assurance, widget.tempsession.adresse, widget.tempsession.ville);
      //Si pas d'erreur on navigue
      //print(authViewModel.errorMessage);
      if(authViewModel.errorMessage==null){
        if(authViewModel.session?.typeUtilisateur=="Gestionnaire de pharmacie"){
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => DashboardGerant())
          );
        }else{
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => Dashboard())
          );
        }
      }
  }

  TextEditingController pin=TextEditingController();
  bool deuxiemTem=false;
  String? ancien;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: Text("Définir un code pin"),),
      body: SafeArea(
        child: Center(
        child: Container(
          height: 500.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadiusGeometry.circular(12.r)
          ),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //Lottie.asset("name"),
                SizedBox(height: 20.h,),
                Text(deuxiemTem?"Confirmez votre codePin":"Veuillez renseigner votre code pin"),
                SizedBox(height: 10.h,),
                Pinput(
                  controller: pin,
                  length: 6,

                ),
                SizedBox(height: 20.h,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(onPressed: () async {
                          if(!deuxiemTem){
                            setState(() {
                              ancien=pin.text;
                              deuxiemTem=true;
                            });
                            pin.clear();
                          }else{
                            if(ancien.toString()==pin.text){
                              _sinscrire();
                            }
                          }
                        }, child: Text(deuxiemTem?"Valider":"Continuer")),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),));
  }
}
