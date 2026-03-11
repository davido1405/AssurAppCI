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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(recupererDifferentsPlan);
  }

  // Plan actuel (à récupérer depuis l'API plus tard)
  String planActuel = "Standard";
  String prixActuel = "15000 FCFA";

  List<Forfait>toutForfait=[];

  Future<void> souscrireForfait(
      String codeGerant,
      String nomForfait,
      String modePaiement,
      ) async {
    print("Souscription au forfait: $nomForfait");

    // Afficher un dialogue de confirmation
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(  // ✅ Renommer pour clarté
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
            onPressed: () => Navigator.pop(dialogContext),  // ✅ Utiliser dialogContext
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);  // ✅ Fermer le dialogue de confirmation

              // ✅ Afficher un loader pendant le traitement
              BuildContext? loaderContext;
              showDialog(
                context: context,
                barrierDismissible: false,  // Empêche de fermer en cliquant à côté
                builder: (BuildContext ctx) {
                  loaderContext = ctx;  // Sauvegarder le contexte du loader
                  return WillPopScope(
                    onWillPop: () async => false,  // Empêche le retour arrière
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
                // ✅ Récupérer le ViewModel
                final souscription = context.read<Abonnementpharmacieviewmodel>();

                // ✅ Appeler la méthode de souscription
                bool resultat = await souscription.souscrireForfait(
                  codePharmacier: codeGerant,
                  nomForfait: nomForfait,
                  modePaiement: modePaiement,
                );

                // ✅ Fermer le loader
                if (loaderContext != null && mounted) {
                  Navigator.of(loaderContext!).pop();
                }

                // ✅ Vérifier le résultat APRÈS l'appel
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

                    // ✅ Recharger les données de l'abonnement
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
                // ✅ Fermer le loader en cas d'erreur
                if (loaderContext != null && mounted) {
                  Navigator.of(loaderContext!).pop();
                }

                // ✅ Afficher l'erreur
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
  Future<List<Forfait>?>recupererDifferentsPlan()async{
    Abonnementpharmacieviewmodel forfaits=context.read<Abonnementpharmacieviewmodel>();

    if(forfaits.errorMessage==null){
      if(mounted){
        setState(() async {
              toutForfait=(await forfaits.chargerForfaits())!;
        });
      }
    }
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
            // ===== PLAN ACTUEL =====
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: LinearGradient(
                  colors: [Colors.lightBlue, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Informations du plan
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
                          context.watch<Abonnementpharmacieviewmodel>().nomForfaitActuel,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 24.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text("${context.watch<Abonnementpharmacieviewmodel>().prixForfaitActuel} FCFA",
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

                    // Actions
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
                            // TODO: Gérer l'abonnement
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
                                  color: Colors.blue,
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
            if(toutForfait.isEmpty)
              CircularProgressIndicator(),
            Column(
              children: toutForfait.expand((forfait)=>[cardForfait(context: context, titre: forfait.nomForfait, montant: '${forfait.prix} FCFA', description: '${forfait.description}', avantageForfait: forfait.fonctionnalites.map((fonctionnalite)=>fonctionnalite.nom).toList(), estRecommande: forfait.nomForfait=='Standard'?true:false, action: ()=>souscrireForfait(context.read<AuthViewModel>().session?.codeUtilisateur as String, forfait.nomForfait, "Wave")),SizedBox(height: 15.h,)]).toList()..removeLast(),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

// ✅ Widget cardForfait corrigé
Widget cardForfait({required BuildContext context, required String titre, required String montant, required String description, required List<String> avantageForfait, required bool estRecommande, required VoidCallback action,}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: estRecommande ? Colors.blue : Colors.grey[300]!,
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
        // ===== EN-TÊTE =====
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
                          color: estRecommande ? Colors.blue[100] : Colors.grey[200],
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
                        color: Colors.green,
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

              // Prix
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    montant,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28.sp,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              // Description
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),

        Divider(height: 1, color: Colors.grey[200]),

        // ===== AVANTAGES =====
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
                      color: Colors.green,
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

        // ===== BOUTON ACTION =====
        Padding(
          padding: EdgeInsets.all(20.w),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: action,
              style: ElevatedButton.styleFrom(
                backgroundColor: estRecommande ? Colors.blue : Colors.grey[200],
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