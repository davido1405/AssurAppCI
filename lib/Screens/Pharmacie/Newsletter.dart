// Screens/Pharmacie/Newsletter.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Newsletter extends StatefulWidget {
  const Newsletter({super.key});

  @override
  State<Newsletter> createState() => _NewsletterState();
}

class _NewsletterState extends State<Newsletter> {
  // Liste des newsletters envoyées
  List<Map<String, dynamic>> newsletters = [
    {
      'id': 1,
      'titre': 'Nouveautés du mois',
      'date': '2024-03-10',
      'destinataires': 245,
      'ouverts': 189,
    },
    {
      'id': 2,
      'titre': 'Conseils santé',
      'date': '2024-03-05',
      'destinataires': 230,
      'ouverts': 175,
    },
  ];

  int _nombreAbonnes = 250;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerNewsletters();
  }

  Future<void> _chargerNewsletters() async {
    setState(() => _isLoading = true);

    // TODO: Appeler l'API
    await Future.delayed(Duration(seconds: 1));

    setState(() => _isLoading = false);
  }

  Future<void> envoyerNouvelleNewsletter() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreerNewsletterScreen(nombreAbonnes: _nombreAbonnes),
      ),
    );

    if (result == true) {
      _chargerNewsletters();
    }
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
                    "Newsletters",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "$_nombreAbonnes abonné(s)",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: envoyerNouvelleNewsletter,
                icon: Icon(Icons.send, size: 20.sp),
                label: Text('Envoyer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // ===== STATISTIQUES =====
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[400]!, Colors.purple[600]!],
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Envoyées', newsletters.length.toString(), Icons.mail_outline),
                Container(width: 1, height: 40.h, color: Colors.white30),
                _buildStat('Taux ouverture', '${_calculerTauxOuverture()}%', Icons.visibility),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // ===== LISTE DES NEWSLETTERS =====
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : newsletters.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _chargerNewsletters,
              child: ListView.builder(
                itemCount: newsletters.length,
                itemBuilder: (context, index) {
                  return _carteNewsletter(newsletters[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  int _calculerTauxOuverture() {
    if (newsletters.isEmpty) return 0;

    int totalEnvoyes = newsletters.fold(0, (sum, item) => sum + (item['destinataires'] as int));
    int totalOuverts = newsletters.fold(0, (sum, item) => sum + (item['ouverts'] as int));

    return totalEnvoyes > 0 ? ((totalOuverts / totalEnvoyes) * 100).round() : 0;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mail_outline, size: 80.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'Aucune newsletter',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Envoyez votre première newsletter',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: envoyerNouvelleNewsletter,
            icon: Icon(Icons.send),
            label: Text('Envoyer une newsletter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
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

  Widget _carteNewsletter(Map<String, dynamic> newsletter) {
    final tauxOuverture = ((newsletter['ouverts'] / newsletter['destinataires']) * 100).round();

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
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    newsletter['titre'],
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Envoyée',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey[600]),
                SizedBox(width: 6.w),
                Text(
                  newsletter['date'],
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(height: 1, color: Colors.grey[200]),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNewsletterStat(
                  Icons.people_outline,
                  'Destinataires',
                  newsletter['destinataires'].toString(),
                ),
                _buildNewsletterStat(
                  Icons.visibility,
                  'Ouverts',
                  newsletter['ouverts'].toString(),
                ),
                _buildNewsletterStat(
                  Icons.analytics_outlined,
                  'Taux',
                  '$tauxOuverture%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsletterStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20.sp, color: Colors.purple),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// ===== ÉCRAN CRÉATION NEWSLETTER =====
class CreerNewsletterScreen extends StatefulWidget {
  final int nombreAbonnes;

  const CreerNewsletterScreen({
    super.key,
    required this.nombreAbonnes,
  });

  @override
  State<CreerNewsletterScreen> createState() => _CreerNewsletterScreenState();
}

class _CreerNewsletterScreenState extends State<CreerNewsletterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _contenuController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titreController.dispose();
    _contenuController.dispose();
    super.dispose();
  }

  Future<void> envoyerNewsletter() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // TODO: Appeler l'API
      await Future.delayed(Duration(seconds: 2));

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Newsletter envoyée à ${widget.nombreAbonnes} abonné(s)'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouvelle Newsletter'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info destinataires
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.purple),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Cette newsletter sera envoyée à ${widget.nombreAbonnes} abonné(s)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.purple[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Titre
              Text('Titre', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _titreController,
                decoration: InputDecoration(
                  hintText: 'Ex: Nouveautés du mois',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer un titre' : null,
              ),

              SizedBox(height: 20.h),

              // Contenu
              Text('Contenu', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _contenuController,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: 'Écrivez votre message...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer un contenu' : null,
              ),

              SizedBox(height: 30.h),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text('Annuler'),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : envoyerNewsletter,
                      icon: _isLoading
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Icon(Icons.send),
                      label: Text(_isLoading ? 'Envoi...' : 'Envoyer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
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