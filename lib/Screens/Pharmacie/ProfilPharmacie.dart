import 'dart:io' show File;
import 'package:assurappci/Models/Assurances.dart';
import 'package:assurappci/Models/Pharmacie.dart';
import 'package:assurappci/ViewModels/AbonnementPharmacieViewModel.dart';
import 'package:assurappci/ViewModels/AssuranceViewModel.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:assurappci/ViewModels/PharmacieViewModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Profilpharmacie extends StatefulWidget {
  const Profilpharmacie({super.key});

  @override
  State<Profilpharmacie> createState() => _ProfilpharmacieState();
}

class _ProfilpharmacieState extends State<Profilpharmacie> {
  Pharmacie? profilPharma;
  TimeOfDay heureOuverture = TimeOfDay.now();
  TimeOfDay heureFermeture = TimeOfDay.now();


  List<Assurances> assurancesSysteme = [];
  final ImagePicker _imagePicker = ImagePicker();

  // ✅ État pour la photo
  File? _photoSelectionnee;
  bool _uploadingPhoto = false;

  // Controllers pour les champs
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _villeController=TextEditingController();

  // Map pour stocker l'état de chaque checkbox
  Map<int, bool> assurancesSelectionnees = {};
  List<int> assurancesAcceptees = [];

  late String horraires='${heureOuverture}-${heureFermeture}';

  @override
  void initState() {
    super.initState();
    Future.microtask(recupererProfilPharm);
    Future.microtask(recupererAssurance);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _villeController.dispose();
    super.dispose();
  }

  //Mettre à jour le statut de garde
  Future<void>statutGarde()async{

  }

  Future<Pharmacie?> recupererProfilPharm() async {
    final codeUtilisateur = context.read<AuthViewModel>().session?.codeUtilisateur;

    if (codeUtilisateur == null) return null;

    final profil = context.read<PharmacieViewModel>();
    await profil.recupererProfilPharmacie(codeUtilisateur);

    if (profil.errorMessage == null) {
      if (mounted) {
        setState(() {
          profilPharma = profil.pharmacie;

          // ✅ Initialiser les controllers avec les données
          if (profilPharma != null) {
            _nomController.text = profilPharma!.nomPharmacie;
            _villeController.text=profilPharma!.villePharmacie ?? '';
            _adresseController.text = profilPharma!.adresseFournit ?? '';
            _telephoneController.text = profilPharma!.numeroPharmacie;
            _emailController.text = profilPharma!.emailPharmacie ?? '';

            // Récupérer les assurances déjà acceptées
            if (profilPharma!.assuranceAcceptees != null) {
              assurancesAcceptees = _parseAssurancesAcceptees(
                  profilPharma!.assuranceAcceptees as String
              );
            }
          }
        });
      }
    }
    return profilPharma;
  }

  // ✅ Parse les assurances acceptées (format: "NSIA, AXA, SUNU")
  List<int> _parseAssurancesAcceptees(String? assurances) {
    // ✅ Ajout du ?
    // ✅ Vérification null-safe
    if (assurances == null || assurances.isEmpty) {
      print('⚠️ Aucune assurance à parser');
      return [];
    }

    print('=== PARSING ASSURANCES ===');
    print('Input: $assurances');
    print('Type: ${assurances.runtimeType}');

    List<int> ids = [];

    // ✅ Split par virgule
    List<String> noms = assurances.split(', ');
    print('Noms split: $noms');

    for (String nom in noms) {
      String nomTrimmed = nom.trim();  // ✅ Enlever les espaces
      print('Recherche assurance: "$nomTrimmed"');

      final assurance = assurancesSysteme.firstWhere(
            (a) => a.nomAssurance.toLowerCase() == nomTrimmed.toLowerCase(),
        orElse: () => Assurances(
          idAssurance: 0,
          nomAssurance: '',
          statutAssurance: 0,
        ),
      );

      if (assurance.idAssurance != 0) {
        ids.add(assurance.idAssurance);
        print('✅ Assurance trouvée: ${assurance.nomAssurance} (ID: ${assurance.idAssurance})');
      } else {
        print('⚠️ Assurance non trouvée: "$nomTrimmed"');
      }
    }

    print('IDs finaux: $ids');
    return ids;
  }

  Future<void> recupererAssurance() async {
    final assu = context.read<AssuranceViewModel>();
    await assu.init();

    if (assu.errorMessage == null) {
      if (mounted) {
        setState(() {
          assurancesSysteme = assu.assurances;

          // ✅ Initialiser l'état des checkboxes
          for (var assurance in assurancesSysteme) {
            assurancesSelectionnees[assurance.idAssurance] =
                assurancesAcceptees.contains(assurance.idAssurance);
          }
        });
      }
    }
  }

