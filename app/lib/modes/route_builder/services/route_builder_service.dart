import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import '../models/route_builder_state.dart';

/// Service class for handling route building logic
class RouteBuilderService extends ChangeNotifier {
  final List<LatLng> _routePoints = [];
  final RouteBuilderStateProvider _stateProvider;
  
  RouteBuilderService(this._stateProvider);
  
  List<LatLng> get routePoints => List.unmodifiable(_routePoints);
  
  /// Handles a tap on the map
  void handleMapTap(LatLng point) {
    switch (_stateProvider.currentState) {
      case RouteBuilderState.awaitingStartPoint:
        _routePoints.add(point);
        _stateProvider.setState(RouteBuilderState.choosingNextSegment);
        break;
        
      case RouteBuilderState.choosingNextSegment:
        _routePoints.add(point);
        break;
    }
    notifyListeners();
  }
  
  /// Cancels the current route building session
  void cancel() {
    _routePoints.clear();
    _stateProvider.reset();
    notifyListeners();
  }
  
  /// Saves the current route
  void save() {
    // TODO: Implement route saving logic
    _routePoints.clear();
    _stateProvider.reset();
    notifyListeners();
  }
} 