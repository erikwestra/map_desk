# MapDesk v013 Changelog

## Overview
Version 013 of MapDesk implements a robust track import and segmentation system with improved error handling and user feedback.

## Features Implemented

### Track Import System
- GPX file loading with native file picker
- Track visualization with OpenStreetMap integration
- Segment creation workflow with start/end point selection
- Segment library management
- Status bar with contextual messages
- Error handling for file operations

### Map Integration
- OpenStreetMap tile layer with error suppression
- Custom HTTP client configuration
- Smooth map panning and zooming
- Automatic bounds fitting for tracks and segments
- Map controls for zoom operations

### UI Components
- Split view with selection panel and map
- Status bar with contextual messages
- Map controls overlay
- Segment options dialog
- Track visualization with color coding:
  - Red for unselected portions
  - Blue for selected portions
  - Green marker for start point
  - Red marker for end point

### State Management
- ImportService for track import workflow
- ModeService for view switching
- MapService for map state
- GpxService for file parsing

## Technical Architecture

### Screen Structure
```
HomeScreen
├── PlatformMenuBar
└── _buildCurrentView
    ├── MapView
    ├── ImportTrackView
    ├── SegmentLibrary (placeholder)
    └── RouteBuilder (placeholder)
```

### Import Track View Structure
```
ImportTrackView
├── ImportTrackSelectionPanel
├── ImportTrackMapView
└── ImportTrackStatusBar
```

### Widget Hierarchy
```
BaseMapView
├── FlutterMap
│   ├── TileLayer
│   ├── PolylineLayer (track visualization)
│   ├── CircleLayer (point markers)
│   └── MapControls
└── Custom Overlays
```

### Service Layer
```
Services
├── ImportService
│   ├── Track management
│   ├── Segment creation
│   ├── State management
│   └── Map control
├── ModeService
│   └── View switching
├── MapService
│   └── Map state
└── GpxService
    └── File parsing
```

## File Structure
```
app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── core/
│   │   ├── models/
│   │   │   ├── simple_gpx_track.dart
│   │   │   ├── splittable_gpx_track.dart
│   │   │   └── segment.dart
│   │   └── services/
│   │       ├── mode_service.dart
│   │       └── gpx_service.dart
│   ├── modes/
│   │   ├── map/
│   │   │   ├── services/
│   │   │   │   └── map_service.dart
│   │   │   └── widgets/
│   │   │       └── map_view.dart
│   │   └── import_track/
│   │       ├── models/
│   │       │   ├── segment_import_options.dart
│   │       │   └── selectable_item.dart
│   │       ├── services/
│   │       │   └── import_service.dart
│   │       └── widgets/
│   │           ├── import_track_view.dart
│   │           ├── import_track_map_view.dart
│   │           ├── import_track_selection_panel.dart
│   │           ├── import_track_status_bar.dart
│   │           ├── import_track_options_dialog.dart
│   │           └── import_segment_map_view.dart
│   ├── screens/
│   │   └── home_screen.dart
│   └── shared/
│       └── widgets/
│           ├── base_map_view.dart
│           └── map_controls.dart
├── macos/
│   └── Runner/
│       └── Base.lproj/
│           └── MainMenu.xib
└── pubspec.yaml
```

## Dependencies
- `flutter_map: ^6.0.1` - OpenStreetMap integration
- `latlong2: ^0.9.1` - Coordinate handling
- `provider: ^6.1.1` - State management
- `file_selector: ^1.0.3` - Native file picker
- `xml: ^6.3.0` - GPX parsing
- `http: ^1.4.0` - Network operations

## Technical Details

### Map Configuration
```dart
TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.example.map_desk',
  errorTileCallback: (tile, error, stackTrace) {},
  tileProvider: NetworkTileProvider(
    httpClient: http.Client() as BaseClient,
  ),
)
```

### Track Visualization
```dart
PolylineLayer(
  polylines: [
    Polyline(
      points: unselectedPoints,
      color: const Color(0xFFFF3B30),
      strokeWidth: 3.0,
    ),
    Polyline(
      points: selectedPoints,
      color: const Color(0xFF007AFF),
      strokeWidth: 3.0,
    ),
  ],
)
```

### Status Messages
- No file: Empty message
- File loaded: "Click on one end of the track to start splitting"
- Start point selected: "Click to select segment"
- Segment selected: "Segment selected"

### Menu Structure
```
MapDesk (Application Menu)
├── Quit                    ⌘Q

File
├── Open                    ⌘O

Mode
├── Map
├── Import Track
├── Segment Library
└── Route Builder

Window
├── MapDesk                 (no shortcut)
``` 