// Base map view widget that provides common functionality for all map views
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class BaseMapView extends StatefulWidget {
  final MapController mapController;
  final double initialZoom;
  final List<Widget> children;
  final Function(LatLng)? onTap;
  final Function()? onMapReady;

  const BaseMapView({
    super.key,
    required this.mapController,
    required this.initialZoom,
    required this.children,
    this.onTap,
    this.onMapReady,
  });

  @override
  State<BaseMapView> createState() => _BaseMapViewState();
}

class _BaseMapViewState extends State<BaseMapView> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        initialCenter: const LatLng(0, 0),  // Default center
        initialZoom: widget.initialZoom,
        interactionOptions: const InteractionOptions(
          enableScrollWheel: true,
          enableMultiFingerGestureRace: true,
          flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom | InteractiveFlag.scrollWheelZoom,
        ),
        maxZoom: 18.0,
        minZoom: 2.0,
        onMapReady: () {
          // Call the provided onMapReady callback if any
          widget.onMapReady?.call();
          
          // Force basemap to display by slightly moving the map
          Future.delayed(const Duration(milliseconds: 100), () {
            final currentCenter = widget.mapController.center;
            widget.mapController.move(
              LatLng(currentCenter.latitude + 0.0001, currentCenter.longitude + 0.0001),
              widget.mapController.zoom,
            );
          });
        },
        onTap: widget.onTap != null 
          ? (tapPosition, point) => widget.onTap!(point)
          : null,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.map_desk',
        ),
        ...widget.children,
      ],
    );
  }
} 