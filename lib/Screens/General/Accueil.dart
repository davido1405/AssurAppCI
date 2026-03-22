import 'package:assurappci/Models/Pharmacie.dart';
import 'package:assurappci/Models/Session.dart';
import 'package:assurappci/Repositories/NewsLetterRepository.dart';
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
    // TODO: implement initState
    super.initState();

    Future.microtask(
      () async => {
        await recupererPharmacie(),
        await FCMService.getToken(),
        await badgeNotifications(),
        await _getPosition(),
      },
    );
  }

  String filtre = "tous";
  List<Pharmacie> toutesPharmacies = [];
  int totalNotifs = 0;

  String lat = '';
  String long = '';

  TextEditingController terme = TextEditingController();

  Future<void> recupererPharmacie() async {
    final pharmacieViewModel = context.read<PharmacieViewModel>();
    await pharmacieViewModel.init();

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

  Future<void> badgeNotifications() async {
    try{
      final utilisateur = context.read<AuthViewModel>().session?.codeUtilisateur;
      if(utilisateur ==null || utilisateur.isEmpty){
        return ;
      }
      final notifs = await context.read<Notificationsviewmodel>();
      await notifs.init(utilisateur);
      if (mounted && notifs.errorMessage == null) {

          setState(() {
            totalNotifs= notifs.nombreNotifs!;
          });
      }
    }catch(e,stackTrace){
      print('❌ Erreur badgeNotifications: $e');
      print('StackTrace: $stackTrace');
    }
  }

  Future<void> rechercherPharmacie() async {
    final resultat = await context
        .read<PharmacieViewModel>()
        .rechercherPharmacie(
          terme.text.isEmpty ? null : terme.text,
          double.tryParse(lat),
          double.tryParse(long),
        );

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

  //Récupérer position de l'utilisateur*
  Future<Position> _getPosition() async {
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
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[100],
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: recupererPharmacie,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Padding(
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
                                Text(
                                  "Salut ! Bienvenu(e)",
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "${context.watch<AuthViewModel>().session?.nomUtilisateur} ${context.watch<AuthViewModel>().session?.prenomUtilisateur}" ??
                                        'Utilisateur',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              child: Row(
                                children: [
                                  Badge(
                                    label: Text("$totalNotifs"),
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Newsletters(),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.notifications_outlined),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.settings),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        TextField(
                          controller: terme,
                          decoration: InputDecoration(
                            hintText: "Rechercher",
                            suffixIcon: IconButton(
                              onPressed: () async {
                                print("Recherche lancé");
                                await rechercherPharmacie();
                              },
                              icon: Icon(Icons.search),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.r),
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
                                        : Colors.deepOrangeAccent,
                                  ),
                                ),
                                icon: Icon(
                                  CupertinoIcons.globe,
                                  color: filtre == "tous"
                                      ? Colors.white
                                      : Colors.deepOrangeAccent,
                                ),
                                style: TextButton.styleFrom(
                                  side: filtre == "tous"
                                      ? null
                                      : BorderSide(
                                          color: Colors.deepOrangeAccent,
                                          width: 2,
                                        ),
                                  backgroundColor: filtre == "tous"
                                      ? Colors.deepOrangeAccent
                                      : Colors.white,
                                ),
                              ),
                              SizedBox(width: 15.w),
                              TextButton.icon(
                                onPressed: () async {
                                  setState(() {
                                    filtre = "adresse";
                                  });
                                  if (long.isEmpty || lat.isEmpty) {
                                    _getPosition().then((value) {
                                      lat = '${value.latitude}';
                                      long = '${value.longitude}';
                                    });
                                    rechercherPharmacie();
                                  }
                                  rechercherPharmacie();
                                },
                                label: Text(
                                  "Près de moi",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: filtre == "adresse"
                                        ? Colors.white
                                        : Colors.deepOrangeAccent,
                                  ),
                                ),
                                icon: Icon(
                                  filtre == "adresse"
                                      ? Icons.location_on
                                      : Icons.location_on_outlined,
                                  color: filtre == "adresse"
                                      ? Colors.white
                                      : Colors.deepOrangeAccent,
                                ),
                                style: TextButton.styleFrom(
                                  side: filtre == "adresse"
                                      ? null
                                      : BorderSide(
                                          color: Colors.deepOrangeAccent,
                                          width: 2,
                                        ),
                                  backgroundColor: filtre == "adresse"
                                      ? Colors.deepOrangeAccent
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
                                        : Colors.deepOrangeAccent,
                                  ),
                                ),
                                icon: Icon(
                                  filtre == "assurance"
                                      ? Icons.shield
                                      : Icons.shield_outlined,
                                  color: filtre == "assurance"
                                      ? Colors.white
                                      : Colors.deepOrangeAccent,
                                ),
                                style: TextButton.styleFrom(
                                  side: filtre == "assurance"
                                      ? null
                                      : BorderSide(
                                          color: Colors.deepOrangeAccent,
                                          width: 2,
                                        ),
                                  backgroundColor: filtre == "assurance"
                                      ? Colors.deepOrangeAccent
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Liste des pharmacies",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25.sp,
                            ),
                          ),
                          Text(
                            "${toutesPharmacies.length}",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: toutesPharmacies.length,
                        itemBuilder: (context, index) {
                          return cardPharmacie(toutesPharmacies[index]);
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
    return GestureDetector(
      onTap: () async {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Detailspharmacie(pharmacie: pharmacie),
            ),
          );
        }
      },
      child: SizedBox(
        height: pharmacie.estDeGarde == 1 ? 180.h : 125.h, // ✅ Correction 1
        child: Card(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: pharmacie.photoPharmacie != null
                    ? Image.network(
                        pharmacie.photoPharmacie!,
                        width: pharmacie.estDeGarde == 1 ? 125.w : 100.w,
                        // ✅ Correction 2
                        height: pharmacie.estDeGarde == 1 ? 130.h : 110.h,
                        // ✅ Correction 3
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
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        pharmacie.nomPharmacie,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            pharmacie.adresseFournit ??
                                'Adresse non disponible',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[500],
                              fontSize: 13.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: Text(
                        pharmacie.villePharmacie ?? "Ville inconnue",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 3,
                          child: Container(
                            height: 35.h,
                            decoration: BoxDecoration(
                              color: pharmacie.libelleStatut == "Actif"
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: Text(
                                "Ouvert de ${pharmacie.horrairesOuverture}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),

                        if (toutesPharmacies.isNotEmpty &&
                            filtre == "adresse" &&
                            pharmacie.distance != null) ...[
                          SizedBox(width: 8.w),
                          Container(
                            height: 32.h,
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepOrangeAccent,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.near_me,
                                  color: Colors.white,
                                  size: 14.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  pharmacie.distance as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (pharmacie.estDeGarde == 1 ?? false) ...[
                      // ✅ Correction 4
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 32.h,
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.deepOrangeAccent,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.nights_stay,
                                    color: Colors.white,
                                    size: 14.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "DE GARDE",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
