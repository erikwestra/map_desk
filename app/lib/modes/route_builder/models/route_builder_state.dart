import 'package:flutter/foundation.dart';

/// Defines the state of the route builder feature
enum RouteBuilderState {
  /// Initial state, waiting for user to select a starting point
  awaitingStartPoint,
  
  /// User has selected a starting point and can choose the next segment
  choosingNextSegment,
}

/// Provider class for managing the route builder state
class RouteBuilderStateProvider extends ChangeNotifier {
  RouteBuilderState _currentState = RouteBuilderState.awaitingStartPoint;
  
  RouteBuilderState get currentState => _currentState;
  
  void setState(RouteBuilderState newState) {
    _currentState = newState;
    notifyListeners();
  }
  
  void reset() {
    _currentState = RouteBuilderState.awaitingStartPoint;
    notifyListeners();
  }
} 