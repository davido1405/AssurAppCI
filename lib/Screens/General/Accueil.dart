import 'package:assurappci/Constants/Couleurs.dart';
import 'package:assurappci/Models/Pharmacie.dart';
import 'package:assurappci/Models/Session.dart';
import 'package:assurappci/Repositories/NewsLetterRepository.dart';
import 'package:assurappci/Screens/General/Carte.dart';
import 'package:assurappci/Screens/General/DetailsPharmacie.dart';
import 'package:assurappci/Screens/General/Newsletters.dart';
import 'package:assurappci/Services/fcm_service.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:assurappci/ViewModels/NewsletterViewModel.dart';
import 'package:assurappci/ViewModels/NotificationsViewModel.dart';
import 'package:assurappci/ViewModels/PharmacieViewModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () async => {
        //await _getPosition(),
        await recupererPharmacie(),
        await FCMService.getToken(),
      },
    );
  }

  String filtre = "tous";
  List<Pharmacie> toutesPharmacies = [];

  bool? chargementEncour;

  String lat = '5.315426';
  String long = '-4.229491';

  TextEditingController terme = TextEditingController();

  Future<void> recupererPharmacie() async {
    final pharmacieViewModel = context.read<PharmacieViewModel>();

    if (mounted) {
      setState(() {
        chargementEncour = true;
      });
    }

    await pharmacieViewModel.init().timeout(Duration(seconds: 10));

    if (mounted) {
      setState(() {
        chargementEncour = false;
      });
    }
    if (pharmacieViewModel.errorMessage == null) {
      switch (filtre) {
        case "tous":
          final ville =
              context.read<AuthViewModel>().session?.villeUtilisateur ?? '';
          print(ville);
          if (mounted) {
            setState(() {
              toutesPharmacies = pharmacieViewModel.pharmacies
                  .where((p) => p.villePharmacie!.contains(ville))
                  .toList();
            });
          }
        case "assurance":
          final ville =
              context.read<AuthViewModel>().session?.villeUtilisateur ?? '';
          final assurance =
              context.read<AuthViewModel>().session?.nomAssuranceUtilisateur ??
              '';
          if (mounted) {
            setState(() {
              toutesPharmacies = pharmacieViewModel.pharmacies
                  .where(
                    (p) =>
                        p.assuranceAcceptees.any((a) => a.contains(assurance)),
                  )
                  .map((p) => p.villePharmacie?.contains(ville))
                  .cast<Pharmacie>()
                  .toList()
                  .toList();
            });
          }
        case "adresse":
          final adresse =
              context
                  .read<AuthViewModel>()
                  .session
                  ?.adresseUtilisateurFournit ??
              '';
          if (mounted) {
            setState(() {
              toutesPharmacies = pharmacieViewModel.pharmacies
                  .where((p) => p.adresseFournit!.contains(adresse))
                  .toList();
            });
          }
        case "degarde":
          if (mounted) {
            setState(() {
              toutesPharmacies = pharmacieViewModel.pharmacies
                  .where((p) => p.estDeGarde == 1)
                  .toList();
            });
          }
        default:
          final ville =
              context.read<AuthViewModel>().session?.villeUtilisateur ?? '';
          print(ville);
          if (mounted) {
            setState(() {
              toutesPharmacies = pharmacieViewModel.pharmacies
                  .where((p) => p.villePharmacie!.contains(ville))
                  .toList();
            });
          }
      }
    } else {
      print(pharmacieViewModel.errorMessage);
    }
  }

  Future<void> rechercherPharmacie() async {
    if (mounted) {
      setState(() {
        chargementEncour = true;
      });
    }

    final resultat = await context
        .read<PharmacieViewModel>()
        .rechercherPharmacie(
          terme.text.isEmpty ? null : terme.text,
          double.tryParse(lat),
          double.tryParse(long),
        );
    if (mounted) {
      setState(() {
        chargementEncour = false;
      });
    }

    if (mounted && chargementEncour == false) {
      if (resultat.isNotEmpty) {
        setState(() {
          toutesPharmacies = resultat ?? [];
        });
      } else {
        setState(() {
          toutesPharmacies = [];
        });
      }
    }
  }

  //Récupérer position de l'utilisateur*
  Future<void> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
        'Veuillez autoriter la localisation pour cette application',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Localisation non autorisé");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        "Localisation n'est pas autorisé. Nous ne pouvons pas accéder à votre position",
      );
    }
    Position position = await Geolocator.getCurrentPosition();

    if (mounted) {
      setState(() {
        lat = position.latitude.toString();
        long = position.longitude.toString();
      });
      print(lat);
      print(long);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Couleurs.lightGreen,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: recupererPharmacie,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Trouvez la pharmacie idéale partout 🚀",
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
                                  "Localisez toutes les pharmacies autour de vous dans un rayoon de 5KM 😎 et vérifiez les assurances utilisées instantanément 👌",
                                  //textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16.sp),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        tileColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                        ),
                        leading: Icon(Icons.search),
                        title: TextField(
                          controller: terme,
                          decoration: InputDecoration(
                            hintText:
                                "Entrez un nom de pharmacie ou assurance",
                            border: InputBorder.none,
                          ),
                        ),
                        trailing: GestureDetector(
                          onTap: () async {
                            if (mounted) {
                              setState(() {
                                filtre = "tous";
                              });
                            }
                            await rechercherPharmacie();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Couleurs.accentOrange,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 25.w,
                                vertical: 10.h,
                              ),
                              child: Text(
                                "Rechercher",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 30.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  filtre = "tous";
                                });

                                recupererPharmacie();
                              },
                              label: Text(
                                "Toutes les pharmacies",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: filtre == "tous"
                                      ? Colors.white
                                      : Couleurs.darkGreen,
                                ),
                              ),
                              icon: Icon(
                                CupertinoIcons.globe,
                                color: filtre == "tous"
                                    ? Colors.white
                                    : Couleurs.darkGreen,
                              ),
                              style: TextButton.styleFrom(
                                side: filtre == "tous"
                                    ? null
                                    : BorderSide(
                                        color: Couleurs.darkGreen,
                                        width: 2,
                                      ),
                                backgroundColor: filtre == "tous"
                                    ? Couleurs.darkGreen
                                    : Colors.white,
                              ),
                            ),
                            SizedBox(width: 15.w),
                            TextButton.icon(
                              onPressed: () async {
                                setState(() {
                                  filtre = "adresse";
                                });
                                await rechercherPharmacie();
                              },
                              label: Text(
                                "Près de moi",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: filtre == "adresse"
                                      ? Colors.white
                                      : Couleurs.darkGreen,
                                ),
                              ),
                              icon: Icon(
                                filtre == "adresse"
                                    ? Icons.location_on
                                    : Icons.location_on_outlined,
                                color: filtre == "adresse"
                                    ? Colors.white
                                    : Couleurs.darkGreen,
                              ),
                              style: TextButton.styleFrom(
                                side: filtre == "adresse"
                                    ? null
                                    : BorderSide(
                                        color: Couleurs.darkGreen,
                                        width: 2,
                                      ),
                                backgroundColor: filtre == "adresse"
                                    ? Couleurs.darkGreen
                                    : Colors.white,
                              ),
                            ),
                            SizedBox(width: 15.w),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  filtre = "assurance";
                                });
                                recupererPharmacie();
                              },
                              label: Text(
                                "Assurances",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: filtre == "assurance"
                                      ? Colors.white
                                      : Couleurs.darkGreen,
                                ),
                              ),
                              icon: Icon(
                                filtre == "assurance"
                                    ? Icons.shield
                                    : Icons.shield_outlined,
                                color: filtre == "assurance"
                                    ? Colors.white
                                    : Couleurs.darkGreen,
                              ),
                              style: TextButton.styleFrom(
                                side: filtre == "assurance"
                                    ? null
                                    : BorderSide(
                                        color: Couleurs.darkGreen,
                                        width: 2,
                                      ),
                                backgroundColor: filtre == "assurance"
                                    ? Couleurs.darkGreen
                                    : Colors.white,
                              ),
                            ),
                            SizedBox(width: 15.w),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  filtre = "degarde";
                                });
                                recupererPharmacie();
                              },
                              label: Text(
                                "De garde",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: filtre == "degarde"
                                      ? Colors.white
                                      : Couleurs.darkGreen,
                                ),
                              ),
                              icon: Icon(
                                filtre == "degarde"
                                    ? Icons.nights_stay
                                    : Icons.nights_stay_outlined,
                                color: filtre == "degarde"
                                    ? Colors.white
                                    : Couleurs.darkGreen,
                              ),
                              style: TextButton.styleFrom(
                                side: filtre == "degarde"
                                    ? null
                                    : BorderSide(
                                        color: Couleurs.darkGreen,
                                        width: 2,
                                      ),
                                backgroundColor: filtre == "degarde"
                                    ? Couleurs.darkGreen
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),
                chargementEncour == true
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 150.h,
                        ),
                        child: CircularProgressIndicator(
                          color: Couleurs.primaryGreen,
                        ),
                      )
                    : toutesPharmacies.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 75.h,
                        ),
                        child: pharmacieEmptyState(),
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: toutesPharmacies.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    cardPharmacie(toutesPharmacies[index]),
                                    if (index < toutesPharmacies.length - 1)
                                      Divider(
                                        height: 10.h,
                                        thickness: 0,
                                        color: Colors.transparent,
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget cardPharmacie(Pharmacie pharmacie) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //Image pharmacie
          Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        topRight: Radius.circular(12.r),
                      ),
                      child: pharmacie.photoPharmacie != null
                          ? Image.network(
                              pharmacie.photoPharmacie!,
                              width: 125.w,
                              // ✅ Correction 2
                              height: 300.h,
                              // ✅ Correction 3
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100.w,
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
                              "assets/images/a.jpg",
                              width: 100.w,
                              height: 110.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100.w,
                                  height: 110.h,
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
                  ),
                ],
              ),
              Positioned(
                top: 9.h,
                left: pharmacie.estDeGarde == 0 ? 220.w : 255.w,
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: pharmacie.estDeGarde == 0
                            ? Couleurs.emergencyRed
                            : Couleurs.darkGreen,
                        borderRadius: BorderRadius.circular(18.r),
                        border: BoxBorder.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 30.w,
                            vertical: 5.h,
                          ),
                          child: Text(
                            pharmacie.estDeGarde == 0
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
                  ],
                ),
              ),
            ],
          ),
          SizedBox(width: 12.h),
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              children: [
                Row(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        pharmacie.nomPharmacie,
                        style: TextStyle(
                          fontSize: 25.sp,
                          fontWeight: FontWeight.bold,
                          color: Couleurs.darkGreen,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Couleurs.darkGreen,
                      size: 25.r,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      pharmacie.adresseFournit ?? "Aucune adresse fournit",
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Wrap(
                  children: [
                    for (var assurance in pharmacie.assuranceAcceptees)
                      Padding(
                        padding: EdgeInsets.all(10.w),
                        child: Chip(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          label: Text(
                            assurance,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Couleurs.lightGreen,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (mounted) {
                            print(pharmacie);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Detailspharmacie(pharmacie: pharmacie),
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Couleurs.accentOrange,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    "Voir détails",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    GestureDetector(
                      onTap: () async {
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Carte(pharmacie: pharmacie),
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Couleurs.lightGreen,
                          border: Border(
                            top: BorderSide(
                              color: Couleurs.darkGreen,
                              width: 1,
                            ),
                            bottom: BorderSide(
                              color: Couleurs.darkGreen,
                              width: 1,
                            ),
                            left: BorderSide(
                              color: Couleurs.darkGreen,
                              width: 1,
                            ),
                            right: BorderSide(
                              color: Couleurs.darkGreen,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Icon(
                            Icons.directions,
                            color: Couleurs.darkGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget pharmacieEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.grey, offset: Offset.zero)],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Icon(Icons.info_outlined, size: 50, color: Colors.grey),
              ),
            ),
            Text(
              "Oups !",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5.h),
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Aucune pharmacie disponible pour le moment",
                  style: TextStyle(fontSize: 18.sp),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await recupererPharmacie();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: Couleurs.darkGreen,
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Text(
                            "Réessayer",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
