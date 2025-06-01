import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/route_builder_service.dart';
import '../../map/services/map_service.dart';
import '../../../../shared/widgets/map_controls.dart';
import '../../../../shared/widgets/base_map_view.dart';
import '../../../../core/services/segment_service.dart';

/// Map widget specifically for route building interaction
class RouteBuilderMap extends StatefulWidget {
  const RouteBuilderMap({super.key});

  @override
  State<RouteBuilderMap> createState() => _RouteBuilderMapState();
}

class _RouteBuilderMapState extends State<RouteBuilderMap> {
  bool _hasInitialized = false;

  @override
  Widget build(BuildContext context) {
    return Consumer3<RouteBuilderService, MapService, SegmentService>(
      builder: (context, routeBuilder, mapService, segmentService, child) {
        // Initialize map view to show all segments if not already done
        if (!_hasInitialized && routeBuilder.routePoints.isEmpty) {
          _hasInitialized = true;
          _initializeMapView(mapService, segmentService);
        }

        return Stack(
          children: [
            BaseMapView(
              mapController: mapService.mapController,
              initialZoom: 2.0,
              onTap: (point) {
                routeBuilder.handleMapTap(point);
              },
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.map_desk',
                ),
                // Current route
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
                // Preview route
                if (routeBuilder.previewPoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routeBuilder.previewPoints,
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 3.0,
                        isDotted: true,
                      ),
                    ],
                  ),
                // Preview end point marker
                if (routeBuilder.previewPoints.isNotEmpty)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: routeBuilder.previewPoints.last,
                        width: 16,
                        height: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                // Selected point marker
                if (routeBuilder.selectedPoint != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: routeBuilder.selectedPoint!,
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        borderColor: Theme.of(context).primaryColor,
                        borderStrokeWidth: 2.0,
                        radius: 8.0,
                      ),
                    ],
                  ),
                // Start and end point markers
                if (routeBuilder.routePoints.isNotEmpty)
                  MarkerLayer(
                    markers: [
                      // Start point marker (green)
                      if (routeBuilder.routePoints.isNotEmpty)
                        Marker(
                          point: routeBuilder.routePoints.first,
                          width: 16,
                          height: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      // End point marker (red)
                      if (routeBuilder.routePoints.length > 1)
                        Marker(
                          point: routeBuilder.routePoints.last,
                          width: 16,
                          height: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            MapControls(mapController: mapService.mapController),
          ],
        );
      },
    );
  }

  Future<void> _initializeMapView(MapService mapService, SegmentService segmentService) async {
    try {
      final segments = await segmentService.getAllSegments();
      if (segments.isEmpty) return;

      // Collect all points from all segments
      final allPoints = segments.expand((segment) => 
        segment.points.map((p) => LatLng(p.latitude, p.longitude))
      ).toList();

      if (allPoints.isEmpty) return;

      // Calculate bounds and zoom to them
      final bounds = LatLngBounds.fromPoints(allPoints);
      mapService.mapController.fitBounds(
        bounds,
        options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
      );
    } catch (e) {
      // If there's an error, just use the default view
      mapService.resetMapController();
    }
  }
} 