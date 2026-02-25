import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Abonnements extends StatefulWidget {
  const Abonnements({super.key});

  @override
  State<Abonnements> createState() => _AbonnementsState();
}

class _AbonnementsState extends State<Abonnements> {

  // Pour l'instant une liste vide, à connecter au ViewModel plus tard
  List<String> abonnements = [];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[100],
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Abonnements", style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold
                  )),
                  Text("Recevez des notifications des pharmacies suivies",
                      style: TextStyle(color: Colors.grey[400])
                  ),
                ],
              ),
            ),

            // Liste des abonnements ou état vide
            Expanded(
              child: abonnements.isEmpty
                  ? _etatVide()
                  : ListView.builder(
                  itemCount: abonnements.length,
                  itemBuilder: (context, index) {
                    return cardAbonnement(abonnements[index]);
                  }
              ),
            )
          ],
        ),
      ),
    );
  }

  // Affiché quand il n'y a pas d'abonnements
  Widget _etatVide() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20.w),
        padding: EdgeInsets.all(30.w),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle
              ),
              child: Icon(Icons.notifications_outlined, size: 40, color: Colors.grey),
            ),
            SizedBox(height: 15.h),
            Text("Restez informé", style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold
            )),
            SizedBox(height: 10.h),
            Text(
              "Abonnez-vous aux pharmacies pour recevoir des notifications sur les promotions et disponibilités",
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }
}

Widget cardAbonnement(String nomPharma) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
    padding: EdgeInsets.all(10.w),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)]
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
              color: Colors.deepOrangeAccent,
              borderRadius: BorderRadius.circular(12.r)
          ),
          child: Icon(Icons.notifications_outlined, color: Colors.white),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nomPharma, style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp
              )),
              Text("Notifications activées", style: TextStyle(color: Colors.grey[400])),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle
          ),
          child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_off_outlined, color: Colors.grey)
          ),
        )
      ],
    ),
  );
}