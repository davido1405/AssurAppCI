import 'package:assurappci/Screens/General/Abonnements.dart';
import 'package:assurappci/Screens/General/Accueil.dart';
import 'package:assurappci/Screens/General/UserProfil.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {


  int index=0;
  void changeIndex(int nouveauIndex){
    setState(() {
      index=nouveauIndex;
    });
  }



  @override
  Widget build(BuildContext context) {
    final List<Widget> barreNavigation=[
    Accueil(),
    Abonnements(),
    Userprofil(),
  ];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: barreNavigation[index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: changeIndex,
        currentIndex: index,
          selectedItemColor: Colors.deepOrangeAccent,
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: true,
          items: [
            BottomNavigationBarItem(
                icon: index==0?Icon(Icons.home):Icon(Icons.home_outlined),
                label: "Accueil"),
            BottomNavigationBarItem(
                icon: index==1?Icon(Icons.notifications):Icon(Icons.notifications_outlined),
                label: "Abonnements"),
            BottomNavigationBarItem(
                icon: index==2?Icon(Icons.person):Icon(Icons.person_outline),
                label: "Profil")]),
    );
  }
}
