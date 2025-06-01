# v015 Changelog

## Overview
Implemented the foundational structure for the route builder feature, establishing the basic UI layout and state management system.

## File Structure
```
app/lib/modes/route_builder/
├── models/
│   └── route_builder_state.dart      # State management
├── screens/
│   └── route_builder_screen.dart     # Main screen layout
├── services/
│   └── route_builder_service.dart    # Route building logic
└── widgets/
    └── route_builder_map.dart        # Map display
```

## Components Implemented

### State Management
- Created `RouteBuilderState` enum with two states:
  - `awaitingStartPoint`: Initial state
  - `choosingNextSegment`: After start point selection
- Implemented `RouteBuilderStateProvider` for state management

### UI Structure
- Split view layout:
  - Map view (left side, expands to fill available space)
  - Sidebar (right side, fixed 300px width)
- Sidebar content changes based on current state:
  - Shows appropriate message for each state
- Map view:
  - Uses existing `BaseMapView` for map display
  - Includes standard map controls
  - Displays route points and lines when available

### Services
- `RouteBuilderService`:
  - Manages route points collection
  - Handles state transitions
  - Provides route data to UI components

### Integration
- Added route builder as a new mode in the application
- Integrated with existing provider system
- Uses shared map controls and base map view

## Technical Details
- Uses Flutter's Material Design components
- Follows Flutter/Dart naming conventions
- Implements proper state management with Provider
- Maintains clean separation of concerns between components
- Uses existing dependencies:
  - `flutter_map` for map display
  - `latlong2` for coordinate handling
  - `provider` for state management 