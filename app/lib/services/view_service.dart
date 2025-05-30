// Manages application view state and navigation between different views.
import 'package:flutter/material.dart';

enum ViewState {
  mapView,
  importTrack,
  segmentLibrary,
  routeBuilder,
}

class ViewService extends ChangeNotifier {
  ViewState _currentView = ViewState.mapView;

  ViewState get currentView => _currentView;

  void setView(ViewState view) {
    _currentView = view;
    notifyListeners();
  }
} 