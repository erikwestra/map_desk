# v017 Changelog

## Overview
v017 implements segment selection and preview functionality in the route builder, allowing users to select segments, preview them on the map, and see how they connect to the current track.

## File Structure
```
app/
├── lib/
│   ├── modes/
│   │   └── route_builder/
│   │       ├── models/
│   │       │   └── route_builder_state.dart
│   │       ├── screens/
│   │       │   └── route_builder_screen.dart
│   │       ├── services/
│   │       │   └── route_builder_service.dart
│   │       └── widgets/
│   │           └── route_builder_map.dart
│   └── shared/
│       └── services/
│           └── map_controller_service.dart
```

## Implemented Features

### Route Builder Screen
- Split view layout with map and sidebar
- Status bar at bottom showing current state
- Sidebar showing nearby segments when a point is selected
- Consistent segment selection highlighting with segment library
- Action buttons for undo, add segment, and save

### Route Builder Map
- Interactive map view with OpenStreetMap tiles
- Track visualization:
  - Solid blue line for current track
  - Green circle marker at start
  - Red circle marker at end
- Preview visualization:
  - Dotted blue line for preview route
  - Blue circle marker at preview end
- Selected point marker
- Map controls for zoom and pan

### Route Builder Service
- State management for route building workflow
- Segment selection and preview generation
- Nearby segment search within 10-meter radius
- Support for one-way and bidirectional segments
- Track point management
- Undo functionality
- Save functionality (placeholder)

### Route Builder State
- State management for route building workflow:
  - `awaitingStartPoint`: Initial state
  - `choosingNextSegment`: After start point selection

### Map Controller Service
- Base service for map state management
- Map bounds and zoom level handling
- Map initialization and reset functionality

## Visual Design
- Consistent color scheme:
  - Primary blue for track and preview
  - Green for start point
  - Red for end point
  - White borders on markers
  - Black shadows for depth
- Consistent segment selection highlighting:
  - Bold text in primary color
  - Light primary color background
  - Direction indicator
- Clean, minimal interface
- Clear visual feedback for selections and previews 