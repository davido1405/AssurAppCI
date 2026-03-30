// Screens/Pharmacie/AbonnementPharmacie.dart

import 'package:assurappci/Constants/Couleurs.dart';
import 'package:assurappci/Models/AbonnementPharmacie.dart';
import 'package:assurappci/ViewModels/AbonnementPharmacieViewModel.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Abonnementpharmacie extends StatefulWidget {
  const Abonnementpharmacie({super.key});

  @override
  State<Abonnementpharmacie> createState() => _AbonnementpharmacieState();
}

class _AbonnementpharmacieState extends State<Abonnementpharmacie> {
  List<Forfait> toutForfait = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(recupererDifferentsPlan);
  }

  // ✅ CORRECTION 1 : Enlever setState et async/await mal placés
  Future<void> recupererDifferentsPlan() async {
    try {
      print('=== CHARGEMENT FORFAITS ===');

      final forfaits = context.read<Abonnementpharmacieviewmodel>();
      final resultats = await forfaits.chargerForfaits();

      if (mounted && resultats != null) {
        setState(() {
          toutForfait = resultats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement forfaits: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> souscrireForfait(
      String codeGerant,
      String nomForfait,
      String modePaiement,
      ) async {
    print("Souscription au forfait: $nomForfait");

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text('Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Voulez-vous souscrire au forfait $nomForfait ?'),
            SizedBox(height: 12),
            if (nomForfait != 'Gratuit') ...[
              Text(
                'Mode de paiement : $modePaiement',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              BuildContext? loaderContext;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext ctx) {
                  loaderContext = ctx;
                  return WillPopScope(
                    onWillPop: () async => false,
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Souscription en cours...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );

              try {
                final souscription = context.read<Abonnementpharmacieviewmodel>();

                bool resultat = await souscription.souscrireForfait(
                  codePharmacier: codeGerant,
                  nomForfait: nomForfait,
                  modePaiement: modePaiement,
                );

                if (loaderContext != null && mounted) {
                  Navigator.of(loaderContext!).pop();
                }

                if (mounted) {
                  if (resultat && souscription.errorMessage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('✅ Forfait $nomForfait souscrit avec succès !'),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                    await souscription.chargerAbonnementActif(codeGerant);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                souscription.errorMessage ??
                                    'Impossible de souscrire au forfait $nomForfait',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (loaderContext != null && mounted) {
                  Navigator.of(loaderContext!).pop();
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(child: Text('❌ Erreur: $e')),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 4),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }

                print('❌ Exception souscrireForfait: $e');
              }
            },
            child: Text('Confirmer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //Intitué de l'écran
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          child: Text(
                            "ESPACE ABONNEMENT",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Couleurs.accentOrange,
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            "Elevez le niveau de votre pharmacie 🚀",
                            style: TextStyle(
                              fontSize: 25.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "Sélectionnez l'abonnement premium pour passer à un niveau supérieur et bénéficier de tous les avantages de GoPharma",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ===== PLAN ACTUEL =====
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: LinearGradient(
                  colors: [Couleurs.primaryGreen, Couleurs.darkGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Votre plan actuel",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          context.watch<Abonnementpharmacieviewmodel>().nomForfaitActuel ?? 'Aucun',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 24.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "${context.watch<Abonnementpharmacieviewmodel>().prixForfaitActuel ?? '0'} FCFA",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28.sp,
                          ),
                        ),
                        Text(
                          "/mois",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 25.h),
                        GestureDetector(
                          onTap: () {
                            print("Gérer l'abonnement");
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 10.h,
                              ),
                              child: Text(
                                "Gérer",
                                style: TextStyle(
                                  color: Couleurs.darkGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
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
            ),

            SizedBox(height: 30.h),

            // ===== TITRE SECTION =====
            Text(
              "Choisir un forfait",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16.h),

            // ✅ CORRECTION 2 : Afficher loader ou liste
            _isLoading
                ? Center(
              child: Padding(
                padding: EdgeInsets.all(40.h),
                child: CircularProgressIndicator(),
              ),
            )
                : toutForfait.isEmpty
                ? Center(
              child: Padding(
                padding: EdgeInsets.all(40.h),
                child: Text(
                  'Aucun forfait disponible',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
                : Column(
              children: toutForfait
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                final forfait = entry.value;

                return Column(
                  children: [
                    cardForfait(
                      context: context,
                      titre: forfait.nomForfait,
                      montant: '${forfait.prix} FCFA',
                      description: forfait.description ?? '',
                      avantageForfait: forfait.fonctionnalites
                          .map((f) => f.nom)
                          .toList(),
                      estRecommande: forfait.nomForfait == 'Standard',
                      action: () => souscrireForfait(
                        context.read<AuthViewModel>().session?.codeUtilisateur ?? '',
                        forfait.nomForfait,
                        "Wave",
                      ),
                    ),
                    // ✅ Ajouter SizedBox sauf pour le dernier
                    if (index < toutForfait.length - 1)
                      SizedBox(height: 15.h),
                  ],
                );
              })
                  .toList(),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

// ===== WIDGET CARD FORFAIT =====
Widget cardForfait({required BuildContext context, required String titre, required String montant, required String description, required List<String> avantageForfait, required bool estRecommande, required VoidCallback action,}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: estRecommande ? Couleurs.darkGreen : Colors.grey[300]!,
        width: estRecommande ? 2.w : 1.w,
      ),
      borderRadius: BorderRadius.circular(16.r),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // EN-TÊTE
        Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: estRecommande ? Couleurs.lightGreen : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Icon(
                            estRecommande ? Icons.star : Icons.shield_outlined,
                            color: estRecommande ? Colors.blue : Colors.grey[600],
                            size: 24.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        titre,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22.sp,
                        ),
                      ),
                    ],
                  ),
                  if (estRecommande)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Couleurs.darkGreen,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Recommandé',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                montant,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28.sp,
                  color: Colors.black87,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),

        Divider(height: 1, color: Colors.grey[200]),

        // AVANTAGES
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: avantageForfait.map((avantage) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Couleurs.darkGreen,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        avantage,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // BOUTON
        Padding(
          padding: EdgeInsets.all(20.w),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: action,
              style: ElevatedButton.styleFrom(
                backgroundColor: estRecommande ? Couleurs.darkGreen : Colors.grey[200],
                foregroundColor: estRecommande ? Colors.white : Colors.black87,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Souscrire',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}