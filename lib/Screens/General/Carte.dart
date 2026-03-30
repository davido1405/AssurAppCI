import 'dart:async';
import 'package:assurappci/Constants/Couleurs.dart';
import 'package:assurappci/Models/Pharmacie.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:assurappci/ViewModels/PharmacieViewModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:provider/provider.dart';

class Carte extends StatefulWidget {
  final Pharmacie? pharmacie;

  const Carte({super.key, this.pharmacie});

  @override
  State<Carte> createState() => _CarteState();
}

class _CarteState extends State<Carte> {
  //Pour interagir avec la carte: Zoom, Centrage etc
  mb.MapboxMap? mapboxMapController;

  mb.PointAnnotationManager? annotationManager;
  StreamSubscription<geo.Position>? userPositionStream;
  geo.Position? currentPosition;
  bool isLoading = true;
  String? errorMessage;
  bool useMockLocation = true;
  Pharmacie? selectedPharmacie;

  bool afficherToutepharmacie = true;

  List<Pharmacie> listePharmacie = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    Future.microtask(() async {
      await afficherTous();
      if (currentPosition != null) {
        addMarker(
          latitude: currentPosition!.latitude,
          longitude: currentPosition!.longitude,
          title: "Moi",
        );
      }
    });
    selectedPharmacie=widget.pharmacie;

  }

  @override
  void dispose() {
    userPositionStream?.cancel();
    super.dispose();
  }

  Future<void> afficherTous() async {
    if (mounted && widget.pharmacie != null) {
      setState(() {
        afficherToutepharmacie = false;
      });
      await recupererPharmacie();
    }
  }

  Future<void> recupererPharmacie() async {
    final pharmacieViewModel = context.read<PharmacieViewModel>();
    await pharmacieViewModel.init();

    if (pharmacieViewModel.errorMessage == null) {
      final ville =
          context.read<AuthViewModel>().session?.villeUtilisateur ?? '';
      print('🏙️ Ville: $ville');

      if (mounted) {
        setState(() {
          listePharmacie = pharmacieViewModel.pharmacies
              .where((p) => p.villePharmacie!.contains(ville))
              .toList();
        });
      }
    } else {
      print('❌ Erreur: ${pharmacieViewModel.errorMessage}');
    }
  }

  // ✅ Initialiser le gestionnaire d'annotations
  Future<void> _initAnnotationManager() async {
    if (mapboxMapController != null && annotationManager == null) {
      annotationManager = await mapboxMapController!.annotations
          .createPointAnnotationManager();
      print('✅ Annotation Manager initialisé');
    }
  }

  //Pour ajouter un marqueur personnalisé sur la carte
  Future<Uint8List> loadMarkerImage(String nom_marqueur) async {
    var byteData = await rootBundle.load("assets/images/$nom_marqueur.png");
    return byteData.buffer.asUint8List();
  }

  // ✅ Ajouter un marqueur
  Future<void> addMarker({required double latitude, required double longitude, String? title, Color? color,}) async {
    if (annotationManager == null) {
      print('⚠️ Annotation Manager non initialisé');
      await _initAnnotationManager();
    }

    if (annotationManager == null) {
      print('❌ Impossible de créer le marqueur');
      return;
    }

    var markerImage = await loadMarkerImage("Logo pour icone");
    var markerMoi = await loadMarkerImage("moi2");

    final pointAnnotation = mb.PointAnnotationOptions(
      geometry: mb.Point(coordinates: mb.Position(longitude, latitude)),
      textField: title ?? 'Moi',
      textSize: 15.0,
      textMaxWidth: 12,
      textColor: Colors.black.value,
      iconSize: title == "Moi" ? 0.04 : 0.2,
      image: title == "Moi" ? markerMoi : markerImage,
    );

    await annotationManager!.create(pointAnnotation);
  }

  // ✅ Ajouter marqueurs de la liste de pharmacies
  Future<void> _addPharmacyMarkersFromList() async {
    if (listePharmacie.isEmpty) {
      print('⚠️ Aucune pharmacie à afficher');
      return;
    }

    for (var pharmacy in listePharmacie) {
      if (pharmacy.latitude != null && pharmacy.longitude != null) {
        await addMarker(
          latitude: pharmacy.latitude!,
          longitude: pharmacy.longitude!,
          title: pharmacy.nomPharmacie,
          color: pharmacy.estDeGarde == true ? Colors.green : Colors.blue,
        );
      }
    }

    print('✅ ${listePharmacie.length} marqueurs pharmacies ajoutés');
  }

  // ✅ Initialiser la localisation
  Future<void> _initializeLocation() async {
    try {
      geo.Position position;

      if (useMockLocation) {
        position = geo.Position(
          latitude: 5.315426,
          longitude: -4.229491,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        print('🧪 Position MOCKÉE activée (Abidjan)');
      } else {
        position = await _getPosition();
        print('📍 Position RÉELLE GPS');
      }

      print('═══════════════════════════════');
      print('📍 POSITION FINALE:');
      print('Latitude: ${position.latitude}');
      print('Longitude: ${position.longitude}');
      print('═══════════════════════════════');

      if (mounted) {
        setState(() {
          currentPosition = position;
          isLoading = false;
        });

        // Centrer seulement si la carte est créée
        if (mapboxMapController != null) {
          _centerMapOnUser();
        }

        if (!useMockLocation) {
          _listenToPositionChanges();
        }
      }
    } catch (e) {
      print('❌ Erreur initialisation: $e');
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  // ✅ Centrer la carte sur l'utilisateur
  void _centerMapOnUser() {
    if (mapboxMapController != null) {
      if (widget.pharmacie != null) {
        print('🎯 Centrage sur la pharmacie en paramètre d\'abord');

        final coords = mb.Position(
          widget.pharmacie!.longitude as num,
          widget.pharmacie!.latitude as num,
        );

        mapboxMapController?.setCamera(
          mb.CameraOptions(center: mb.Point(coordinates: coords), zoom: 13.0),
        );
      } else if (currentPosition != null) {
        final coords = mb.Position(
          currentPosition!.longitude,
          currentPosition!.latitude,
        );

        mapboxMapController?.setCamera(
          mb.CameraOptions(center: mb.Point(coordinates: coords), zoom: 13.0),
        );
      } else {
        print('⚠️ Impossible de centrer: position ou carte non disponible');
      }
    } else {
      print('⚠️ Impossible de charger la carte');
    }
  }

  // ✅ Récupérer position
  Future<geo.Position> _getPosition() async {
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Veuillez activer la localisation');
    }

    geo.LocationPermission permission = await geo.Geolocator.checkPermission();

    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();

      if (permission == geo.LocationPermission.denied) {
        throw Exception('Localisation non autorisée');
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      throw Exception('Localisation refusée définitivement');
    }

    return await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );
  }

  // ✅ Écouter position
  void _listenToPositionChanges() {
    const locationSettings = geo.LocationSettings(
      accuracy: geo.LocationAccuracy.high,
      distanceFilter: 10,
    );

    userPositionStream =
        geo.Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((geo.Position position) {
          if (mounted) {
            setState(() {
              currentPosition = position;
            });
          }
        });
  }

  void _onTap(mb.MapContentGestureContext context) {
    if (listePharmacie.isNotEmpty) {
      if (mounted) {
        Pharmacie temp = listePharmacie.firstWhere(
          (p) =>
              p.latitude == context.point.coordinates.lat &&
              p.longitude == context.point.coordinates.lng,
        );

        setState(() {
          selectedPharmacie= temp;
        });
      }
    }
    print(
      "OnTap coordinate: {${context.point.coordinates.lng}, ${context.point.coordinates.lat}}" +
          " point: {x: ${context.touchPosition.x}, y: ${context.touchPosition.y}}",
    );
  }

  // ✅ Callback création de la carte (ORDRE IMPORTANT)
  void _onMapCreated(mb.MapboxMap controller) async {
    print('🗺️ Carte créée');

    setState(() {
      mapboxMapController = controller;
    });

    mapboxMapController?.gestures.updateSettings(mb.GesturesSettings());
    // 1. Activer le composant de localisation
    mapboxMapController?.location.updateSettings(
      mb.LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );

    print('✅ Composant localisation activé');

    // 2. Initialiser le gestionnaire d'annotations
    await _initAnnotationManager();

    // 3. Ajouter le marqueur de la pharmacie passée en paramètre
    if (!afficherToutepharmacie && widget.pharmacie != null) {
      if (widget.pharmacie!.latitude != null &&
          widget.pharmacie!.longitude != null) {
        await addMarker(
          latitude: widget.pharmacie!.latitude!,
          longitude: widget.pharmacie!.longitude!,
          title: widget.pharmacie!.nomPharmacie,
          color: widget.pharmacie!.estDeGarde == true
              ? Colors.green
              : Colors.blue,
        );
      }
    }

    // 4. Centrer sur l'utilisateur si position déjà disponible
    if (currentPosition != null) {
      _centerMapOnUser();
      addMarker(
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude,
        title: "Moi",
      );
    }

    // 5. Optionnel: Récupérer et afficher toutes les pharmacies
    // await recupererPharmacie();
    if (afficherToutepharmacie) {
      await recupererPharmacie();
      if (listePharmacie.isNotEmpty) {
        for (final pharmacie in listePharmacie) {
          addMarker(
            title: pharmacie.nomPharmacie,
            latitude: pharmacie.longitude!,
            longitude: pharmacie.latitude!,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.lightGreen,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Couleurs.darkGreen,
        title: widget.pharmacie != null
            ? Text(
                "${widget.pharmacie!.nomPharmacie} sur la carte",
                style: TextStyle(color: Colors.white),
              )
            : Text("Vue sur la carte", style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Carte
            mb.MapWidget(onMapCreated: _onMapCreated, onTapListener: _onTap),

            // Loading indicator
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),

            // Erreur
            if (errorMessage != null)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_off, color: Colors.white, size: 60),
                        SizedBox(height: 16),
                        Text(
                          'Erreur de localisation',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              errorMessage = null;
                              isLoading = true;
                            });
                            _initializeLocation();
                          },
                          child: Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            _buildBottomPanel(),
            // Bouton recentrer
            if (!isLoading && errorMessage == null)
              Positioned(
                right: 16,
                top: 200,
                child: FloatingActionButton(
                  onPressed: _centerMapOnUser,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.my_location, color: Colors.blue),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return DraggableScrollableSheet(
      initialChildSize: 0.25, // hauteur initiale
      minChildSize: 0.10,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: ListView(
            controller: scrollController,
            children: [
              SizedBox(height: 10),

              // 🔘 petite barre (drag indicator)
              Center(
                child: Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              SizedBox(height: 15),

              /**
                  // 🔍 Search bar
                  Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                  decoration: InputDecoration(
                  hintText: "Rechercher...",
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                  ),
                  ),
                  ),
                  ),
               **/
              SizedBox(height: 20),

              //Afficher les différentes options ici
              widget.pharmacie == null
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 100.h,
                        horizontal: 25.w,
                      ),
                      child: emptyStatePharma(),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 5.h,
                        horizontal: 15.w,
                      ),
                      child: detailsMarqueur(),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget emptyStatePharma() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100]),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.r),
                color: Couleurs.darkGreen,
              ),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Icon(
                  CupertinoIcons.info_circle_fill,
                  color: Couleurs.lightGreen,
                  size: 30.r,
                ),
              ),
            ),
            SizedBox(height: 5.h),
            Text("Oups !"),
            Text("Aucun détails disponible. Veuillez toucher un marqueur"),
          ],
        ),
      ),
    );
  }

  Widget detailsMarqueur() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedPharmacie?.distance != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 30.w,
                      vertical: 5.h,
                    ),
                    child: Text(
                      'A ${double.tryParse(selectedPharmacie!.distance.toString())?.toStringAsFixed(2)} mètre de vous',
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  selectedPharmacie!.nomPharmacie,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30.sp,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              decoration: BoxDecoration(
                color: selectedPharmacie!.estDeGarde == 0
                    ? Colors.red
                    : Colors.green,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.w,
                    vertical: 5.h,
                  ),
                  child: Text(
                    selectedPharmacie!.estDeGarde == 0
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
        Row(
          children: [
            Icon(CupertinoIcons.location_solid, color: Couleurs.darkGreen),
            Text(
              selectedPharmacie?.adresseFournit ?? 'Aucune adresse fournit',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            color: Colors.grey[100],
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 5,
                blurStyle: BlurStyle.inner,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(
                  Icons.access_time_filled_sharp,
                  size: 30.r,
                  color: Couleurs.darkGreen,
                ),
                title: Text(
                  "Horaires d'ouverture",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
              ),
              horaires(
                "Lundi-Vendredi",
                selectedPharmacie?.horaires_en_semaine ?? '08:30 - 21:30',
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[300],
                indent: 20,
                endIndent: 20,
              ),
              horaires(
                "Samedi",
                selectedPharmacie?.horaires_samedi ?? '08:30 - 15:30',
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[300],
                indent: 20,
                endIndent: 20,
              ),
              horaires(
                "Dimanche",
                selectedPharmacie?.horaires_dimanche ?? 'Fermée',
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey[300],
          indent: 20,
          endIndent: 20,
        ),
        Padding(
          padding: EdgeInsets.all(5.w),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    print("Tracer itinéraire");
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Couleurs.mapBlue,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.arrow_branch,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              "Tracer un itinéraire",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget horaires(String jour, String heures) {
    return ListTile(
      leading: Text(jour, style: TextStyle(fontSize: 16.sp)),
      trailing: Text(
        heures ?? "Fermée",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
          color: (heures == "Fermé" || heures == "Fermée")
              ? Colors.red
              : Colors.black,
        ),
      ),
    );
  }
}
