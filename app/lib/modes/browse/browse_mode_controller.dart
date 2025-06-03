import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../core/interfaces/mode_controller.dart';
import '../../core/interfaces/mode_ui_context.dart';
import '../../core/services/mode_service.dart';
import '../../core/services/menu_service.dart';
import '../../core/services/segment_service.dart';
import '../../core/models/segment.dart';
import '../../main.dart';

/// Controller for the Browse mode, which handles segment library browsing.
class BrowseModeController extends ModeController with ChangeNotifier {
  String _searchText = '';

  BrowseModeController(ModeUIContext uiContext) : super(uiContext);

  @override
  String get modeName => 'Browse';

  @override
  bool get showLeftSidebar => true;

  @override
  bool get showRightSidebar => false;

  @override
  Widget buildLeftSidebar(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Text('Browse Sidebar'),
      ),
    );
  }

  @override
  Widget buildRightSidebar(BuildContext context) {
    return const Center(child: Text('Right Sidebar'));
  }

  @override
  Widget buildStatusBarContent(BuildContext context) {
    final segmentService = Provider.of<ServiceProvider>(context, listen: false).segmentService;
    
    return FutureBuilder<List<Segment>>(
      future: segmentService.getAllSegments(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return const Text('Loading segments...');
        }

        final segments = snapshot.data!;
        final matchingSegments = _searchText.isEmpty 
            ? segments 
            : segments.where((s) => s.name.toLowerCase().contains(_searchText.toLowerCase())).toList();

        return Text(
          _searchText.isEmpty
              ? '${segments.length} segments'
              : '${matchingSegments.length} matching segments',
        );
      },
    );
  }

  void setSearchText(String text) {
    _searchText = text;
    notifyListeners();
  }

  @override
  void onActivate() {}

  @override
  void onDeactivate() {}

  @override
  void dispose() {
    super.dispose();
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
    // TODO: Implement segment selection in Browse mode
    print('BrowseModeController: Segment selected: $segment');
  }

  Future<void> _handleRoutePointSelection(dynamic point) async {
    // TODO: Implement route point selection in Browse mode
    print('BrowseModeController: Route point selected: $point');
  }
}
