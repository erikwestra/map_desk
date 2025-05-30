# MapDesk v007 Changelog

## Overview
Version 007 reorganizes the import track screen to include a top information panel and a right-side segment list, while maintaining the main map view. This version focuses on improving the user interface organization and file handling workflow.

## Application Structure

### Screen Hierarchy
```
HomeScreen
├── MapView (ViewState.mapView)
├── ImportTrackView (ViewState.importTrack)
├── SegmentLibraryView (ViewState.segmentLibrary)
└── RouteBuilderView (ViewState.routeBuilder)
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
    │   ├── ImportTrackTopPanel
    │   │   ├── FileInfo
    │   │   └── FileControls
    │   └── MainContent
    │       ├── ImportMapView
    │       │   ├── FlutterMap
    │       │   │   ├── TileLayer
    │       │   │   ├── PolylineLayer
    │       │   │   ├── CircleLayer
    │       │   │   └── MarkerLayer
    │       │   └── MapControls
    │       ├── SegmentSplitter
    │       └── ImportTrackSegmentList
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
│   └── Segment management
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
│   │   ├── map_service.dart      # Map state and controls
│   │   ├── import_service.dart   # Track import and segments
│   │   └── gpx_service.dart      # GPX file parsing
│   ├── models/
│   │   ├── gpx_track.dart        # GPX data model
│   │   └── segment.dart          # Segment data model
│   └── widgets/
│       ├── map_view.dart         # Main map view
│       ├── map_controls.dart     # Map control buttons
│       ├── import_track_view.dart # Import track screen
│       ├── import_map_view.dart  # Map view for import
│       ├── import_track_top_panel.dart # Top panel for import
│       ├── import_track_segment_list.dart # Segment list
│       └── segment_splitter.dart # Segment creation UI
├── pubspec.yaml                  # Dependencies
└── macos/Runner/Info.plist       # macOS app configuration
```

## Implementation Details

### ImportTrackTopPanel
- Horizontal panel at the top of the import screen
- Shows current file name or "No file selected"
- Provides Open/Close buttons for file management
- Uses system styling and colors
- Handles file selection through file_selector package

### ImportTrackSegmentList
- Right-side panel showing created segments
- Displays segment name and description
- Provides delete functionality for segments
- Shows "No segments created yet" when empty
- Uses ListView for scrollable content

### ImportTrackView
- Main container for the import workflow
- Combines top panel, map view, and segment list
- Manages split mode and segment creation
- Handles point selection for segment creation
- Provides Done button to return to map view

### File Handling
- Removed automatic file picker on view entry
- File selection now controlled by user through top panel
- Clean file state management through ImportService
- Proper error handling for file operations

### UI/UX Improvements
- Cleaner, more organized layout
- Better visual hierarchy
- Improved user control over file operations
- Consistent macOS styling
- Responsive layout that maintains proportions

## Success Criteria
- ✅ Top panel displays correctly
- ✅ File state shows properly
- ✅ Open/Close controls work
- ✅ Segment list displays on right
- ✅ Map view maintains functionality
- ✅ Layout is responsive
- ✅ UI follows macOS guidelines 