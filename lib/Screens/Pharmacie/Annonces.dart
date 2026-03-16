// Screens/Pharmacie/Annonces.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Annonces extends StatefulWidget {
  const Annonces({super.key});

  @override
  State<Annonces> createState() => _AnnoncesState();
}

class _AnnoncesState extends State<Annonces> {
  // Liste des annonces (à remplacer par un appel API)
  List<Map<String, dynamic>> annonces = [
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

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerAnnonces();
  }

  Future<void> _chargerAnnonces() async {
    setState(() => _isLoading = true);

    // TODO: Appeler l'API
    await Future.delayed(Duration(seconds: 1));

    setState(() => _isLoading = false);
  }

  Future<void> creerNouvelleAnnonce() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreerAnnonceScreen(),
      ),
    );

    if (result == true) {
      _chargerAnnonces();
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
                annonces.removeWhere((a) => a['id'] == id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Annonce supprimée'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
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
                    "${annonces.length} annonce(s)",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: creerNouvelleAnnonce,
                icon: Icon(Icons.add, size: 20.sp),
                label: Text('Nouvelle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
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

          // ===== LISTE DES ANNONCES =====
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : annonces.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _chargerAnnonces,
              child: ListView.builder(
                itemCount: annonces.length,
                itemBuilder: (context, index) {
                  return _carteAnnonce(annonces[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'Aucune annonce',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Créez votre première annonce',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: creerNouvelleAnnonce,
            icon: Icon(Icons.add),
            label: Text('Créer une annonce'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteAnnonce(Map<String, dynamic> annonce) {
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
          // En-tête
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  onSelected: (value) {
                    if (value == 'modifier') {
                      modifierAnnonce(annonce['id']);
                    } else if (value == 'supprimer') {
                      supprimerAnnonce(annonce['id']);
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
                Text(
                  annonce['titre'],
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
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

          // Footer
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey[600]),
                    SizedBox(width: 6.w),
                    Text(
                      annonce['date'],
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.visibility, size: 14.sp, color: Colors.grey[600]),
                    SizedBox(width: 6.w),
                    Text(
                      '${annonce['vues']} vues',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
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
}

// ===== ÉCRAN CRÉATION =====
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

  final List<String> _types = ['Information', 'Promotion', 'Urgence'];

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> publierAnnonce() async {
    if (_formKey.currentState!.validate()) {
      // TODO: Appeler l'API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Annonce publiée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
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
              Text("Type d'annonce", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                children: _types.map((type) {
                  final estSelectionne = _typeSelectionne == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: estSelectionne,
                    onSelected: (selected) => setState(() => _typeSelectionne = type),
                    selectedColor: Colors.blue,
                    labelStyle: TextStyle(
                      color: estSelectionne ? Colors.white : Colors.black87,
                      fontWeight: estSelectionne ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24.h),
              Text('Titre', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _titreController,
                decoration: InputDecoration(
                  hintText: 'Ex: Promotion sur les vitamines',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer un titre' : null,
              ),
              SizedBox(height: 20.h),
              Text('Description', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Décrivez votre annonce...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer une description' : null,
              ),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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