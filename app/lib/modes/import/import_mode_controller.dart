import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../core/interfaces/mode_controller.dart';
import '../../core/interfaces/mode_ui_context.dart';
import '../../core/services/mode_service.dart';
import '../../core/services/menu_service.dart';
import '../../core/services/gpx_service.dart';
import '../../core/services/segment_sidebar_service.dart';
import '../../core/services/segment_service.dart';
import '../../core/models/simple_gpx_track.dart';
import '../../core/models/segment.dart';
import '../../core/widgets/edit_segment_dialog.dart';
import '../../main.dart';
import 'models/selectable_track.dart';

/// Controller for the Import mode, which handles track import and segment creation.
class ImportModeController extends ModeController {
  SimpleGpxTrack? _currentTrack;
  SelectableTrack? _selectableTrack;
  bool _isLoading = false;
  SegmentSidebarService? _segmentSidebarService;
  SegmentService? _segmentService;
  bool _isMapReady = false;
  bool _hasZoomedToBounds = false;
  double _lastZoomLevel = 2.0;
  int _currentSegmentNumber = 1;
  String _lastDirection = 'bidirectional';  // Default direction

  SimpleGpxTrack? get currentTrack => _currentTrack;
  bool get isTrackLoaded => _currentTrack != null;
  SelectableTrack? get selectableTrack => _selectableTrack;
  bool get isMapReady => _isMapReady;
  double get lastZoomLevel => _lastZoomLevel;

  ImportModeController(ModeUIContext uiContext) : super(uiContext);

  @override
  String get modeName => 'Import';

  @override
  bool get showLeftSidebar => true;

  @override
  bool get showRightSidebar => false;

  @override
  void onActivate() {
    // Initialize services if not already initialized
    _segmentSidebarService ??= Provider.of<ServiceProvider>(navigatorKey.currentContext!, listen: false).segmentSidebarService;
    _segmentService ??= Provider.of<ServiceProvider>(navigatorKey.currentContext!, listen: false).segmentService;
    
    // Show the current track in the segment sidebar
    _segmentSidebarService?.setShowCurrentTrack(true);
    // Clear any existing selection
    _segmentSidebarService?.clearSelection();
    // Update status bar
    _updateStatusBar();
  }

  @override
  void onDeactivate() {
    // Hide the current track in the segment sidebar
    _segmentSidebarService?.setShowCurrentTrack(false);
    // Clear status bar
    uiContext.statusBarService.clearContent();
  }

  @override
  void dispose() {
  }

  @override
  Map<String, dynamic> getState() => {};

  @override
  void restoreState(Map<String, dynamic> state) {}

  @override
  Future<void> handleEvent(String eventType, dynamic eventData) async {
    print('ImportModeController: Received event: $eventType');
    switch (eventType) {
      case 'menu_open':
        print('ImportModeController: Handling menu_open event');
        await _handleOpen();
        break;
      case 'track_selected':
        _handleTrackSelected(eventData as Segment);
        break;
      case 'segment_selected':
        _handleSegmentSelected(eventData as Segment);
        break;
      case 'map_ready':
        _handleMapReady();
        break;
      case 'map_click':
        _handleMapClick(eventData as LatLng);
        break;
      case 'create_segment':
        await _handleCreateSegment();
        break;
      case 'edit_segment':
        await _handleEditSegment(eventData);
        break;
      case 'delete_segment':
        await _handleDeleteSegment(eventData as Segment);
        break;
      case 'key_enter':
        // Only handle if both points are selected
        if (_selectableTrack != null && 
            _selectableTrack!.startPointIndex != null && 
            _selectableTrack!.endPointIndex != null) {
          await _handleCreateSegment();
        }
        break;
      case 'key_escape':
        // Only handle if we have an end point selected
        if (_selectableTrack != null && _selectableTrack!.endPointIndex != null) {
          // Clear end point selection
          _selectableTrack!.clearEndPoint();
          _updateMapContent();
          _updateStatusBar();
        }
        break;
      default:
        print('ImportModeController: Unhandled event type: $eventType');
    }
  }

  void _handleMapReady() {
    _isMapReady = true;
    if (isTrackLoaded && !_hasZoomedToBounds) {
      _scheduleZoomToTrackBounds();
    }
  }

