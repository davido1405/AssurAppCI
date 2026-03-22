import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;


class Carte extends StatefulWidget {
  const Carte({super.key});

  @override
  State<Carte> createState() => _CarteState();
}

class _CarteState extends State<Carte> {
  mb.MapboxMap? mapboxMapController;
  StreamSubscription<geo.Position>? userPositionStream;
  geo.Position? currentPosition;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    userPositionStream?.cancel();
    super.dispose();
  }

  // ✅ Initialiser la localisation
  Future<void> _initializeLocation() async {
    try {
      final position = await _getPosition();

      if (mounted) {
        setState(() {
          currentPosition = position;
          isLoading = false;
        });

        // Centrer la carte sur la position utilisateur
        _centerMapOnUser();

        // Écouter les changements de position
        _listenToPositionChanges();
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

  // ✅ Centrer la carte sur l'utilisateur
  void _centerMapOnUser() {
    if (currentPosition != null && mapboxMapController != null) {
      final coords = mb.Position(
        currentPosition!.longitude,
        currentPosition!.latitude,
      );

      mapboxMapController?.setCamera(
        mb.CameraOptions(
          center: mb.Point(coordinates: coords),
          zoom: 15.0,
        ),
      );
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

    userPositionStream = geo.Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
          (geo.Position position) {
        if (mounted) {
          setState(() {
            currentPosition = position;
          });
        }
      },
    );
  }

  // ✅ Callback création de la carte
  void _onMapCreated(mb.MapboxMap controller) {
    setState(() {
      mapboxMapController = controller;
    });

    // Activer le composant de localisation
    mapboxMapController?.location.updateSettings(
      mb.LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
      ),
    );

    // Centrer sur l'utilisateur si position déjà disponible
    if (currentPosition != null) {
      _centerMapOnUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Carte
          mb.MapWidget(
            onMapCreated: _onMapCreated,
          ),

          // Loading indicator
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
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
                      Icon(
                        Icons.location_off,
                        color: Colors.white,
                        size: 60,
                      ),
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
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
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

          // Bouton recentrer
          if (!isLoading && errorMessage == null)
            Positioned(
              right: 16,
              bottom: 100,
              child: FloatingActionButton(
                onPressed: _centerMapOnUser,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.my_location,
                  color: Colors.blue,
                ),
              ),
            ),
        ],
      ),
    );
  }
}