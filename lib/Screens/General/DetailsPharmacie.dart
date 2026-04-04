import 'package:assurappci/Constants/Couleurs.dart';
import 'package:assurappci/Models/Pharmacie.dart';
import 'package:assurappci/Screens/General/Carte.dart';
import 'package:assurappci/ViewModels/AbonnementPharmacieViewModel.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:assurappci/ViewModels/NewsletterViewModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Detailspharmacie extends StatefulWidget {
  final Pharmacie pharmacie;

  const Detailspharmacie({super.key, required this.pharmacie});

  @override
  State<Detailspharmacie> createState() => _DetailspharmacieState();
}

class _DetailspharmacieState extends State<Detailspharmacie> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await abonne();
    });
  }

  Future<void> abonne() async {
    final utilisateur = context.read<AuthViewModel>().session?.codeUtilisateur;
    final abonnements = context.read<Newsletterviewmodel>();
    await abonnements.init(utilisateur!);
    if (abonnements.errorMessage == null) {
      final liste = abonnements.newsLetter.where(
        (n) => n.codePharmacie.contains(widget.pharmacie.codePharmacie),
      );
      if (liste.isNotEmpty) {
        setState(() {
          dejaAbonne = true;
        });

        print(widget.pharmacie);
      }
    }
  }

  Future<void> sabonner() async {
    final sabonne = await context.read<Newsletterviewmodel>();
    try {
      sabonne.sabonner(
        widget.pharmacie.codePharmacie,
        context.read<AuthViewModel>().session!.codeUtilisateur,
      );

      if (sabonne.errorMessage == null) {
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Satut abonnement"),
              content: Text("Abonnement éffectué avec succès !"),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await abonne();
                  },
                  child: Text("Compris"),
                ),
              ],
            );
          },
        );
      } else {
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Satut abonnement"),
              content: Text("${sabonne.errorMessage}"),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await abonne();
                  },
                  child: Text("Compris"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> desouscrirAbonnement() async {
    final newletterViewmodel = context.read<Newsletterviewmodel>();

    final codeUtilisateur =
        context.read<AuthViewModel>().session?.codeUtilisateur ?? '';

    if (codeUtilisateur.isEmpty) return;
    await newletterViewmodel.desabonner(
      widget.pharmacie.codePharmacie,
      codeUtilisateur,
    );
    if (newletterViewmodel.errorMessage == null) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Satut abonnement"),
            content: Text("Abonnement désactivé avec succès !"),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await abonne();
                },
                child: Text("Compris"),
              ),
            ],
          );
        },
      );
    } else {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Satut abonnement"),
            content: Text("${newletterViewmodel.errorMessage}"),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await abonne();
                },
                child: Text("Compris"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void>lancerAppel(String numeroTelephone)async{
    final Uri lanchUri=Uri(scheme: 'tel',path: numeroTelephone);
    if(await canLaunchUrl(lanchUri)){
      await launchUrl(lanchUri);
    }else{
      if(mounted){
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Text("Appel téléphonique"),
            content: Text("Impossible d'appeler cette pharmacie"),
            actions: [
              Center(child: ElevatedButton(onPressed: (){
                if(mounted){
                  Navigator.pop(context);
                }
              }, child: Text("Compris")),)
            ],
          );
        });
      }
    }
  }

  bool dejaAbonne = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.lightGreen,
      appBar: AppBar(
        backgroundColor: Couleurs.darkGreen,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Détails ${widget.pharmacie.nomPharmacie}",
          style: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: abonne,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Image de la pharmacie
                Padding(
                  padding: EdgeInsets.all(18.w),
                  child: Stack(
                    children: [
                      //Image pharmacie
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: widget.pharmacie.photoPharmacie != null
                            ? Image.network(
                                widget.pharmacie.photoPharmacie!,
                                width: double.maxFinite,
                                // ✅ Correction 2
                                height: 300.h,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.maxFinite,
                                    height: 300.h,
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.local_pharmacy,
                                      size: 40.sp,
                                      color: Colors.grey[600],
                                    ),
                                  );
                                },
                              )
                            : Image.asset(
                                "assets/images/b.jpg",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.maxFinite,
                                    height: 300.h,
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.local_pharmacy,
                                      size: 40.sp,
                                      color: Colors.grey[600],
                                    ),
                                  );
                                },
                              ),
                      ),
                      Positioned(
                        top: 180.h,
                        left: 20.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: widget.pharmacie.estDeGarde == 0
                                    ? Colors.red
                                    : Colors.green,
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 30.w,
                                    vertical: 5.h,
                                  ),
                                  child: Text(
                                    widget.pharmacie.estDeGarde == 0
                                        ? "Pas de garde"
                                        : "De garde",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.pharmacie.nomPharmacie,
                                style: TextStyle(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 2,
                              ),
                            ),
                            if (widget.pharmacie.distance != null)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(18.r),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 30.w,
                                      vertical: 5.h,
                                    ),
                                    child: Text(
                                      'A ${double.tryParse(widget.pharmacie.distance.toString())?.toStringAsFixed(2)} mètre de vous',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                //Section horaires d'ouverture
                Padding(
                  padding: EdgeInsets.all(18.w),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 5,
                          blurStyle: BlurStyle.inner,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.access_time_filled_sharp,
                            size: 30.r,
                            color: Couleurs.darkGreen,
                          ),
                          title: Text(
                            "HORAIRES D'OUVERTURE",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                            ),
                          ),
                        ),
                        horaires(
                          "Lundi-Vendredi",
                          widget.pharmacie.horaires_en_semaine ??
                              '08:30 - 21:30',
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey[300],
                          indent: 20,
                          endIndent: 20,
                        ),
                        horaires(
                          "Samedi",
                          widget.pharmacie.horaires_samedi ?? '08:30 - 15:30',
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey[300],
                          indent: 20,
                          endIndent: 20,
                        ),
                        horaires(
                          "Dimanche",
                          widget.pharmacie.horaires_dimanche ?? 'Fermée',
                        ),
                      ],
                    ),
                  ),
                ),
                //Section contacts pharmacie
                Padding(
                  padding: EdgeInsets.all(18.w),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 5,
                          blurStyle: BlurStyle.inner,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            CupertinoIcons.info_circle_fill,
                            size: 30.r,
                            color: Couleurs.darkGreen,
                          ),
                          title: Text(
                            "CONTACTS ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: Couleurs.lightGreen,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Icon(
                                CupertinoIcons.phone_solid,
                                color: Couleurs.darkGreen,
                              ),
                            ),
                          ),
                          title: Text(
                            "Numéro",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          subtitle: Text(
                            widget.pharmacie.numeroPharmacie,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: Couleurs.lightGreen,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Icon(
                                CupertinoIcons.mail_solid,
                                color: Couleurs.darkGreen,
                              ),
                            ),
                          ),
                          title: Text(
                            "Email",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          subtitle: Text(
                            widget.pharmacie.emailPharmacie ??
                                'Aucune email fourni',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        //Bouton d'action
                        Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    lancerAppel(widget.pharmacie.numeroPharmacie);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Couleurs.darkGreen,
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(10.w),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              CupertinoIcons.phone_solid,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 10.w),
                                            Text(
                                              "Appeler maintenant",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
                //Section localisation pharmacie
                Padding(
                  padding: EdgeInsets.all(18.w),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      color: Couleurs.primaryGreen,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 5,
                          blurStyle: BlurStyle.inner,
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          color: Couleurs.lightGreen,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15.w),
                          child: Icon(
                            Icons.location_on,
                            color: Couleurs.darkGreen,
                            size: 30.r,
                          ),
                        ),
                      ),
                      title: Text(
                        "Adresse pharmacie",
                        style: TextStyle(fontSize: 18.sp, color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.pharmacie.adresseFournit!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Carte(pharmacie: widget.pharmacie),
                                  ),
                                );
                              }
                            },
                            child: ListTile(
                              horizontalTitleGap: 0,
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Sur la carte",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Couleurs.accentOrange,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.deepOrangeAccent,
                                    size: 18.r,
                                  ),
                                ],
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //Assurances acceptées
                Padding(
                  padding: EdgeInsets.all(18.w),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 5,
                          blurStyle: BlurStyle.inner,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            CupertinoIcons.shield_lefthalf_fill,
                            color: Couleurs.darkGreen,
                            size: 30.r,
                          ),
                          title: Text(
                            "ASSURANCES ACCEPTEES",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Column(
                          children: widget.pharmacie.assuranceAcceptees
                              .asMap()
                              .entries
                              .map((entry) {
                                final index = entry.key;
                                final assurance = entry.value;
                                return Column(
                                  children: [
                                    cardAssurance(assurance),
                                    if (index <
                                        widget
                                                .pharmacie
                                                .assuranceAcceptees
                                                .length -
                                            1)
                                      Divider(
                                        color: Colors.grey[300],
                                        thickness: 1,
                                        indent: 25.w,
                                        endIndent: 25.w,
                                      ),
                                  ],
                                );
                              })
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                //Bouton d'action
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (dejaAbonne == true) {
                          await desouscrirAbonnement();
                          await abonne();
                        } else {
                          await sabonner();
                          await abonne();
                        }
                      },
                      label: Text(
                        dejaAbonne == true
                            ? "Desactiver les notifications"
                            : "Activer les notifications",
                        style: TextStyle(
                          color: dejaAbonne == true
                              ? Colors.grey[200]
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                      icon: Icon(
                        dejaAbonne == true
                            ? Icons.notifications_off_outlined
                            : Icons.notifications,
                        color: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dejaAbonne == true
                            ? Colors.grey
                            : Couleurs.accentOrange,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget cardAssurance(String assurances) {
    return Padding(
      padding: EdgeInsets.all(15.w),
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: Couleurs.primaryGreen,
          ),
          child: Padding(
            padding: EdgeInsets.all(15.w),
            child: Icon(Icons.shield_outlined, color: Colors.white),
          ),
        ),
        title: Text(
          assurances,
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.check_circle, color: Couleurs.darkGreen),
      ),
    );
  }

  Widget horaires(String jour, String heures) {
    return ListTile(
      leading: Text(jour, style: TextStyle(fontSize: 16.sp)),
      trailing: Text(
        heures ?? "Fermée",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
          color: (heures == "Fermé" || heures == "Fermée")
              ? Colors.red
              : Colors.black,
        ),
      ),
    );
  }
}
