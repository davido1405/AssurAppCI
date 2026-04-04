import 'dart:async';
import 'dart:convert';
import 'package:assurappci/Constants/Couleurs.dart';
import 'package:assurappci/Models/Pharmacie.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:assurappci/ViewModels/PharmacieViewModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────
// Listener clics marqueurs
// ─────────────────────────────────────────────────────────────
class _PharmacieAnnotationClickListener
    extends mb.OnPointAnnotationClickListener {
  final Function(mb.PointAnnotation) onAnnotationClick;

  _PharmacieAnnotationClickListener({required this.onAnnotationClick});

  @override
  void onPointAnnotationClick(mb.PointAnnotation annotation) {
    onAnnotationClick(annotation);
  }
}

// ─────────────────────────────────────────────────────────────
// Widget principal
// ─────────────────────────────────────────────────────────────
class Carte extends StatefulWidget {
  final Pharmacie? pharmacie;

  const Carte({super.key, this.pharmacie});

  @override
  State<Carte> createState() => _CarteState();
}

class _CarteState extends State<Carte> {
  // ── Carte ──────────────────────────────────────────────────
  mb.MapboxMap? mapboxMapController;
  mb.PointAnnotationManager? annotationManager;
  mb.PolylineAnnotationManager? polylineManager; // ✅ NOUVEAU

  // ── Position ───────────────────────────────────────────────
  StreamSubscription<geo.Position>? userPositionStream;
  geo.Position? currentPosition;
  bool useMockLocation = true;

  // ── État UI ────────────────────────────────────────────────
  bool isLoading = true;
  String? errorMessage;
  bool isLoadingItineraire = false; // ✅ spinner bouton
  String? itineraireErrorMessage; // ✅ message d'erreur itinéraire
  bool itineraireActif = false; // ✅ route tracée ?

  // ── Données ────────────────────────────────────────────────
  Pharmacie? selectedPharmacie;
  List<Pharmacie> listePharmacie = [];
  final Map<String, Pharmacie> _annotationIdToPharmacy = {};

  bool get _afficherUniquementCible => widget.pharmacie != null;


  // ✅ Même token que dans main.dart / MapboxOptions.accessToken
  // En production : utilise flutter_dotenv ou --dart-define
  String? _mapboxToken = 'TON_MAPBOX_ACCESS_TOKEN';