  void _handleMapClick(LatLng point) {
    if (_selectableTrack == null) return;

    // Find the closest point on the track
    final points = _selectableTrack!.track.points;
    var closestIndex = 0;
    var minDistance = double.infinity;
    final distance = Distance();

    for (var i = 0; i < points.length; i++) {
      final trackPoint = points[i].toLatLng();
      final dist = distance.as(LengthUnit.Meter, point, trackPoint);
      if (dist < minDistance) {
        minDistance = dist;
        closestIndex = i;
      }
    }

    // If the point is too far from the track, ignore it
    if (minDistance > 10.0) return; // 10 meters threshold

    // If we have a start point, we can always select/update the end point
    if (_selectableTrack!.startPointIndex != null) {
      // Only allow selecting points after the start point
      if (closestIndex > _selectableTrack!.startPointIndex!) {
        _selectableTrack!.selectEndPoint(closestIndex);
        _updateMapContent();
        _updateStatusBar();
      }
    }
  }

  void _scheduleZoomToTrackBounds() {
    if (!_isMapReady) return;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_isMapReady) {
        _zoomToTrackBounds();
      }
    });
  }

  void _zoomToTrackBounds() {
    if (!_isMapReady || _currentTrack == null || _currentTrack!.points.isEmpty) return;
    try {
      final points = _currentTrack!.points.map((p) => p.toLatLng()).toList();
      final bounds = LatLngBounds.fromPoints(points);
      uiContext.mapViewService.mapController.fitBounds(
        bounds,
        options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
      );
      _hasZoomedToBounds = true;
      _lastZoomLevel = uiContext.mapViewService.mapController.zoom;
    } catch (e) {
      // If the map controller isn't ready yet, schedule another attempt
      _scheduleZoomToTrackBounds();
    }
  }

  void _updateMapContent() {
    if (_selectableTrack == null) return;

    final selectedPoints = _selectableTrack!.selectedPoints;
    final unselectedPoints = _selectableTrack!.unselectedPoints;

    // If we have an end point, the unselected portion should start from there
    if (_selectableTrack!.endPointIndex != null) {
      final endPoint = _selectableTrack!.track.points[_selectableTrack!.endPointIndex!].toLatLng();
      final remainingPoints = _selectableTrack!.track.points
          .skip(_selectableTrack!.endPointIndex! + 1)
          .map((p) => p.toLatLng())
          .toList();
      
      // Combine end point with remaining points
      final adjustedUnselectedPoints = [endPoint, ...remainingPoints];

      uiContext.mapViewService.setContent([
        // Draw unselected portion of track
        PolylineLayer(
          polylines: [
            Polyline(
              points: adjustedUnselectedPoints,
              color: Colors.blue.withOpacity(0.5),
              strokeWidth: 2.0,
            ),
          ],
        ),
        // Draw small blue circles around each unselected point
        CircleLayer(
          circles: adjustedUnselectedPoints.map((point) => CircleMarker(
            point: point,
            color: Colors.blue.withOpacity(0.5),
            radius: 3.0,
          )).toList(),
        ),
        // Draw selected portion of track
        PolylineLayer(
          polylines: [
            Polyline(
              points: selectedPoints,
              color: Colors.red.withOpacity(0.5),
              strokeWidth: 3.0,
            ),
          ],
        ),
        // Draw small red circles around each selected point
        CircleLayer(
          circles: selectedPoints.map((point) => CircleMarker(
            point: point,
            color: Colors.red.withOpacity(0.5),
            radius: 3.0,
          )).toList(),
        ),
        // Draw markers for start and end points
        CircleLayer(
          circles: [
            if (_selectableTrack!.startPointIndex != null)
              CircleMarker(
                point: _selectableTrack!.track.points[_selectableTrack!.startPointIndex!].toLatLng(),
                color: Colors.green,
                radius: 8.0,
              ),
            if (_selectableTrack!.endPointIndex != null)
              CircleMarker(
                point: _selectableTrack!.track.points[_selectableTrack!.endPointIndex!].toLatLng(),
                color: Colors.red,
                radius: 8.0,
              ),
          ],
        ),
      ]);
    } else {
      // If no end point is selected yet, show all points as unselected
      uiContext.mapViewService.setContent([
        // Draw unselected portion of track
        PolylineLayer(
          polylines: [
            Polyline(
              points: unselectedPoints,
              color: Colors.blue.withOpacity(0.5),
              strokeWidth: 2.0,
            ),
          ],
        ),
        // Draw small blue circles around each unselected point
        CircleLayer(
          circles: unselectedPoints.map((point) => CircleMarker(
            point: point,
            color: Colors.blue.withOpacity(0.5),
            radius: 3.0,
          )).toList(),
        ),
        // Draw selected portion of track
        PolylineLayer(
          polylines: [
            Polyline(
              points: selectedPoints,
              color: Colors.red.withOpacity(0.5),
              strokeWidth: 3.0,
            ),
          ],
        ),
        // Draw small red circles around each selected point
        CircleLayer(
          circles: selectedPoints.map((point) => CircleMarker(
            point: point,
            color: Colors.red.withOpacity(0.5),
            radius: 3.0,
          )).toList(),
        ),
        // Draw markers for start and end points
        CircleLayer(
          circles: [
            if (_selectableTrack!.startPointIndex != null)
              CircleMarker(
                point: _selectableTrack!.track.points[_selectableTrack!.startPointIndex!].toLatLng(),
                color: Colors.green,
                radius: 8.0,
              ),
            if (_selectableTrack!.endPointIndex != null)
              CircleMarker(
                point: _selectableTrack!.track.points[_selectableTrack!.endPointIndex!].toLatLng(),
                color: Colors.red,
                radius: 8.0,
              ),
          ],
        ),
      ]);
    }
  }

  void _updateStatusBar() {
    // Case 1: No track loaded
    if (_selectableTrack == null) {
      uiContext.statusBarService.setContent(
        Row(
          children: [
            const Text('No track loaded'),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () => _handleOpen(),
              child: const Text('Open'),
            ),
          ],
        ),
      );
      return;
    }

    // Case 2: No sidebar selection
    if (_segmentSidebarService?.selectedItem == null) {
      uiContext.statusBarService.clearContent();
      return;
    }

    // Case 3: Current track is selected
    if (_segmentSidebarService?.selectedItem?.type == 'current_track') {
      if (_selectableTrack!.endPointIndex == null) {
        uiContext.statusBarService.setContent(
          const Text('Click on end of segment'),
        );
      } else {
        // Show distance and action buttons
        final selectedPoints = _selectableTrack!.selectedPoints;
        final distance = Distance();
        var totalDistance = 0.0;
        for (var i = 0; i < selectedPoints.length - 1; i++) {
          totalDistance += distance.as(LengthUnit.Meter, selectedPoints[i], selectedPoints[i + 1]);
        }

        uiContext.statusBarService.setContent(
          Row(
            children: [
              Text('Selected segment: ${(totalDistance / 1000).toStringAsFixed(2)} km'),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  // Clear end point selection
                  _selectableTrack!.clearEndPoint();
                  _updateMapContent();
                  _updateStatusBar();
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  // Remove points up to but not including the end point
                  _selectableTrack!.removePointsUpTo(_selectableTrack!.endPointIndex! - 1);
                  // Set the end point as the new start point
                  _selectableTrack!.selectStartPoint(0);
                  _updateMapContent();
                  _updateStatusBar();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(navigatorKey.currentContext!).colorScheme.error.withOpacity(0.8),
                  foregroundColor: Theme.of(navigatorKey.currentContext!).colorScheme.onError,
                ),
                child: const Text('Delete'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _handleCreateSegment(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(navigatorKey.currentContext!).colorScheme.primary.withOpacity(0.8),
                  foregroundColor: Theme.of(navigatorKey.currentContext!).colorScheme.onPrimary,
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Case 4: A segment is selected
    uiContext.statusBarService.clearContent();
  }

  Future<void> _handleOpen() async {
    print('ImportModeController: Starting _handleOpen');
    if (_isLoading) {
      print('ImportModeController: Already loading, returning');
      return;
    }

    try {
      _isLoading = true;
      print('ImportModeController: Opening file picker');

      final typeGroup = XTypeGroup(
        label: 'GPX',
        extensions: ['gpx'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      print('ImportModeController: File picker result: ${file?.path}');

      if (file != null) {
        print('ImportModeController: Parsing GPX file');
        final track = await GpxService.parseGpxFile(File(file.path));
        _currentTrack = track;
        _selectableTrack = SelectableTrack(track);
        _hasZoomedToBounds = false;
        
        // Convert GpxPoint to SegmentPoint
        final segmentPoints = track.points.map((p) => SegmentPoint(
          latitude: p.latitude,
          longitude: p.longitude,
          elevation: p.elevation,
        )).toList();
        
        // Convert SimpleGpxTrack to Segment for the sidebar
        final segment = Segment.fromPoints(
          name: track.name,
          allPoints: segmentPoints,
          startIndex: 0,
          endIndex: segmentPoints.length - 1,
        );
        
        print('ImportModeController: Updating sidebar with track');
        // Update the segment sidebar with the new track
        _segmentSidebarService?.setCurrentTrack(segment);
        
        print('ImportModeController: Updating map content');
        // Update the map content
        _updateMapContent();
        
        // Update status bar
        _updateStatusBar();
        
        // Zoom to track bounds
        _scheduleZoomToTrackBounds();
        
        print('ImportModeController: Track loaded successfully');
      } else {
        print('ImportModeController: No file selected');
      }
    } catch (e) {
      print('ImportModeController: Failed to load GPX file: $e');
      _showError('Failed to load GPX file: $e');
    } finally {
      _isLoading = false;
      print('ImportModeController: Finished _handleOpen');
    }
  }

  void _handleTrackSelected(Segment track) {
    print('ImportModeController: Handling track selection');
    
    // Update the map content to show the track
    final points = track.points.map((p) => p.toLatLng()).toList();
    final bounds = LatLngBounds.fromPoints(points);
    
    // If we have a selectable track and points are selected, zoom to the appropriate point
    if (_selectableTrack != null) {
      LatLng? pointToZoom;
      
      // First try to zoom to end point if it exists
      if (_selectableTrack!.endPointIndex != null) {
        pointToZoom = _selectableTrack!.track.points[_selectableTrack!.endPointIndex!].toLatLng();
      }
      // If no end point, try to zoom to start point
      else if (_selectableTrack!.startPointIndex != null) {
        pointToZoom = _selectableTrack!.track.points[_selectableTrack!.startPointIndex!].toLatLng();
      }
      
      // If we have a point to zoom to, move the map there
      if (pointToZoom != null) {
        uiContext.mapViewService.mapController.move(
          pointToZoom,
          uiContext.mapViewService.mapController.camera.zoom,
        );
      } else {
        // If no specific point to zoom to, show the entire track
        uiContext.mapViewService.mapController.move(
          bounds.center,
          uiContext.mapViewService.mapController.camera.zoom,
        );
        uiContext.mapViewService.mapController.fitBounds(
          bounds,
          options: const FitBoundsOptions(padding: EdgeInsets.all(50.0)),
        );
      }
    } else {
      // If no selectable track, show the entire track
      uiContext.mapViewService.mapController.move(
        bounds.center,
        uiContext.mapViewService.mapController.camera.zoom,
      );
      uiContext.mapViewService.mapController.fitBounds(
        bounds,
        options: const FitBoundsOptions(padding: EdgeInsets.all(50.0)),
      );
    }
    
    _updateMapContent();
    _updateStatusBar();
    print('ImportModeController: Track selection handled');
  }

  void _handleSegmentSelected(Segment segment) {
    print('ImportModeController: Handling segment selection');
    // Update the map content to show the segment
    final points = segment.points.map((p) => p.toLatLng()).toList();
    final bounds = LatLngBounds.fromPoints(points);
    final theme = Theme.of(navigatorKey.currentContext!);
    
    // Create map content with the segment
    final content = <Widget>[
      // Segment layer
      PolylineLayer(
        polylines: [
          Polyline(
            points: points,
            color: theme.colorScheme.primary,
            strokeWidth: 4.0, // Thicker line for selected segment
          ),
        ],
      ),
      // Start and end markers
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
    ];
    
    // Set the map content
    uiContext.mapViewService.setContent(content);
    
    // Set the map bounds to show the entire segment
    uiContext.mapViewService.mapController.move(
      bounds.center,
      uiContext.mapViewService.mapController.camera.zoom,
    );
    uiContext.mapViewService.mapController.fitBounds(
      bounds,
      options: const FitBoundsOptions(padding: EdgeInsets.all(50.0)),
    );
    
    // Clear status bar when segment is selected
    uiContext.statusBarService.clearContent();
    
    print('ImportModeController: Segment selection handled');
  }

  Future<void> _handleCreateSegment() async {
    if (_selectableTrack == null || 
        _selectableTrack!.startPointIndex == null || 
        _selectableTrack!.endPointIndex == null) {
      _showError('Please select both start and end points before creating a segment');
      return;
    }

    try {
      // Show edit dialog first
      final result = await showDialog<dynamic>(
        context: navigatorKey.currentContext!,
        builder: (context) => EditSegmentDialog(
          name: 'Segment $_currentSegmentNumber',
          direction: _lastDirection,
          showDeleteButton: false,
          title: 'Create Segment',
          onDelete: () {
            // Remove points up to but not including the end point
            _selectableTrack!.removePointsUpTo(_selectableTrack!.endPointIndex! - 1);
            // Set the end point as the new start point
            _selectableTrack!.selectStartPoint(0);
            // Update UI
            _updateMapContent();
            _updateStatusBar();
          },
        ),
      );

      // If dialog was cancelled, just return
      if (result == null) return;

      // If result is 'delete', the onDelete callback was already called
      if (result == 'delete') return;

      // Create segment from selected points with the edited name and direction
      final Map<String, dynamic> segmentData = result as Map<String, dynamic>;
      final String newName = segmentData['name'] as String;
      _lastDirection = segmentData['direction'] as String;  // Save the direction for next time
      
      // Check if segment name already exists
      final existingSegments = await _segmentService?.getAllSegments() ?? [];
      if (existingSegments.any((s) => s.name == newName)) {
        _showError('A segment with this name already exists. Please choose a different name.');
        // Show the dialog again with the same name
        return _handleCreateSegment();
      }
      
      // Extract segment number from the name if it exists
      final RegExp numberRegex = RegExp(r'(\d+)$');
      final match = numberRegex.firstMatch(newName);
      if (match != null) {
        final numberStr = match.group(1);
        if (numberStr != null) {
          final number = int.tryParse(numberStr);
          if (number != null) {
            _currentSegmentNumber = number + 1;
          }
        }
      }

      final points = _selectableTrack!.track.points.map((p) => SegmentPoint(
        latitude: p.latitude,
        longitude: p.longitude,
        elevation: p.elevation,
      )).toList();

      final segment = Segment.fromPoints(
        name: newName,
        allPoints: points,
        startIndex: _selectableTrack!.startPointIndex!,
        endIndex: _selectableTrack!.endPointIndex!,
        direction: segmentData['direction'],
      );

      // Save segment to database
      await _segmentService?.createSegment(segment);

      // Remove points up to but not including the end point
      _selectableTrack!.removePointsUpTo(_selectableTrack!.endPointIndex! - 1);
      // Set the end point as the new start point
      _selectableTrack!.selectStartPoint(0);

      // Update UI
      _updateMapContent();
      _updateStatusBar();
      _segmentSidebarService?.refreshSegments();

      // Show success message
      _showSuccess('Segment created successfully');
    } catch (e) {
      _showError('Failed to create segment: $e');
    }
  }

  Future<void> _handleEditSegment(Map<String, dynamic> data) async {
    final segment = data['segment'] as Segment;
    final name = data['name'] as String;
    final direction = data['direction'] as String;

    try {
      // Check if segment name already exists (excluding the current segment)
      final existingSegments = await _segmentService?.getAllSegments() ?? [];
      if (existingSegments.any((s) => s.name == name && s.id != segment.id)) {
        _showError('A segment with this name already exists. Please choose a different name.');
        return;
      }

      // Update the segment in the database
      final updatedSegment = segment.copyWith(
        name: name,
        direction: direction,
      );
      await _segmentService?.updateSegment(updatedSegment);

      // Refresh the segment list in the sidebar
      await _segmentSidebarService?.refreshSegments();

      // Update the UI
      _updateStatusBar();
      _updateMapContent();

      // Show success message
      _showSuccess('Segment updated successfully');
    } catch (error) {
      print('ImportModeController: Failed to update segment: $error');
      _showError('Failed to update segment: $error');
    }
  }

  Future<void> _handleDeleteSegment(Segment segment) async {
    try {
      // Delete the segment from the database
      await _segmentService?.deleteSegment(segment.id);

      // Clear the selection
      _segmentSidebarService?.clearSelection();

      // Refresh the segment list in the sidebar
      await _segmentSidebarService?.refreshSegments();

      // Update the UI
      _updateStatusBar();
      _updateMapContent();

      // Show success message
      _showSuccess('Segment deleted successfully');
    } catch (error) {
      print('ImportModeController: Failed to delete segment: $error');
      _showError('Failed to delete segment: $error');
    }
  }

  void _showError(String message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // This method will be called by the map view to handle key events
  bool handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      // Check if Return/Enter key was pressed
      if (event.logicalKey == LogicalKeyboardKey.enter || 
          event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        // Only handle if both points are selected
        if (_selectableTrack != null && 
            _selectableTrack!.startPointIndex != null && 
            _selectableTrack!.endPointIndex != null) {
          _handleCreateSegment();
          return true; // Event was handled
        }
      }
    }
    return false; // Event was not handled
  }
}
