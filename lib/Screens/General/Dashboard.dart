import 'package:assurappci/Constants/Couleurs.dart';
import 'package:assurappci/Screens/General/Abonnements.dart';
import 'package:assurappci/Screens/General/Accueil.dart';
import 'package:assurappci/Screens/General/Carte.dart';
import 'package:assurappci/Screens/General/Newsletters.dart';
import 'package:assurappci/Screens/General/UserProfil.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:assurappci/ViewModels/NotificationsViewModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() async {
      await badgeNotifications();
    });
  }

  Future<void> badgeNotifications() async {
    try {
      final utilisateur = context
          .read<AuthViewModel>()
          .session
          ?.codeUtilisateur;
      if (utilisateur == null || utilisateur.isEmpty) {
        return;
      }
      final notifs = await context.read<Notificationsviewmodel>();
      await notifs.init(utilisateur);
      if (mounted && notifs.errorMessage == null) {
        setState(() {
          totalNotifs = notifs.nombreNotifs!;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Erreur badgeNotifications: $e');
      print('StackTrace: $stackTrace');
    }
  }

  int totalNotifs = 0;
  int index = 0;

  void changeIndex(int nouveauIndex) {
    setState(() {
      index = nouveauIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> barreNavigation = [
      Accueil(),
      Abonnements(),
      Userprofil(),
    ];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Couleurs.darkGreen,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "GoPharma",
              style: TextStyle(
                fontSize: 25.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Newsletters()),
                );
              },
              icon: Badge(
                backgroundColor: Couleurs.primaryGreen,
                label: Text("$totalNotifs", style: TextStyle(fontSize: 15.sp)),
                child: Icon(Icons.notifications, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          barreNavigation[index],
          if (index == 0)
            Positioned(
              right: 16,
              bottom: 50,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Carte()),
                  );
                },
                backgroundColor: Couleurs.primaryGreen,
                child: Padding(
                  padding: EdgeInsets.all(15.w),
                  child: Icon(
                    CupertinoIcons.map_pin_ellipse,size: 30.r,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: changeIndex,
        currentIndex: index,
        selectedItemColor: Colors.white,
        unselectedItemColor: Couleurs.primaryGreen,
        showSelectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: index == 0 ? Icon(Icons.home) : Icon(Icons.home_outlined),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: index == 1
                ? Icon(Icons.newspaper)
                : Icon(Icons.newspaper_outlined),
            label: "Abonnements",
          ),
          BottomNavigationBarItem(
            icon: index == 2 ? Icon(Icons.person) : Icon(Icons.person_outline),
            label: "Profil",
          ),
        ],
        backgroundColor: Couleurs.darkGreen,
      ),
      backgroundColor: Couleurs.lightGreen,
    );
  }
}
