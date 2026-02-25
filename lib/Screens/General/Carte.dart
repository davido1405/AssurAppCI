import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
class Carte extends StatefulWidget {
  const Carte({super.key});

  @override
  State<Carte> createState() => _CarteState();
}

class _CarteState extends State<Carte> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: FlutterMap(options:MapOptions(
      initialCenter: LatLng(7.546855,  -5.5471),
      initialZoom: 10,
      interactionOptions: const InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom),
    ),children: [
      openStreetMapTileLayer
    ],),);
  }
}
TileLayer get openStreetMapTileLayer =>TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',userAgentPackageName:'dev.fleaflet.flutter_map.example',);
