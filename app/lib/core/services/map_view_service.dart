import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Service that manages the content displayed on the map.
/// Acts as a central store for map content and notifies listeners when content changes.
class MapViewService extends ChangeNotifier {
  List<Widget> _content = [];
  final MapController mapController = MapController();
  bool _isMapReady = false;

  /// The current content to display on the map
  List<Widget> get content => _content;

  /// Whether the map is ready to display content
  bool get isMapReady => _isMapReady;

  /// Mark the map as ready
  void setMapReady() {
    _isMapReady = true;
    notifyListeners();
  }

  /// Update the map content
  void setContent(List<Widget> content) {
    _content = content;
    notifyListeners();
  }

  /// Clear the map content
  void clearContent() {
    _content = [];
    notifyListeners();
  }

  /// Center the map on a specific point
  void centerOnPoint(LatLng point) {
    mapController.move(point, mapController.zoom);
    notifyListeners();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
} 