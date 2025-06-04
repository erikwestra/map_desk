import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../interfaces/mode_controller.dart';
import '../interfaces/mode_ui_context.dart';
import '../services/mode_service.dart';
import '../services/menu_service.dart';
import '../services/segment_service.dart';
import '../models/segment.dart';
import '../main.dart';

/// Controller for the Browse mode, which handles segment library browsing.
class BrowseModeController extends ModeController with ChangeNotifier {
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
    _updateMapContent();
    
    // Set segment sidebar to editable in Browse mode
    uiContext.segmentSidebarService.setEditable(true);
  }

  @override
  void onDeactivate() {
    uiContext.statusBarService.clearContent();
    uiContext.mapViewService.clearContent();
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

  void _updateMapContent() {
    final segmentService = Provider.of<ServiceProvider>(navigatorKey.currentContext!, listen: false).segmentService;
    final selectedSegment = uiContext.segmentSidebarService.selectedSegment;
    final theme = Theme.of(navigatorKey.currentContext!);
    
    segmentService.getAllSegments().then((segments) {
      // Create map content with all segments
      final content = <Widget>[
        // All segments layer
        PolylineLayer(
          polylines: segments.map((segment) {
            final isSelected = selectedSegment != null && segment.id == selectedSegment.id;
            return Polyline(
              points: segment.points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
              color: theme.colorScheme.primary,
              strokeWidth: isSelected ? 4.0 : 2.0,
            );
          }).toList(),
        ),
      ];

      // Add markers for selected segment if any
      if (selectedSegment != null) {
        final points = selectedSegment.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
        content.add(
          CircleLayer(
            circles: [
              // Start point marker (green)
              CircleMarker(
                point: points.first,
                color: Colors.green,
                radius: 8.0,
              ),
              // End point marker (red)
              CircleMarker(
                point: points.last,
                color: Colors.red,
                radius: 8.0,
              ),
            ],
          ),
        );
      }

      uiContext.mapViewService.setContent(content);
    }).catchError((error) {
      print('BrowseModeController: Failed to update map content: $error');
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
      case 'edit_segment':
        await _handleEditSegment(eventData);
        break;
      case 'delete_segment':
        await _handleDeleteSegment(eventData);
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
    final segmentService = Provider.of<ServiceProvider>(navigatorKey.currentContext!, listen: false).segmentService;
    final segmentSidebarService = Provider.of<ServiceProvider>(navigatorKey.currentContext!, listen: false).segmentSidebarService;
    
    // Get all segments
    final segments = await segmentService.getAllSegments();
    
    // Find all segments that are near the clicked point
    final nearbySegments = <Segment>[];
    double minDistance = double.infinity;
    Segment? closestSegment;

    for (final segment in segments) {
      // Use the new calcDistanceToSegment method
      final distance = segment.calcDistanceToSegment(point, maxDistanceToCheck: 20.0);
      if (distance != null) {
        nearbySegments.add(segment);
        if (distance < minDistance) {
          minDistance = distance;
          closestSegment = segment;
        }
      }
    }
    
    // Select the closest segment if any were found
    if (closestSegment != null) {
      segmentSidebarService.selectSegment(closestSegment, shouldScroll: true);
    } else {
      segmentSidebarService.clearSelection();
    }
  }

  Future<void> _handleSegmentSelection(dynamic segment) async {
    if (segment is! Segment) return;

    // Calculate length in meters
    final lengthMeters = segment.calcLength();

    // Format length string based on distance
    final lengthString = lengthMeters < 1000 
        ? '${lengthMeters.round()} m'
        : '${(lengthMeters / 1000.0).toStringAsFixed(2)} km';

    // Update status bar with segment info
    uiContext.statusBarService.setContent(
      Text('Selected: ${segment.name} ($lengthString)'),
    );

    // Calculate bounds of the segment
    final points = segment.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    final bounds = LatLngBounds.fromPoints(points);
    
    // Fit the map to the segment bounds with padding
    uiContext.mapViewService.mapController.fitBounds(
      bounds,
      options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
    );

    // Update map content to highlight selected segment
    _updateMapContent();
  }

  Future<void> _handleRoutePointSelection(dynamic point) async {
    // TODO: Implement route point selection in Browse mode
    print('BrowseModeController: Route point selected: $point');
  }

  Future<void> _handleEditSegment(Map<String, dynamic> data) async {
    final segment = data['segment'] as Segment;
    final name = data['name'] as String;
    final direction = data['direction'] as String;

    final segmentService = Provider.of<ServiceProvider>(navigatorKey.currentContext!, listen: false).segmentService;
    final segmentSidebarService = Provider.of<ServiceProvider>(navigatorKey.currentContext!, listen: false).segmentSidebarService;
    
    try {
      // Update the segment in the database
      await segmentService.updateSegment(
        segment.copyWith(
          name: name,
          direction: direction,
        ),
      );

      // Refresh the segment list in the sidebar
      await segmentSidebarService.refreshSegments();

      // Update the UI
      _updateStatusBar();
      _updateMapContent();
    } catch (error) {
      print('BrowseModeController: Failed to update segment: $error');
      // TODO: Show error message to user
    }
  }

  Future<void> _handleDeleteSegment(Segment segment) async {
    final segmentService = Provider.of<ServiceProvider>(navigatorKey.currentContext!, listen: false).segmentService;
    final segmentSidebarService = Provider.of<ServiceProvider>(navigatorKey.currentContext!, listen: false).segmentSidebarService;
    
    try {
      // Delete the segment from the database using its ID
      await segmentService.deleteSegment(segment.id);

      // Clear the selection
      segmentSidebarService.clearSelection();

      // Refresh the segment list in the sidebar
      await segmentSidebarService.refreshSegments();

      // Update the UI
      _updateStatusBar();
      _updateMapContent();
    } catch (error) {
      print('BrowseModeController: Failed to delete segment: $error');
      // TODO: Show error message to user
    }
  }
}
