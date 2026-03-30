import 'package:assurappci/Constants/Couleurs.dart';
import 'package:assurappci/Screens/Auth/Inscription.dart';
import 'package:assurappci/Screens/Auth/RecoverPassword.dart';
import 'package:assurappci/Screens/General/Accueil.dart';
import 'package:assurappci/Screens/General/Dashboard.dart';
import 'package:assurappci/Screens/Pharmacie/DashboardGerant.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  @override
  void dispose() {
    _codePinController.dispose();
    super.dispose();
  }

    final TextEditingController _codePinController=TextEditingController();

  Future<void>_seConnecter() async {
    final authViewModel=context.read<AuthViewModel>();
    
    await authViewModel.connexion(_codePinController.text);

    //Si pas d'erreur on navigue
    if(authViewModel.errorMessage==null){
      if(authViewModel.session?.typeUtilisateur=="Gestionnaire de pharmacie"){
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>DashboardGerant()), (route)=>false);
      }else{
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Dashboard()), (route)=>false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    return Scaffold(
      backgroundColor: Couleurs.lightGreen,
      body: SafeArea(child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: ScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20.h,),
            Padding(padding: EdgeInsets.symmetric(vertical: 12.h),child: Center(
              child: Image.asset("name"),
            ),),
            Text("Connexion",style: TextStyle(fontSize: 25.sp,fontWeight: FontWeight.bold),),
            Text("C'est bien de te revoir 👋",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey),),
            SizedBox(
              height: 25.h,
            ),

            // Affiche l'erreur si elle existe
            if (authViewModel.errorMessage != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(
                  authViewModel.errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 14.sp),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Container(
                height: 300.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r)
                ),
                child: Column(
                  children: [

                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.w),
                      child: Text("Code Pin à 6 chiffres"),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Pinput(
                        disabledPinTheme: PinTheme(
                          decoration: BoxDecoration(
                            color: Couleurs.lightGreen,
                          )
                        ),
                        controller: _codePinController,
                        length: 6,),
                    ),
                    Padding(
                      padding: EdgeInsets.all(15.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [GestureDetector(
                          onTap:(){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>Recoverpassword()));
                          },
                          child: Text("Pin oublié?",style: TextStyle(
                        color: Couleurs.darkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp
                      ),),)],),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.w),
                      child: Row(
                        children: [
                          Expanded(child: ElevatedButton(
                            // Affiche un loader pendant la connexion
                            onPressed: authViewModel.isLoading ? null : _seConnecter,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Couleurs.darkGreen
                            ),
                            child: authViewModel.isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text("Se connecter", style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp
                            )),
                          )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 25.h,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1.0,color: Colors.white),
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.white70
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.0.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text("Pas encore de compte? ",style: TextStyle(fontSize: 20.sp,color: Colors.grey[400])),GestureDetector(onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Inscription()));
                    },child: Text("S'inscrire",style: TextStyle(color: Couleurs.darkGreen,fontWeight: FontWeight.bold,fontSize: 20.sp),),)],
                  ),
                ),
              ),
            )
          ],
        ),
      )));
  }
}
