import 'package:assurappci/Constants/Couleurs.dart';
import 'package:assurappci/Models/Notifications.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:assurappci/ViewModels/NewsletterViewModel.dart';
import 'package:assurappci/ViewModels/NotificationsViewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Newsletters extends StatefulWidget {
  const Newsletters({super.key});

  @override
  State<Newsletters> createState() => _NewslettersState();
}

class _NewslettersState extends State<Newsletters> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await recupererNotification();
    });
  }

  List<Notifications> toutesNotifications = [];

  bool chargementEncour = false;

  Future<void> recupererNotification() async {
    if (mounted) {
      setState(() {
        chargementEncour = true;
      });
    }
    try {
      //Récupérer le code de l'utilisateur connecté
      final utilisateur = context
          .read<AuthViewModel>()
          .session
          ?.codeUtilisateur;
      print(utilisateur);
      if (utilisateur == null || utilisateur.isEmpty) {
        return;
      }
      final notif = context.read<Notificationsviewmodel>();
      await notif.recupererNotifications(utilisateur);
      if (mounted) {
        setState(() {
          chargementEncour = false;
        });
      }
      if (mounted && notif.errorMessage == null) {
        setState(() {
          toutesNotifications = notif.notifications;
        });
        print(toutesNotifications);
      }
    } catch (e, stackTrace) {
      setState(() {
        chargementEncour = false;
      });
      print(e);
      print(stackTrace);
    }
  }

  Future<void>lireNotification(Notifications notif)async{
    try{
      final utilisateur = context
          .read<AuthViewModel>()
          .session
          ?.codeUtilisateur;
      final notification = context.read<Notificationsviewmodel>();
      await notification.lireNotification(utilisateur!, notif.idNotification);
      if (mounted && notification.errorMessage == null) {
        print("notification lu");
        await recupererNotification();
      }
    }catch(e){
      print(e);
    }
  }

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
            Text("Centre notification", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            recupererNotification();
          },
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                //Titre et sous-titre
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Notifications",
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 15.h),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width -
                                  48.w, // Largeur écran - marges
                              child: Text(
                                "Abonnez-vous aux différentes pharmacies pour rester informé(e) de leur dernière actualité",
                                //textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16.sp),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Liste des notifications
                chargementEncour
                    ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 250.h),
                      child: CircularProgressIndicator(color: Couleurs.darkGreen,),
                    )
                    : toutesNotifications.isEmpty
                    ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 100.h),
                      child: emptyStateNotification(),
                    )
                    : Column(
                        children: [
                          for (var notif in toutesNotifications)
                            Padding(
                              padding: EdgeInsets.all(5.w),
                              child: GestureDetector(onTap: () async {
                                if(mounted){
                                  showDialog(context: context, builder: (context){
                                    return detailsNotifs(notif);
                                  });
                                }
                                await lireNotification(notif);

                              },
                                  child: carteNotification(notif)),
                            ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget carteNotification(Notifications notif) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r)
      ),
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: Couleurs.lightGreen,
          ),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Icon(Icons.notifications, color: Couleurs.darkGreen),
          ),
        ),
        title: Text("${notif.nomPharmacie} - ${notif.titre}"),
        subtitle: Text(
          "${notif.contenu.substring(0, notif.contenu.length - 10)}...",
        ),
        /**
        trailing: GestureDetector(
          onTap: () {
            //Ouvrir la notification
            print("notification ouverte");
          },
          child: Container(
            decoration: BoxDecoration(
              color: Couleurs.accentOrange,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
              child: Text("Lire"),
            ),
          ),
        ),*/
      ),
    );
  }

  Widget emptyStateNotification() {
    return Padding(
      padding: EdgeInsets.all(15.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(color: Colors.grey, blurRadius: 1, spreadRadius: 0.2),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Couleurs.lightGreen,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(18.w),
                  child: Icon(
                    Icons.notifications_off,
                    color: Couleurs.darkGreen,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text("Oups !", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.5.h),
                "Aucune notifications pour le moment ou vous n'êtes abonné à aucune pharmacie",
              ),
              SizedBox(height: 10.h),
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Couleurs.accentOrange,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.w,
                        vertical: 5.h,
                      ),
                      child: Text(
                        "M'abonner à une pharmacie",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget detailsNotifs(Notifications notif){

    return DraggableScrollableSheet(
      initialChildSize: 0.60, // hauteur initiale
      minChildSize: 0.15,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
              )
            ],
          ),
          child: ListView(
            controller: scrollController,
            children: [
              SizedBox(height: 10),

              // 🔘 petite barre (drag indicator)
              Center(
                child: Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              SizedBox(height: 15),

              SizedBox(height: 20),
              //Afficher les différentes options ici
            ],
          ),
        );
      },
    );

  }
}
