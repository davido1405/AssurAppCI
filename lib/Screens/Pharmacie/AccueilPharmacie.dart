import 'package:assurappci/Models/AbonnementPharmacie.dart';
import 'package:assurappci/ViewModels/AbonnementPharmacieViewModel.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:assurappci/ViewModels/PharmacieViewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Accueilpharmacie extends StatefulWidget {
  const Accueilpharmacie({super.key});

  @override
  State<Accueilpharmacie> createState() => _AccueilpharmacieState();
}

class _AccueilpharmacieState extends State<Accueilpharmacie> {

  @override
  void initState() {
    super.initState();
    _chargerStatistiques();
    Future.microtask(typeAbonnement);
  }

  Future<void> _chargerStatistiques() async {
    final authVM = context.read<AuthViewModel>();
    final codePharmacier = authVM.session?.codeUtilisateur;

    if (codePharmacier != null) {
      // TODO: Charger les statistiques depuis l'API
      // await context.read<PharmacieViewModel>().chargerStatistiques(codePharmacier);
    }
  }

  Future<Map<String,dynamic>?>typeAbonnement()async{

    final authVM = context.read<AuthViewModel>();
    final codePharmacier = authVM.session?.codeUtilisateur;
    final abonnement=context.read<Abonnementpharmacieviewmodel>();
    
    try{
      final abonn=abonnement.chargerAbonnementActif(codePharmacier!);
      if(abonnement.errorMessage!=null){
        if(mounted){
          setState(() {
            abonnementActif=abonn as Map<String, dynamic>;
          });
        }
      }
    }catch(e){
      print (e);
    }
  }

  Map<String,dynamic>? abonnementActif;

  @override
  Widget build(BuildContext context) {
    final abonnementVM = context.watch<Abonnementpharmacieviewmodel>();
    final pharmacieVM = context.watch<PharmacieViewModel>();

    final nomPharmacie = pharmacieVM.pharmacie?.nomPharmacie ?? 'Ma Pharmacie';
    final photoPharmacie = pharmacieVM.pharmacie?.photoPharmacie;

    return RefreshIndicator(
      onRefresh: _chargerStatistiques,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== EN-TÊTE =====
            _buildHeader(nomPharmacie, photoPharmacie),

            SizedBox(height: 20.h),

            // ===== CARTE ABONNEMENT ACTUEL =====
            _buildCarteAbonnement(abonnementVM),

            SizedBox(height: 20.h),

            // ===== STATISTIQUES =====
            Text(
              'Statistiques',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 12.h),

            abonnementVM.nomForfaitActuel!="Gratuit"?
              _buildStatistiques():
                _buildStatEmptyState(),

            //SizedBox(height: 20.h),

            // ===== ACTIONS RAPIDES =====
            //Text('Actions rapides', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold,),),

            //SizedBox(height: 12.h),

            //_buildActionsRapides(context),

            SizedBox(height: 20.h),

            // ===== ACTIVITÉ RÉCENTE =====
            //_buildActiviteRecente(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String nomPharmacie, String? photoPharmacie) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrangeAccent, Colors.orangeAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: Colors.white,
            backgroundImage: photoPharmacie != null
                ? NetworkImage(photoPharmacie)
                : null,
            child: photoPharmacie == null
                ? Icon(Icons.local_pharmacy, size: 30.sp, color: Colors.deepOrangeAccent)
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenue',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  nomPharmacie,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarteAbonnement(Abonnementpharmacieviewmodel abonnementVM) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.workspace_premium, color: Colors.amber, size: 24.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Forfait actuel',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Actif',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            abonnementVM.nomForfaitActuel,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          if (abonnementVM.joursRestants > 0)
            Text(
              '${abonnementVM.joursRestants} jours restants',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
            ),
          SizedBox(height: 16.h),
          Divider(),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gérer votre abonnement dans Abonnement',
                style: TextStyle(
                  color: Colors.deepOrangeAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistiques() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: Icons.visibility,
          titre: 'Vues',
          valeur: '1,234',
          couleur: Colors.blue,
        ),
        _buildStatCard(
          icon: Icons.people,
          titre: 'Abonnés',
          valeur: '89',
          couleur: Colors.green,
        ),
        _buildStatCard(
          icon: Icons.campaign,
          titre: 'Annonces',
          valeur: '5',
          couleur: Colors.orange,
        ),
        _buildStatCard(
          icon: Icons.email,
          titre: 'Newsletters',
          valeur: '12',
          couleur: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required String titre, required String valeur, required Color couleur,}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: couleur.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: couleur, size: 20.sp),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valeur,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                titre,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRapides(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.add,
            titre: 'Nouvelle annonce',
            onTap: () {
              // TODO: Navigation vers créer annonce
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildActionButton(
            icon: Icons.edit,
            titre: 'Modifier profil',
            onTap: () {
              // TODO: Navigation vers profil
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String titre, required VoidCallback onTap,}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.deepOrangeAccent, size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiviteRecente() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activité récente',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Column(
              children: [
                Icon(Icons.inbox, size: 48.sp, color: Colors.grey[400]),
                SizedBox(height: 8.h),
                Text(
                  'Aucune activité récente',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatEmptyState() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistique',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Column(
              children: [
                Icon(Icons.data_saver_off, size: 48.sp, color: Colors.grey[400]),
                SizedBox(height: 8.h),
                Text(
                  'Choisissez un autre forfait pour voir vos statistiques',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}