  // ─────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    selectedPharmacie = widget.pharmacie;
    _initializeLocation();
  }

  @override
  void dispose() {
    userPositionStream?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────
  // Carte : création et initialisation
  // ─────────────────────────────────────────────────────────────────────
  void _onMapCreated(mb.MapboxMap controller) async {
    print('🗺️ Carte créée');
    setState(() => mapboxMapController = controller);

    mapboxMapController?.gestures.updateSettings(mb.GesturesSettings());
    mapboxMapController?.location.updateSettings(
      mb.LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );

    await _initAnnotationManager();
    _centerMapOnUser();

    if (currentPosition != null) {
      await addMarker(
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude,
        title: "Moi",
      );
    }

    if (_afficherUniquementCible) {
      final p = widget.pharmacie!;
      if (p.latitude != null && p.longitude != null) {
        await addMarker(
          latitude: p.latitude!,
          longitude: p.longitude!,
          title: p.nomPharmacie,
          pharmacie: p,
        );
      }
    } else {
      await recupererPharmacie();
      for (final pharmacie in listePharmacie) {
        if (pharmacie.latitude != null && pharmacie.longitude != null) {
          await addMarker(
            latitude: pharmacie.latitude!,
            longitude: pharmacie.longitude!,
            title: pharmacie.nomPharmacie,
            pharmacie: pharmacie,
          );
        }
      }
    }
  }

  Future<void> _initAnnotationManager() async {
    if (mapboxMapController != null && annotationManager == null) {
      // Manager marqueurs
      annotationManager = await mapboxMapController!.annotations
          .createPointAnnotationManager();

      annotationManager!.addOnPointAnnotationClickListener(
        _PharmacieAnnotationClickListener(
          onAnnotationClick: (annotation) {
            final tapped = _annotationIdToPharmacy[annotation.id];
            if (tapped != null && mounted) {
              setState(() {
                selectedPharmacie = tapped;
                // Réinitialiser l'itinéraire au changement de pharmacie
                itineraireActif = false;
                itineraireErrorMessage = null;
              });
            }
          },
        ),
      );

      // ✅ Manager polylines (route)
      polylineManager = await mapboxMapController!.annotations
          .createPolylineAnnotationManager();

      print('✅ Managers initialisés');
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // ✅ Tracer l'itinéraire via API Directions Mapbox
  // ─────────────────────────────────────────────────────────────────────
  Future<void> _tracerItineraire(Pharmacie pharma) async {
    if (currentPosition == null) {
      setState(() => itineraireErrorMessage = 'Position actuelle indisponible');
      return;
    }
    if (pharma.latitude == null || pharma.longitude == null) {
      setState(
        () => itineraireErrorMessage = 'Coordonnées de la pharmacie manquantes',
      );
      return;
    }
    if (polylineManager == null) {
      setState(() => itineraireErrorMessage = 'Carte non prête, réessaie');
      return;
    }

    setState(() {
      isLoadingItineraire = true;
      itineraireErrorMessage = null;
    });
    await dotenv.load(fileName: '.env');

    setState(() {
      _mapboxToken = dotenv.env["MAPBOX_ACCESS_TOKEN"];
    });

    try {
      final startLng = currentPosition!.longitude;
      final startLat = currentPosition!.latitude;
      final endLng = pharma.longitude!;
      final endLat = pharma.latitude!;

      // Appel API Directions Mapbox
      // Profils disponibles : driving | walking | cycling
      final url = Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving/'
        '$startLng,$startLat;$endLng,$endLat'
        '?geometries=geojson'
        '&overview=full'
        '&steps=false'
        '&access_token=$_mapboxToken',
      );

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Délai de connexion dépassé'),
          );

      if (response.statusCode != 200) {
        throw Exception('Erreur serveur (${response.statusCode})');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List?;

      if (routes == null || routes.isEmpty) {
        throw Exception('Aucun itinéraire trouvé');
      }

      // Extraire les coordonnées GeoJSON [lng, lat]
      final coords = routes[0]['geometry']['coordinates'] as List;
      final List<mb.Position> positions = coords
          .map(
            (c) =>
                mb.Position((c[0] as num).toDouble(), (c[1] as num).toDouble()),
          )
          .toList();

      // Effacer l'ancien itinéraire
      await polylineManager!.deleteAll();

      // Tracer la route
      await polylineManager!.create(
        mb.PolylineAnnotationOptions(
          geometry: mb.LineString(coordinates: positions),
          lineColor: Couleurs.mapBlue.value,
          lineWidth: 5.0,
          lineOpacity: 0.85,
          lineJoin: mb.LineJoin.ROUND,
        ),
      );

      // Ajuster le zoom pour voir tout le trajet
      _ajusterCameraItineraire(
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
      );

      // Extraire distance et durée depuis la réponse
      final distanceKm = ((routes[0]['distance'] as num) / 1000)
          .toStringAsFixed(1);
      final dureeMin = ((routes[0]['duration'] as num) / 60).ceil();
      print('✅ Itinéraire : $distanceKm km — $dureeMin min');

      if (mounted) setState(() => itineraireActif = true);
    } catch (e) {
      print('❌ Erreur itinéraire: $e');
      if (mounted) {
        setState(() {
          itineraireErrorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => isLoadingItineraire = false);
    }
  }

  // ✅ Effacer la route tracée
  Future<void> _effacerItineraire() async {
    await polylineManager?.deleteAll();
    if (mounted) {
      setState(() {
        itineraireActif = false;
        itineraireErrorMessage = null;
      });
    }
  }

  // ✅ Zoom automatique pour voir départ + arrivée
  void _ajusterCameraItineraire({required double startLat, required double startLng, required double endLat, required double endLng,}) {
    final minLat = startLat < endLat ? startLat : endLat;
    final maxLat = startLat > endLat ? startLat : endLat;
    final minLng = startLng < endLng ? startLng : endLng;
    final maxLng = startLng > endLng ? startLng : endLng;

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    // Zoom adaptatif selon l'écart entre les deux points
    final maxDelta = (maxLat - minLat) > (maxLng - minLng)
        ? maxLat - minLat
        : maxLng - minLng;

    final double zoom;
    if (maxDelta < 0.01)
      zoom = 15.0;
    else if (maxDelta < 0.05)
      zoom = 13.0;
    else if (maxDelta < 0.1)
      zoom = 12.0;
    else if (maxDelta < 0.5)
      zoom = 11.0;
    else
      zoom = 9.0;

    mapboxMapController?.setCamera(
      mb.CameraOptions(
        center: mb.Point(coordinates: mb.Position(centerLng, centerLat)),
        zoom: zoom,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Marqueurs
  // ─────────────────────────────────────────────────────────────────────
  Future<Uint8List> loadMarkerImage(String nomMarqueur) async {
    final byteData = await rootBundle.load("assets/images/$nomMarqueur.png");
    return byteData.buffer.asUint8List();
  }

  Future<void> addMarker({
    required double latitude,
    required double longitude,
    String? title,
    Pharmacie? pharmacie,
  }) async {
    if (annotationManager == null) await _initAnnotationManager();
    if (annotationManager == null) return;

    final markerImage = await loadMarkerImage("Logo pour icone");
    final markerMoi = await loadMarkerImage("moi2");
    final bool isMoi = title == "Moi";

    final options = mb.PointAnnotationOptions(
      geometry: mb.Point(coordinates: mb.Position(longitude, latitude)),
      textField: title ?? 'Moi',
      textSize: 15.0,
      textMaxWidth: 12,
      textColor: Colors.black.value,
      iconSize: isMoi ? 0.04 : 0.2,
      image: isMoi ? markerMoi : markerImage,
    );

    final annotation = await annotationManager!.create(options);
    if (pharmacie != null) {
      _annotationIdToPharmacy[annotation.id] = pharmacie;
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Localisation
  // ─────────────────────────────────────────────────────────────────────
  Future<void> _initializeLocation() async {
    try {
      geo.Position position;
      if (useMockLocation) {
        position = geo.Position(
          latitude: 5.340693458088221,
          longitude: -4.145782084657672,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
      } else {
        position = await _getPosition();
      }

      if (mounted) {
        setState(() {
          currentPosition = position;
          isLoading = false;
        });
        if (mapboxMapController != null) _centerMapOnUser();
        if (!useMockLocation) _listenToPositionChanges();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  void _centerMapOnUser() {
    if (mapboxMapController == null) return;

    if (widget.pharmacie != null) {
      mapboxMapController!.setCamera(
        mb.CameraOptions(
          center: mb.Point(
            coordinates: mb.Position(
              widget.pharmacie!.longitude as num,
              widget.pharmacie!.latitude as num,
            ),
          ),
          zoom: 15.0,
        ),
      );
    } else if (currentPosition != null) {
      mapboxMapController!.setCamera(
        mb.CameraOptions(
          center: mb.Point(
            coordinates: mb.Position(
              currentPosition!.longitude,
              currentPosition!.latitude,
            ),
          ),
          zoom: 13.0,
        ),
      );
    }
  }

  Future<geo.Position> _getPosition() async {
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Veuillez activer la localisation');

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

  void _listenToPositionChanges() {
    userPositionStream =
        geo.Geolocator.getPositionStream(
          locationSettings: const geo.LocationSettings(
            accuracy: geo.LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((pos) {
          if (mounted) setState(() => currentPosition = pos);
        });
  }

  void _onTap(mb.MapContentGestureContext context) {
    if (mounted) setState(() => selectedPharmacie = null);
  }

  Future<void> recupererPharmacie() async {
    final vm = context.read<PharmacieViewModel>();
    await vm.init();
    if (vm.errorMessage == null) {
      final ville =
          context.read<AuthViewModel>().session?.villeUtilisateur ?? '';
      if (mounted) {
        setState(() {
          listePharmacie = vm.pharmacies
              .where((p) => p.villePharmacie!.contains(ville))
              .toList();
        });
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.lightGreen,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Couleurs.darkGreen,
        title: Text(
          widget.pharmacie != null
              ? "${widget.pharmacie!.nomPharmacie} sur la carte"
              : "Vue sur la carte",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            mb.MapWidget(
              onMapCreated: _onMapCreated,
              onTapListener: _onTap,
              styleUri: "mapbox://styles/mapbox/streets-v12",
            ),

            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),

            if (errorMessage != null)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_off,
                          color: Colors.white,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Erreur de localisation',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              errorMessage = null;
                              isLoading = true;
                            });
                            _initializeLocation();
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            _buildBottomPanel(),

            if (!isLoading && errorMessage == null) ...[
              // Bouton recentrer
              Positioned(
                right: 16,
                top: 50,
                child: FloatingActionButton(
                  heroTag: 'center',
                  onPressed: _centerMapOnUser,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
              ),

              // ✅ Bouton effacer itinéraire (visible seulement si actif)
              if (itineraireActif)
                Positioned(
                  right: 16,
                  top: 150,
                  child: FloatingActionButton(
                    heroTag: 'clear_route',
                    onPressed: _effacerItineraire,
                    backgroundColor: Colors.red[400],
                    tooltip: "Effacer l'itinéraire",
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Panneau bas
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildBottomPanel() {
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.10,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: ListView(
            controller: scrollController,
            children: [
              const SizedBox(height: 10),
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
              const SizedBox(height: 15),
              selectedPharmacie == null
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 100.h,
                        horizontal: 25.w,
                      ),
                      child: _emptyStatePharma(),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 5.h,
                        horizontal: 15.w,
                      ),
                      child: _detailsMarqueur(),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyStatePharma() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100]),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            const Text("Aucun détails disponible"),
            const Text("Veuillez toucher un marqueur sur la carte"),
          ],
        ),
      ),
    );
  }

  Widget _detailsMarqueur() {
    final pharma = selectedPharmacie!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Distance badge
        if (pharma.distance != null)
          Container(
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
              child: Text(
                'À ${double.tryParse(pharma.distance.toString())?.toStringAsFixed(0)} m de vous',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
            ),
          ),

        SizedBox(height: 8.h),

        // Nom + badge garde
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  pharma.nomPharmacie,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              decoration: BoxDecoration(
                color: pharma.estDeGarde == 0 ? Colors.red : Colors.green,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                child: Text(
                  pharma.estDeGarde == 0 ? "Pas de garde" : "De garde",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 4.h),

        // Adresse
        Row(
          children: [
            Icon(CupertinoIcons.location_solid, color: Couleurs.darkGreen),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                pharma.adresseFournit ?? 'Aucune adresse fournie',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 10.h),

        // Horaires
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            color: Colors.grey[100],
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.access_time_filled_sharp,
                  size: 28.r,
                  color: Couleurs.darkGreen,
                ),
                title: Text(
                  "Horaires d'ouverture",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ),
              _horaires(
                "Lundi-Vendredi",
                pharma.horaires_en_semaine ?? '08:30 - 21:30',
              ),
              Divider(
                height: 1,
                color: Colors.grey[300],
                indent: 20,
                endIndent: 20,
              ),
              _horaires("Samedi", pharma.horaires_samedi ?? '08:30 - 15:30'),
              Divider(
                height: 1,
                color: Colors.grey[300],
                indent: 20,
                endIndent: 20,
              ),
              _horaires("Dimanche", pharma.horaires_dimanche ?? 'Fermée'),
              SizedBox(height: 12.h),
            ],
          ),
        ),

        SizedBox(height: 10.h),

        // ✅ Message d'erreur itinéraire
        if (itineraireErrorMessage != null)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[400],
                      size: 20.r,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        itineraireErrorMessage!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ✅ Bouton itinéraire (3 états)
        _boutonItineraire(pharma),

        SizedBox(height: 10.h),
      ],
    );
  }

  // ✅ Bouton avec 3 états : chargement | effacer+recalculer | tracer
  Widget _boutonItineraire(Pharmacie pharma) {
    // État 1 — calcul en cours
    if (isLoadingItineraire) {
      return Container(
        decoration: BoxDecoration(
          color: Couleurs.mapBlue.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.all(12.w),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 10),
            Text(
              "Calcul en cours...",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // État 2 — itinéraire déjà affiché
    if (itineraireActif) {
      return Row(
        children: [
          // Effacer
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: _effacerItineraire,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                padding: EdgeInsets.all(10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close, color: Colors.grey[700]),
                    SizedBox(width: 6.w),
                    Text(
                      "Effacer",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Recalculer
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _tracerItineraire(pharma),
              child: Container(
                decoration: BoxDecoration(
                  color: Couleurs.mapBlue,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                padding: EdgeInsets.all(10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.arrow_branch,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6.w),
                    const Text(
                      "Recalculer",
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
        ],
      );
    }

    // État 3 — pas encore d'itinéraire
    return GestureDetector(
      onTap: () => _tracerItineraire(pharma),
      child: Container(
        decoration: BoxDecoration(
          color: Couleurs.mapBlue,
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.all(10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.arrow_branch, color: Colors.white),
            SizedBox(width: 10.w),
            const Text(
              "Tracer un itinéraire",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _horaires(String jour, String heures) {
    final bool estFerme = heures == "Fermé" || heures == "Fermée";
    return ListTile(
      leading: Text(jour, style: TextStyle(fontSize: 15.sp)),
      trailing: Text(
        heures,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17.sp,
          color: estFerme ? Colors.red : Colors.black,
        ),
      ),
    );
  }
}
