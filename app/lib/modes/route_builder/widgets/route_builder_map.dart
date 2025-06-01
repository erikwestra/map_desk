import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/route_builder_service.dart';
import '../../map/services/map_service.dart';
import '../../../../shared/widgets/map_controls.dart';

/// Map widget specifically for route building interaction
class RouteBuilderMap extends StatelessWidget {
  const RouteBuilderMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<RouteBuilderService, MapService>(
      builder: (context, routeBuilder, mapService, child) {
        return Stack(
          children: [
            FlutterMap(
              mapController: mapService.mapController,
              options: MapOptions(
                initialCenter: const LatLng(0, 0),
                initialZoom: 2.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.map_desk',
                ),
                if (routeBuilder.routePoints.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routeBuilder.routePoints,
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 3.0,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: routeBuilder.routePoints.map((point) {
                    return Marker(
                      point: point,
                      width: 12,
                      height: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            MapControls(mapController: mapService.mapController),
          ],
        );
      },
    );
  }
} 