  // ✅ Sélectionner depuis la galerie
  Future<File?> selectionnerDepuisGalerie() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print("Erreur sélection image: $e");
      return null;
    }
  }

  // ✅ Prendre une photo
  Future<File?> prendrePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print("Erreur prise photo: $e");
      return null;
    }
  }

  // ✅ Afficher dialogue de sélection (galerie ou caméra)
  Future<void> choisirSourcePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.blue),
              title: Text('Galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.photo_camera, color: Colors.green),
              title: Text('Appareil photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.red),
              title: Text('Annuler'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      File? image;
      if (source == ImageSource.gallery) {
        image = await selectionnerDepuisGalerie();
      } else {
        image = await prendrePhoto();
      }

      if (image != null) {
        setState(() {
          _photoSelectionnee = image;
        });
      }
    }
  }

  // ✅ Upload de la photo seule
  Future<void> uploadPhotoSeule() async {
    if (_photoSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez d\'abord sélectionner une photo')),
      );
      return;
    }

    if (profilPharma == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil pharmacie non chargé')),
      );
      return;
    }

    setState(() {
      _uploadingPhoto = true;
    });

    try {
      final pharmacieVM = context.read<PharmacieViewModel>();

      // ✅ Appeler la méthode d'upload dans le ViewModel
      await pharmacieVM.uploadPhotoPharmacier(
        profilPharma!.codePharmacie,
        _photoSelectionnee!,
      );

      if (pharmacieVM.errorMessage == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo mise à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );

          // Recharger le profil
          await recupererProfilPharm();

          setState(() {
            _photoSelectionnee = null; // Reset
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(pharmacieVM.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _uploadingPhoto = false;
        });
      }
    }
  }

  // Screens/Pharmacie/ProfilPharmacie.dart

  // Screens/Pharmacie/ProfilPharmacie.dart

  Future<void> enregistrerModifications() async {
    if (profilPharma == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil pharmacie non chargé')),
      );
      return;
    }

    // Validation
    if (_nomController.text.isEmpty ||
        _adresseController.text.isEmpty ||
        _telephoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs requis')),
      );
      return;
    }

    // Afficher un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    // ✅ Garder une référence au contexte du dialogue
    BuildContext? dialogContext;

    try {
      print('=== PRÉPARATION MODIFICATIONS ===');

      // ✅ CORRECTION: Convertir les IDs en noms d'assurances
      List<String> nomsAssurances = [];

      if (assurancesAcceptees.isNotEmpty) {
        print('IDs sélectionnés: $assurancesAcceptees');

        // Convertir chaque ID en nom
        for (var id in assurancesAcceptees) {
          print('Recherche assurance avec ID: $id');

          try {
            // ✅ Utiliser firstWhere avec gestion d'erreur
            final assurance = assurancesSysteme.firstWhere(
                  (a) => a.idAssurance == id,
              orElse: () => Assurances(
                idAssurance: 0,
                nomAssurance: '',
                statutAssurance: 0,
              ),
            );

            if (assurance.idAssurance != 0) {
              nomsAssurances.add(assurance.nomAssurance);
              print('✅ Trouvé: ${assurance.nomAssurance}');
            } else {
              print('⚠️ Assurance ID $id non trouvée');
            }
          } catch (e) {
            print('❌ Erreur recherche assurance ID $id: $e');
          }
        }

        print('Noms finaux: $nomsAssurances');
      }

      final pharmacieVM = context.read<PharmacieViewModel>();

      // ✅ Créer le Map avec les noms d'assurances (pas les IDs)
      final modifications = {
        'nom_pharmacie': _nomController.text,
        'ville_pharmacie': _villeController.text.isEmpty ? 'Abidjan' : _villeController.text,
        'adresse_fournit': _adresseController.text,
        'numeros_pharmacie': _telephoneController.text,
        'email_pharmacie': _emailController.text,
        'horraires_ouverture':
        '${heureOuverture.hour.toString().padLeft(2,'0')}:${heureOuverture.minute.toString().padLeft(2,'0')} - '
            '${heureFermeture.hour.toString().padLeft(2,'0')}:${heureFermeture.minute.toString().padLeft(2,'0')}',
        'assurances': nomsAssurances,  // ✅ Liste de String, pas List<int>
      };

      print('=== MODIFICATIONS FINALES ===');
      print(modifications);

      // ✅ Afficher le loader et garder son contexte
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext ctx) {
            dialogContext = ctx; // ✅ Sauvegarder le contexte du dialogue
            return WillPopScope(
              onWillPop: () async => false,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        );
      }

      // ✅ Appeler le ViewModel
      await pharmacieVM.mettreAJourPharmacie(
        profilPharma!.codePharmacie,
        modifications,
        _photoSelectionnee,
      );
      // ✅ Fermer le loader avec le bon contexte
      if (dialogContext != null && mounted) {
        Navigator.of(dialogContext!).pop();
      }

      if (mounted) {
        Navigator.pop(context); // Fermer le loader

        if (pharmacieVM.errorMessage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Modifications enregistrées avec succès'),
              backgroundColor: Colors.green,
            ),
          );

          // Recharger le profil
          await recupererProfilPharm();

          setState(() {
            _photoSelectionnee = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${pharmacieVM.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ Exception enregistrerModifications: $e');
      print('StackTrace: $stackTrace');

      // ✅ Fermer le loader si encore ouvert
      if (dialogContext != null && mounted) {
        try {
          Navigator.of(dialogContext!).pop();
        } catch (e) {
          print('⚠️ Dialogue déjà fermé');
        }
      }

      if (mounted) {
        Navigator.pop(context); // Fermer le loader

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
  // ✅ Enregistrer le profil de la pharmacie (AJOUT)
  Future<void> ajouterPharmacie() async {
    // Validation
    if (_nomController.text.isEmpty ||
        _adresseController.text.isEmpty ||
        _telephoneController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs requis')),
      );
      return;
    }

    // Vérifier qu'une photo est sélectionnée
    if (_photoSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner une photo')),
      );
      return;
    }

    // Vérifier qu'au moins une assurance est sélectionnée
    if (assurancesAcceptees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner au moins une assurance')),
      );
      return;
    }

    // Afficher un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final pharmacieVM = context.read<PharmacieViewModel>();
      final gerant = context.read<AuthViewModel>().session?.codeUtilisateur;

      if (gerant == null || gerant.isEmpty) {
        throw Exception('Code gérant manquant');
      }

      // ✅ Récupérer les NOMS des assurances sélectionnées
      List<String> nomsAssurances = assurancesSysteme
          .where((a) => assurancesAcceptees.contains(a.idAssurance))
          .map((a) => a.nomAssurance)
          .toList();

      print('Noms assurances à envoyer: $nomsAssurances');

      // ✅ Appeler le ViewModel avec les bons paramètres
      await pharmacieVM.ajouterPharmacie(
        _photoSelectionnee!,  // ✅ File (pas .path)
        gerant,
        _nomController.text,
        _telephoneController.text,
        _emailController.text,
        null, // latitude (optionnel pour l'instant)
        null, // longitude (optionnel pour l'instant)
        _villeController.text.isEmpty ? '' : _villeController.text,  // ✅ Ville
        _adresseController.text,
        "${heureOuverture.hour.toString().padLeft(2, '0')}:${heureOuverture.minute.toString().padLeft(2, '0')} - ${heureFermeture.hour.toString().padLeft(2, '0')}:${heureFermeture.minute.toString().padLeft(2, '0')}",
        nomsAssurances,  // ✅ Liste de String
      );

      if (mounted) {
        Navigator.pop(context); // Fermer le loader

        if (pharmacieVM.errorMessage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pharmacie enregistrée avec succès'),
              backgroundColor: Colors.green,
            ),
          );

          // Recharger le profil
          await recupererProfilPharm();

          setState(() {
            _photoSelectionnee = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(pharmacieVM.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Erreur ajouterPharmacie: $e');

      if (mounted) {
        Navigator.pop(context); // Fermer le loader

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget listeChoixAssurance(Assurances assurance) {
    final bool estCochee = assurancesSelectionnees[assurance.idAssurance] ?? false;

    return CheckboxListTile(
      value: estCochee,
      onChanged: (bool? newValue) {
        if (newValue != null && mounted) {
          setState(() {
            assurancesSelectionnees[assurance.idAssurance] = newValue;

            if (newValue) {
              if (!assurancesAcceptees.contains(assurance.idAssurance)) {
                assurancesAcceptees.add(assurance.idAssurance);
              }
            } else {
              assurancesAcceptees.remove(assurance.idAssurance);
            }
          });
        }
      },
      title: Text(assurance.nomAssurance),
      checkColor: Colors.white,
      activeColor: Colors.green,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // ===== SECTION PHOTO =====
            Container(
              height: 350.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Photo de la pharmacie",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // ✅ Affichage de la photo
                    Center(
                      child: GestureDetector(
                        onTap: choisirSourcePhoto,
                        child: Container(
                          width: 200.w,
                          height: 200.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: _photoSelectionnee != null
                                ? Image.file(
                              _photoSelectionnee!,
                              fit: BoxFit.cover,
                            )
                                : profilPharma?.photoPharmacie != null
                                ? Image.network(
                              profilPharma!.photoPharmacie!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) {
                                return _buildPlaceholderPhoto();
                              },
                            )
                                : _buildPlaceholderPhoto(),
                          ),
                        ),
                      ),
                    ),

                    // ✅ Boutons de gestion photo
                    Center(
                      child: Wrap(
                        spacing: 8,
                        children: [
                          TextButton.icon(
                            onPressed: _uploadingPhoto ? null : choisirSourcePhoto,
                            label: Text(
                              "Choisir une photo",
                              style: TextStyle(color: Colors.white),
                            ),
                            icon: Icon(Icons.photo_camera_outlined, color: Colors.white),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.deepOrangeAccent,
                            ),
                          ),

                          if (_photoSelectionnee != null)
                            TextButton.icon(
                              onPressed:(){} ,//_uploadingPhoto ? null : uploadPhotoSeule,
                              label: Text(
                                _uploadingPhoto ? "Upload..." : "Upload",
                                style: TextStyle(color: Colors.white),
                              ),
                              icon: _uploadingPhoto
                                  ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                                  : Icon(Icons.cloud_upload, color: Colors.white),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 25.h),

            // ===== SECTION INFORMATIONS DE BASE =====
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Informations de base",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 25.h),

                    // Nom
                    Text("Nom de la pharmacie"),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _nomController,
                      decoration: InputDecoration(
                        hintText: "Nom pharmacie",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                    ),SizedBox(height: 16.h),

                    // Email
                    Text("Ville"),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _villeController,
                      decoration: InputDecoration(
                        hintText: "Ville pharmacie",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Adresse
                    Text("Adresse"),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _adresseController,
                      decoration: InputDecoration(
                        hintText: "Adresse pharmacie",
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Téléphone
                    Text("Téléphone"),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _telephoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Contact pharmacie",
                        prefixIcon: Icon(CupertinoIcons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Email
                    Text("Email"),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "E-mail pharmacie",
                        prefixIcon: Icon(CupertinoIcons.mail),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 25.h),

            // ===== SECTION HORAIRES =====
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Horaires pharmacie",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 25.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Heure d'ouverture
                        Column(
                          children: [
                            Text("Heure d'ouverture"),
                            SizedBox(height: 10.h),
                            InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: heureOuverture,
                                );
                                if (time != null) {
                                  setState(() => heureOuverture = time);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  "${heureOuverture.hour.toString().padLeft(2, '0')}:${heureOuverture.minute.toString().padLeft(2, '0')}",
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Heure de fermeture
                        Column(
                          children: [
                            Text("Heure de fermeture"),
                            SizedBox(height: 10.h),
                            InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: heureFermeture,
                                );
                                if (time != null) {
                                  setState(() => heureFermeture = time);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  "${heureFermeture.hour.toString().padLeft(2, '0')}:${heureFermeture.minute.toString().padLeft(2, '0')}",
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 25.h),

            // ===== SECTION ASSURANCES =====
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Assurances acceptées",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "${assurancesAcceptees.length} assurance(s) sélectionnée(s)",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 15.h),

                    context.watch<Abonnementpharmacieviewmodel>().nomForfaitActuel!="Gratuit" && assurancesSysteme.isNotEmpty
                        ? Column(
                      children: assurancesSysteme.asMap().entries.map((entry) {
                        final index = entry.key;
                        final assurance = entry.value;
                        return Column(
                          children: [
                            listeChoixAssurance(assurance),
                            if (index < assurancesSysteme.length - 1)
                              Divider(color: Colors.grey[200], thickness: 1),
                          ],
                        );
                      }).toList(),
                    )
                        : Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.h),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // ===== BOUTONS D'ACTION =====
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      // TODO: Aperçu
                    },
                    label: Text(
                      "Aperçu",
                      style: TextStyle(color: Colors.white),
                    ),
                    icon: Icon(Icons.remove_red_eye, color: Colors.white),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: profilPharma!=null?() async{
                      enregistrerModifications();
                    }:ajouterPharmacie,
                    label: Text(
                      profilPharma!=null?"Enregistrer les modifications":"Enregistrer ma pharmacie",
                      style: TextStyle(color: Colors.white),
                    ),
                    icon: Icon(Icons.save, color: Colors.white),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
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

  Widget _buildPlaceholderPhoto() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.photo_camera_outlined, size: 50.r, color: Colors.grey[400]),
        SizedBox(height: 8.h),
        Text(
          'Ajouter une photo',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}