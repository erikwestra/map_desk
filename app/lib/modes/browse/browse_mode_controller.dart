import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../core/interfaces/mode_controller.dart';
import '../../core/interfaces/mode_ui_context.dart';
import '../../core/services/mode_service.dart';
import '../../core/services/menu_service.dart';
import '../../core/services/segment_service.dart';
import '../../core/models/segment.dart';
import '../../main.dart';

/// Controller for the Browse mode, which handles segment library browsing.
class BrowseModeController extends ModeController with ChangeNotifier {
  final MapController _mapController = MapController();

  BrowseModeController(ModeUIContext uiContext) : super(uiContext);

  @override
  String get modeName => 'Browse';

  @override
  bool get showLeftSidebar => true;

  @override
  bool get showRightSidebar => false;

  @override
  void onActivate() {
    _updateStatusBar();
  }

  @override
  void onDeactivate() {
    uiContext.statusBarService.clearContent();
  }

  void _updateStatusBar() {
    final segmentService = Provider.of<ServiceProvider>(navigatorKey.currentContext!, listen: false).segmentService;
    
    segmentService.getAllSegments().then((segments) {
      uiContext.statusBarService.setContent(
        Text('${segments.length} segments'),
      );
    }).catchError((error) {
      uiContext.statusBarService.setContent(
        Text('Error: $error'),
      );
    });
  }

  @override
  Map<String, dynamic> getState() => {};

  @override
  void restoreState(Map<String, dynamic> state) {}

  @override
  Future<void> handleEvent(String eventType, dynamic eventData) async {
    switch (eventType) {
      // Menu events
      case 'menu_open':
        await _handleOpen();
        break;
      case 'menu_save_route':
        await _handleSaveRoute();
        break;
      case 'menu_undo':
        await _handleUndo();
        break;
      case 'menu_clear_track':
        await _handleClearTrack();
        break;
      
      // UI interaction events
      case 'map_click':
        if (eventData is LatLng) {
          await _handleMapClick(eventData);
        }
        break;
      case 'segment_selected':
        await _handleSegmentSelection(eventData);
        break;
      case 'route_point_selected':
        await _handleRoutePointSelection(eventData);
        break;
      default:
        print('BrowseModeController: Unhandled event type: $eventType');
    }
  }

  Future<void> _handleOpen() async {
    // TODO: Implement file opening in Browse mode
    print('BrowseModeController: Open called');
  }

  Future<void> _handleSaveRoute() async {
    // TODO: Implement save route in Browse mode
    print('BrowseModeController: Save route called');
  }

  Future<void> _handleUndo() async {
    // TODO: Implement undo in Browse mode
    print('BrowseModeController: Undo called');
  }

  Future<void> _handleClearTrack() async {
    // TODO: Implement track clearing in Browse mode
    print('BrowseModeController: Clear track called');
  }

  Future<void> _handleMapClick(LatLng point) async {
    // TODO: Implement map click handling in Browse mode
    print('BrowseModeController: Map clicked at $point');
  }

  Future<void> _handleSegmentSelection(dynamic segment) async {
    if (segment is! Segment) return;

    // Update status bar with segment info
    uiContext.statusBarService.setContent(
      Text('Selected: ${segment.name} (${segment.points.length} points)'),
    );

    // Calculate bounds of the segment
    final points = segment.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    final bounds = LatLngBounds.fromPoints(points);
    
    // Fit the map to the segment bounds with padding
    _mapController.fitBounds(
      bounds,
      options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
    );
  }

  Future<void> _handleRoutePointSelection(dynamic point) async {
    // TODO: Implement route point selection in Browse mode
    print('BrowseModeController: Route point selected: $point');
  }
}
