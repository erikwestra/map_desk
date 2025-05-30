# MapDesk v006 Changelog

## Overview
Version 006 implements a robust map initialization system that ensures proper loading of base map tiles and track visualization. This version focuses on fixing initialization issues and providing a consistent map experience across different views.

## Application Structure

### Screen Hierarchy
```
HomeScreen
├── MapView (ViewState.map)
├── ImportTrackView (ViewState.import)
├── SegmentLibraryView (ViewState.segments)
└── RouteBuilderView (ViewState.route)
```

### Widget Hierarchy
```
HomeScreen
├── PlatformMenuBar
│   ├── MapDesk Menu (Quit)
│   ├── File Menu (Open)
│   ├── Mode Menu (View switching)
│   └── Window Menu
└── Current View
    ├── MapView
    │   ├── FlutterMap
    │   │   ├── TileLayer
    │   │   ├── PolylineLayer
    │   │   └── CircleLayer
    │   └── MapControls
    ├── ImportTrackView
    │   ├── ImportMapView
    │   │   ├── FlutterMap
    │   │   │   ├── TileLayer
    │   │   │   ├── PolylineLayer
    │   │   │   ├── CircleLayer
    │   │   │   └── MarkerLayer
    │   │   └── MapControls
    │   └── SegmentSplitter
    ├── SegmentLibraryView
    └── RouteBuilderView
```

### Service Architecture
```
Provider
├── ViewService
│   └── ViewState management
├── MapService
│   ├── Map state
│   ├── Track visualization
│   └── Map controller
├── ImportService
│   ├── Track import
│   ├── Split mode
│   └── Segment creation
└── GPXService
    └── File parsing
```

## File Structure
```
app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── screens/
│   │   └── home_screen.dart      # Main screen with view switching
│   ├── services/
│   │   ├── view_service.dart     # View state management
│   │   ├── map_service.dart      # Main map state
│   │   ├── import_service.dart   # Import functionality
│   │   └── gpx_service.dart      # GPX file handling
│   ├── widgets/
│   │   ├── map_view.dart         # Main map visualization
│   │   ├── import_map_view.dart  # Import map view
│   │   ├── import_track_view.dart # Import track interface
│   │   ├── map_controls.dart     # Shared map controls
│   │   └── segment_splitter.dart # Track splitting interface
│   └── models/
│       ├── gpx_track.dart        # Track data model
│       └── segment.dart          # Segment data model
└── docs/
    └── v006-changelog.md        # This changelog
```

## Technical Implementation

### Map Initialization System
- Implemented state-based map initialization using `_isMapReady` flag
- Added delayed retry mechanism for zooming to track bounds
- Implemented error handling for map controller operations
- Added safety checks for map state before operations

### Key Components

#### Map Services
Both `MapService` and `ImportService` implement:
- Map ready state tracking
- Delayed zoom scheduling
- Error handling for map operations
- Safe map controller management

#### Map Views
Both `MapView` and `ImportMapView` implement:
- Stateful widget pattern for initialization
- Map ready callback handling
- Consistent map options and controls
- Unified track visualization

## Features

### Map Initialization
- Automatic base map tile loading
- Proper initialization sequence
- Error recovery mechanisms
- State-based initialization tracking

### Track Visualization
- Consistent track display across views
- Start/end point markers
- Track bounds calculation
- Automatic zoom to track

### Map Controls
- Unified control interface
- Zoom controls
- Pan controls
- Track-specific controls

### View Management
- Native macOS menu integration
- View state management
- Keyboard shortcuts
- View switching

## Technical Architecture

### State Management
- Provider pattern for service state
- ChangeNotifier for state updates
- Stateful widgets for view state
- Event-based initialization

### Map Controller Management
- Single controller instance per service
- Safe controller initialization
- Proper disposal handling
- Error recovery mechanisms

### View Architecture
- Consistent widget hierarchy
- Shared control components
- Unified styling
- Common interaction patterns

### Menu Integration
- Native macOS menu bar
- Standard menu items
- Keyboard shortcuts
- View switching commands 