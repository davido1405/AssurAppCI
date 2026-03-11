import 'package:assurappci/Repositories/AbonnementPharmacieRepository.dart';
import 'package:assurappci/Repositories/PharmacieRespository.dart';
import 'package:assurappci/Screens/Auth/Connexion.dart';
import 'package:assurappci/Screens/Pharmacie/AbonnementPharmacie.dart';
import 'package:assurappci/Screens/Pharmacie/AccueilPharmacie.dart';
import 'package:assurappci/Screens/Pharmacie/Annonces.dart';
import 'package:assurappci/Screens/Pharmacie/Newsletter.dart';
import 'package:assurappci/Screens/Pharmacie/ProfilPharmacie.dart';
import 'package:assurappci/ViewModels/AbonnementPharmacieViewModel.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:assurappci/ViewModels/PharmacieViewModel.dart';
import 'package:assurappci/constants/fonctionnalites.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class DashboardGerant extends StatefulWidget {
  const DashboardGerant({super.key});

  @override
  State<DashboardGerant> createState() => _DashboardGerantState();
}

class _DashboardGerantState extends State<DashboardGerant> {
  String pageActive = "accueil";

  // ViewModels partagés pour tout le dashboard
  late Abonnementpharmacieviewmodel _abonnementVM;
  late PharmacieViewModel _pharmacieVM;

