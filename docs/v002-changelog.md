# MapDesk v002 Changelog

## Overview
Version 002 of MapDesk implements interactive map functionality with OpenStreetMap integration, GPX track visualization, and native macOS menu integration.

## Features Implemented

### Map Integration
- Interactive OpenStreetMap display using `flutter_map` package
- Smooth map panning with optimized drag sensitivity
- Multi-touch zoom support
- Mouse wheel zoom support
- Double-tap/click zoom support
- Fixed north-up orientation (no rotation)
- Configurable zoom limits (2.0 to 18.0)

### GPX Track Visualization
- Red polyline track display (stroke width: 3.0)
- Track points loaded from GPX files
- Dynamic track rendering when GPX file loaded
- Automatic track bounds calculation

### Native macOS Integration
- Standard macOS menu bar implementation
- Working keyboard shortcuts:
  - ⌘O for file opening
  - ⌘Q for application quit
- Native file picker for GPX files
- Proper menu item naming following macOS conventions

### Network Configuration
- OpenStreetMap tile loading enabled
- Proper network permissions in Info.plist
- Configured entitlements for network access
- User agent set as 'com.mapdesk.app'

## Technical Architecture

### State Management
- Provider pattern implementation
- MapService for centralized map state handling
- Reactive UI updates based on track loading state

### Component Structure
- Stateless widget architecture
- Clear separation of map view and controls
- Stack-based layout for overlaying controls

### Map Configuration
- Custom interaction options
- Optimized gesture handling
- Tile layer configuration
- Polyline layer for track display

## File Structure

```
app/
├── lib/
│   ├── main.dart                 # App entry point & menu setup
│   ├── models/
│   │   └── gpx_track.dart        # GPX data structures
│   ├── services/
│   │   ├── gpx_service.dart      # GPX parsing logic
│   │   └── map_service.dart      # Map state management
│   ├── widgets/
│   │   ├── map_view.dart         # Main map component
│   │   └── map_controls.dart     # Zoom controls overlay
│   └── screens/
│       └── home_screen.dart      # Main app screen
├── macos/
│   └── Runner/
│       ├── Info.plist           # macOS configuration
│       └── DebugProfile.entitlements  # Network permissions
└── pubspec.yaml                 # Dependencies
```

## Dependencies
- `flutter_map: ^6.2.1` - OpenStreetMap integration
- `latlong2: ^0.8.1` - Coordinate handling
- `provider: ^6.1.1` - State management
- `file_picker: ^6.1.1` - File selection
- `xml: ^6.3.0` - GPX parsing

## Technical Details

### Map View Configuration
```dart
FlutterMap(
  options: MapOptions(
    initialCenter: const LatLng(0, 0),
    initialZoom: 2,
    interactionOptions: const InteractionOptions(
      enableScrollWheel: true,
      enableMultiFingerGestureRace: true,
      flags: InteractiveFlag.drag | 
             InteractiveFlag.pinchZoom | 
             InteractiveFlag.doubleTapZoom | 
             InteractiveFlag.scrollWheelZoom,
    ),
    maxZoom: 18.0,
    minZoom: 2.0,
  ),
  children: [
    TileLayer(...),
    PolylineLayer(...),
  ],
)
```

### Track Visualization
```dart
PolylineLayer(
  polylines: [
    Polyline(
      points: mapService.trackPoints,
      color: const Color(0xFFFF3B30),
      strokeWidth: 3.0,
    ),
  ],
)
```

### Network Configuration
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
``` 