import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Accueilpharmacie extends StatefulWidget {
  const Accueilpharmacie({super.key});

  @override
  State<Accueilpharmacie> createState() => _AccueilpharmacieState();
}

class _AccueilpharmacieState extends State<Accueilpharmacie> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            height: 300.h,
            width: 350.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200]
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Icon(Icons.subscriptions_outlined,size: 25.r),
                  ),
                ),
                SizedBox(height: 15.h,),
                Text("Vos statistiques s'afficheront ici",style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp
                ),),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