  @override
  void initState() {
    super.initState();

    // Initialiser les ViewModels
    _abonnementVM = Abonnementpharmacieviewmodel(Abonnementpharmacierepository());
    _pharmacieVM = PharmacieViewModel(Pharmacierespository());

    // Charger les données initiales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerDonneesInitiales();
    });
  }

  Future<void> _chargerDonneesInitiales() async {
    final authVM = context.read<AuthViewModel>();
    final codePharmacier = authVM.session?.codeUtilisateur;

    if (codePharmacier != null) {
      // Charger l'abonnement actif et les forfaits
      await _abonnementVM.chargerAbonnementActif(codePharmacier);
      await _abonnementVM.chargerForfaits();

      // Charger le profil de la pharmacie
      await _pharmacieVM.recupererProfilPharmacie(codePharmacier);
    }
  }

  /// ✅ VÉRIFICATION D'ACCÈS AVANT NAVIGATION
  Future<void> _verifierEtNaviguer(String page, String? codeFonctionnalite) async {
    final authVM = context.read<AuthViewModel>();
    final codePharmacier = authVM.session?.codeUtilisateur;

    if (codePharmacier == null) {
      _afficherErreur('Session expirée. Veuillez vous reconnecter.');
      return;
    }

    // ✅ Si la page ne nécessite pas de vérification, naviguer directement
    if (codeFonctionnalite == null) {
      _naviguer(page);
      return;
    }

    // ✅ Afficher un loader pendant la vérification
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // ✅ Vérifier l'accès à la fonctionnalité
      final acces = await _abonnementVM.verifierAccesFonctionnalite(
        codePharmacier: codePharmacier,
        codeFonctionnalite: codeFonctionnalite,
      );

      // Fermer le loader
      if (mounted) Navigator.pop(context);

      if (acces != null && acces.acces) {
        // ✅ Accès autorisé
        _naviguer(page);

        // Afficher info sur la limite si applicable
        if (acces.limite != null && acces.restant != null) {
          _afficherInfoLimite(
            codeFonctionnalite,
            acces.utilise ?? 0,
            acces.limite!,
            acces.restant!,
          );
        }
      } else {
        // ❌ Accès refusé
        _afficherDialogueUpgrade(
          codeFonctionnalite,
          acces?.raison ?? 'Fonctionnalité non disponible dans votre forfait',
        );
      }
    } catch (e) {
      // Fermer le loader
      if (mounted) Navigator.pop(context);

      print('❌ Erreur vérification accès: $e');
      _afficherErreur('Erreur lors de la vérification. Veuillez réessayer.');
    }
  }

  /// Navigation simple (sans fermer le drawer)
  void _naviguer(String page) {
    setState(() {
      pageActive = page;
    });
    Navigator.of(context).pop(); // Fermer le drawer
  }

  /// Afficher un message d'erreur
  void _afficherErreur(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Afficher info sur l'utilisation (limite atteinte bientôt)
  void _afficherInfoLimite(String fonctionnalite, int utilise, int limite, int restant) {
    if (restant <= 2 && restant > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ Attention: Plus que $restant utilisation(s) restante(s) pour cette fonctionnalité ce mois-ci',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  /// Dialogue pour proposer un upgrade
  void _afficherDialogueUpgrade(String fonctionnalite, String raison) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock, color: Colors.orange),
            SizedBox(width: 8.w),
            Text('Accès restreint'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(raison),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Passez à un forfait supérieur pour débloquer cette fonctionnalité',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Rediriger vers la page abonnements
              setState(() {
                pageActive = 'abonnements';
              });
            },
            icon: Icon(Icons.workspace_premium, size: 18.sp),
            label: Text('Voir les forfaits'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrangeAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final nomUtilisateur = authVM.session?.nomUtilisateur ?? 'Utilisateur';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _abonnementVM),
        ChangeNotifierProvider.value(value: _pharmacieVM),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Espace Pharmacie",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.deepOrangeAccent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
            // Badge abonnement
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        _abonnementVM.nomForfaitActuel,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        drawer: _buildDrawer(nomUtilisateur),
        body: Container(
          color: Colors.grey[100],
          child: SafeArea(child: _chargerPages()),
        ),
      ),
    );
  }

  Widget _buildDrawer(String nomUtilisateur) {
    return Drawer(
      child: Column(
        children: [
          // Header avec informations utilisateur
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.deepOrangeAccent,
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35.r,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40.sp,
                      color: Colors.deepOrangeAccent,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    nomUtilisateur,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Gérant',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Badge abonnement
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 14.sp),
                        SizedBox(width: 4.w),
                        Text(
                          _abonnementVM.nomForfaitActuel,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(height: 8.h),

                // ✅ Accueil - Pas de vérification
                _buildMenuItem(
                  icon: pageActive == "accueil" ? Icons.home : Icons.home_outlined,
                  titre: "Accueil",
                  isActive: pageActive == "accueil",
                  onTap: () => _verifierEtNaviguer("accueil", null),
                ),

                // ✅ Profil - Pas de vérification (fonctionnalité de base)
                _buildMenuItem(
                  icon: pageActive == "profilpharmacie"
                      ? Icons.local_hospital
                      : Icons.local_hospital_outlined,
                  titre: "Profil pharmacie",
                  isActive: pageActive == "profilpharmacie",
                  onTap: () => _verifierEtNaviguer("profilpharmacie", null),
                ),

                // ✅ Newsletters - VÉRIFICATION REQUISE
                _buildMenuItem(
                  icon: pageActive == "newsletter" ? Icons.newspaper : Icons.newspaper_outlined,
                  titre: "Newletter",
                  isActive: pageActive == "newsletter",
                  onTap: () => _verifierEtNaviguer(
                    "newsletter",
                    CodesFonctionnalites.NEWSLETTER, // ✅ Vérification
                  ),
                  badge: _getBadgeLimite(CodesFonctionnalites.NEWSLETTER),
                ),

                // ✅ Annonces - VÉRIFICATION REQUISE
                _buildMenuItem(
                  icon: pageActive == "annonces" ? Icons.campaign : Icons.campaign_outlined,
                  titre: "Annonces",
                  isActive: pageActive == "annonces",
                  onTap: () => _verifierEtNaviguer(
                    "annonces",
                    CodesFonctionnalites.ANNONCES, // ✅ Vérification
                  ),
                  badge: _getBadgeLimite(CodesFonctionnalites.ANNONCES),
                ),

                // ✅ Abonnements - Pas de vérification
                _buildMenuItem(
                  icon: pageActive == "abonnements"
                      ? Icons.workspace_premium
                      : Icons.workspace_premium_outlined,
                  titre: "Abonnement",
                  isActive: pageActive == "abonnements",
                  onTap: () => _verifierEtNaviguer("abonnements", null),
                ),

                Divider(indent: 15, endIndent: 15, height: 32.h),

                // Déconnexion
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    "Déconnexion",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Confirmation'),
                        content: Text('Voulez-vous vraiment vous déconnecter ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Annuler'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => Connexion()),
                                    (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text('Déconnexion'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Badge pour afficher les limites d'utilisation
  Widget? _getBadgeLimite(String codeFonctionnalite) {
    final acces = _abonnementVM.accesFonctionnalites[codeFonctionnalite];

    if (acces != null && acces.limite != null && acces.restant != null) {
      if (acces.restant! <= 2) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: acces.restant == 0 ? Colors.red : Colors.orange,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            '${acces.restant}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
    }

    return null;
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String titre,
    required bool isActive,
    required VoidCallback onTap,
    Widget? badge,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isActive ? Colors.deepOrangeAccent.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.deepOrangeAccent : Colors.grey[700],
        ),
        title: Text(
          titre,
          style: TextStyle(
            color: isActive ? Colors.deepOrangeAccent : Colors.black87,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: badge, // ✅ Badge de limite
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  Widget _chargerPages() {
    switch (pageActive) {
      case "accueil":
        return Accueilpharmacie();
      case "profilpharmacie":
        return Profilpharmacie();
      case "newsletter":
        return Newsletter();
      case "annonces":
        return Annonces();
      case "abonnements":
        return Abonnementpharmacie();
      default:
        return Accueilpharmacie();
    }
  }
}