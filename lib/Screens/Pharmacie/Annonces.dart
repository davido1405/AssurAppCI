import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Annonces extends StatefulWidget {
  const Annonces({super.key});

  @override
  State<Annonces> createState() => _AnnoncesState();
}

class _AnnoncesState extends State<Annonces> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Liste des annonces (à remplacer par un appel API)
  List<Map<String, dynamic>> annoncesActives = [
    {
      'id': 1,
      'titre': 'Promotion vitamines',
      'description': 'Réduction de 20% sur toutes les vitamines',
      'type': 'Promotion',
      'date': '2024-03-08',
      'vues': 156,
    },
    {
      'id': 2,
      'titre': 'Nouveau service',
      'description': 'Livraison à domicile maintenant disponible',
      'type': 'Information',
      'date': '2024-03-05',
      'vues': 89,
    },
  ];

  List<Map<String, dynamic>> annoncesBrouillons = [
    {
      'id': 3,
      'titre': 'Brouillon test',
      'description': 'Ceci est un brouillon',
      'type': 'Promotion',
      'date': '2024-03-09',
      'vues': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> creerNouvelleAnnonce() async {
    // Navigation vers l'écran de création d'annonce
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreerAnnonceScreen(),
      ),
    );

    if (result == true) {
      // Recharger les annonces
      setState(() {
        // TODO: Appeler l'API pour recharger
      });
    }
  }

  void modifierAnnonce(int id) {
    print('Modifier annonce: $id');
    // TODO: Navigation vers écran de modification
  }

  void supprimerAnnonce(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer cette annonce ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                annoncesActives.removeWhere((a) => a['id'] == id);
                annoncesBrouillons.removeWhere((a) => a['id'] == id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Annonce supprimée'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== EN-TÊTE =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mes Annonces",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "${annoncesActives.length + annoncesBrouillons.length} annonce(s) au total",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: creerNouvelleAnnonce,
                icon: Icon(Icons.add),
                label: Text('Nouvelle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // ===== ONGLETS =====
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12.r),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black87,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text('Actives'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.drafts_outlined, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text('Brouillons'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // ===== CONTENU DES ONGLETS =====
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Onglet Actives
                annoncesActives.isEmpty
                    ? _buildEmptyState('Aucune annonce active')
                    : ListView.builder(
                  itemCount: annoncesActives.length,
                  itemBuilder: (context, index) {
                    return carteAnnonce(
                      context: context,
                      annonce: annoncesActives[index],
                      onModifier: () => modifierAnnonce(annoncesActives[index]['id']),
                      onSupprimer: () => supprimerAnnonce(annoncesActives[index]['id']),
                    );
                  },
                ),

                // Onglet Brouillons
                annoncesBrouillons.isEmpty
                    ? _buildEmptyState('Aucun brouillon')
                    : ListView.builder(
                  itemCount: annoncesBrouillons.length,
                  itemBuilder: (context, index) {
                    return carteAnnonce(
                      context: context,
                      annonce: annoncesBrouillons[index],
                      onModifier: () => modifierAnnonce(annoncesBrouillons[index]['id']),
                      onSupprimer: () => supprimerAnnonce(annoncesBrouillons[index]['id']),
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

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// ===== WIDGET CARTE ANNONCE =====
Widget carteAnnonce({
  required BuildContext context,
  required Map<String, dynamic> annonce,
  required VoidCallback onModifier,
  required VoidCallback onSupprimer,
}) {
  // Déterminer la couleur selon le type
  Color getTypeColor(String type) {
    switch (type) {
      case 'Promotion':
        return Colors.orange;
      case 'Information':
        return Colors.blue;
      case 'Urgence':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  return Container(
    margin: EdgeInsets.only(bottom: 16.h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
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
        // En-tête avec badge type
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge type
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: getTypeColor(annonce['type']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.label,
                      size: 14.sp,
                      color: getTypeColor(annonce['type']),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      annonce['type'],
                      style: TextStyle(
                        color: getTypeColor(annonce['type']),
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // Menu actions
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                onSelected: (value) {
                  if (value == 'modifier') {
                    onModifier();
                  } else if (value == 'supprimer') {
                    onSupprimer();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'modifier',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18.sp, color: Colors.blue),
                        SizedBox(width: 8.w),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'supprimer',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18.sp, color: Colors.red),
                        SizedBox(width: 8.w),
                        Text('Supprimer'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Text(
                annonce['titre'],
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8.h),

              // Description
              Text(
                annonce['description'],
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        Divider(height: 1, color: Colors.grey[200]),

        // Footer avec stats
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    annonce['date'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              // Vues
              Row(
                children: [
                  Icon(
                    Icons.visibility,
                    size: 14.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '${annonce['vues']} vues',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
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

// ===== ÉCRAN DE CRÉATION D'ANNONCE =====
class CreerAnnonceScreen extends StatefulWidget {
  const CreerAnnonceScreen({super.key});

  @override
  State<CreerAnnonceScreen> createState() => _CreerAnnonceScreenState();
}

class _CreerAnnonceScreenState extends State<CreerAnnonceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _typeSelectionne = 'Information';

  final List<String> _types = ['Information', 'Promotion', 'Urgence', 'Événement'];

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> publierAnnonce() async {
    if (_formKey.currentState!.validate()) {
      // TODO: Appeler l'API pour créer l'annonce
      print('Titre: ${_titreController.text}');
      print('Description: ${_descriptionController.text}');
      print('Type: $_typeSelectionne');

      // Simuler un succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Annonce publiée avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Retourner true pour indiquer succès
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouvelle Annonce'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type d'annonce
              Text(
                "Type d'annonce",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _types.map((type) {
                  final estSelectionne = _typeSelectionne == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: estSelectionne,
                    onSelected: (selected) {
                      setState(() {
                        _typeSelectionne = type;
                      });
                    },
                    selectedColor: Colors.blue,
                    labelStyle: TextStyle(
                      color: estSelectionne ? Colors.white : Colors.black87,
                      fontWeight: estSelectionne ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 24.h),

              // Titre
              Text(
                'Titre',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _titreController,
                decoration: InputDecoration(
                  hintText: 'Ex: Promotion sur les vitamines',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20.h),

              // Description
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Décrivez votre annonce...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),

              SizedBox(height: 30.h),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text('Annuler'),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: publierAnnonce,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text('Publier'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}