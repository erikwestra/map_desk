# MapDesk v019 Changelog

## Overview
Version 019 focuses on improving the menu system and user interface consistency across the application. The main changes include standardizing menu behavior, removing redundant UI elements, and ensuring consistent functionality across different modes.

## Menu System Changes

### File Menu
- Standardized "Open" command behavior across modes:
  - Enabled in Map mode for viewing tracks
  - Enabled in Import mode for track import
  - Disabled in Segment Library and Route Builder modes
- Removed redundant "Open" button from Import Track view
- Maintained consistent keyboard shortcuts (⌘O)

### Edit Menu
- Streamlined Edit menu to only show relevant items:
  - "Undo" command in Route Builder mode
  - "Clear Track" command in Route Builder mode
- Removed redundant status bar buttons for Undo, Save Track, and Clear
- Kept "Add Segment" as a status bar button for better UX

## UI Structure

### Main Application
```
app/
├── lib/
│   ├── main.dart                 # App entry point with menu system
│   ├── core/
│   │   ├── services/
│   │   │   ├── mode_service.dart    # Mode state management
│   │   │   ├── database_service.dart # Database operations
│   │   │   ├── gpx_service.dart     # GPX file handling
│   │   │   └── segment_service.dart # Segment management
│   │   └── models/
│   │       ├── simple_gpx_track.dart # Basic GPX track model
│   │       └── segment.dart         # Segment data model
│   ├── modes/
│   │   ├── map/
│   │   │   ├── services/
│   │   │   │   └── map_service.dart # Map state management
│   │   │   └── widgets/
│   │   │       └── map_view.dart    # Map display
│   │   ├── import_track/
│   │   │   ├── services/
│   │   │   │   └── import_service.dart # Import workflow
│   │   │   ├── widgets/
│   │   │   │   ├── import_track_view.dart      # Main import view
│   │   │   │   ├── import_track_map_view.dart  # Map for import
│   │   │   │   ├── import_track_selection_panel.dart # Track selection
│   │   │   │   └── import_track_status_bar.dart # Status display
│   │   │   └── models/
│   │   │       ├── selectable_item.dart        # Selection model
│   │   │       └── segment_import_options.dart # Import options
│   │   ├── segment_library/
│   │   │   ├── services/
│   │   │   │   └── segment_library_service.dart # Library management
│   │   │   └── widgets/
│   │   │       └── segment_library_view.dart    # Library display
│   │   └── route_builder/
│   │       ├── services/
│   │       │   ├── route_builder_service.dart    # Route building logic
│   │       │   └── route_builder_state.dart      # Route state
│   │       └── widgets/
│   │           ├── route_builder_view.dart       # Route builder UI
│   │           └── route_builder_menu.dart       # Route menu items
│   └── shared/
│       └── widgets/
│           ├── base_map_view.dart    # Common map functionality
│           └── map_controls.dart     # Map control buttons
```

## Service Architecture

### Core Services
- `ModeService`: Manages application mode state
- `DatabaseService`: Handles database operations
- `GpxService`: Manages GPX file parsing
- `SegmentService`: Handles segment data operations

### Mode-Specific Services
- `MapService`: Manages map state and interactions
- `ImportService`: Handles track import workflow
- `SegmentLibraryService`: Manages segment library
- `RouteBuilderService`: Handles route building logic

## Widget Architecture

### Main Components
- `AppMenuBar`: Manages the application menu system
- `HomeScreen`: Main application container
- Mode-specific views for each application mode

### Shared Components
- `BaseMapView`: Common map functionality
- `MapControls`: Reusable map control buttons

## State Management
- Uses Provider pattern for state management
- Mode-specific state handled by dedicated services
- Reactive UI updates through `Consumer` widgets

## User Interface

### Menu System
- Native macOS menu bar integration
- Context-aware menu items
- Consistent keyboard shortcuts

### Mode Views
- Map View: Track visualization
- Import Track: Track import and segment creation
- Segment Library: Segment management
- Route Builder: Route creation and editing

### Status Bars
- Mode-specific status information
- Context-aware action buttons
- Consistent styling across modes 