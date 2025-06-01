# v018 Changelog

## Overview
v018 implements track building functionality in the route builder, allowing users to build routes by connecting segments, with support for saving tracks as GPX files.

## File Structure
```
app/
├── lib/
│   ├── modes/
│   │   └── route_builder/
│   │       ├── models/
│   │       │   └── route_builder_state.dart      # State management
│   │       ├── screens/
│   │       │   └── route_builder_screen.dart     # Main screen layout
│   │       ├── services/
│   │       │   └── route_builder_service.dart    # Route building logic
│   │       └── widgets/
│   │           └── route_builder_map.dart        # Map display
│   └── shared/
│       └── widgets/
│           └── segment_direction_indicator.dart  # Segment direction UI
```

## Implemented Features

### Route Builder Screen
- Split view layout with map and sidebar
- Status bar with action buttons:
  - Undo: Remove last segment
  - Add Segment: Add selected segment to track
  - Save Track: Export track as GPX
  - Clear: Reset track and zoom to all segments
- Sidebar showing nearby segments when a point is selected
- Segment list with direction indicators
- Status messages for user feedback

### Route Builder Map
- Interactive map view with OpenStreetMap tiles
- Track visualization:
  - Solid blue line for current track
  - Dotted blue line for preview route
  - Circle markers for points
- Automatic map centering when adding segments
- Zoom to track bounds on clear

### Route Builder Service
- State management for route building workflow
- Segment selection and preview generation
- Nearby segment search within 20-meter radius
- Support for one-way and bidirectional segments
- Track point management
- Undo functionality
- Clear functionality with map reset
- GPX export with proper formatting:
  - Track name
  - Track points with lat/lon
  - Elevation data (if available)
  - No timestamps (routes only)

### Route Builder State
- State management for route building workflow:
  - `awaitingStartPoint`: Initial state
  - `choosingNextSegment`: After start point selection

## Technical Details
- Uses Flutter's Material Design components
- Follows Flutter/Dart naming conventions
- Implements proper state management with Provider
- Maintains clean separation of concerns between components
- Uses existing dependencies:
  - `flutter_map` for map display
  - `latlong2` for coordinate handling
  - `provider` for state management
  - `file_selector` for file operations
  - `xml` for GPX export 