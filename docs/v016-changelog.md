# v016 Changelog

## Overview
Implemented map interaction functionality for the route builder, allowing users to select starting points and find nearby segments.

## File Structure
```
app/lib/
├── modes/
│   └── route_builder/
│       ├── models/
│       │   └── route_builder_state.dart
│       ├── screens/
│       │   └── route_builder_screen.dart
│       ├── services/
│       │   └── route_builder_service.dart
│       └── widgets/
│           └── route_builder_map.dart
└── shared/
    └── widgets/
        └── base_map_view.dart
```

## Implemented Features

### Route Builder Service
- Manages route building state and logic
- Handles map tap events
- Implements segment search within 10-meter radius
- Supports one-way and bidirectional segments
- Maintains selected points and nearby segments
- Provides undo and save functionality

### Route Builder Screen
- Implements main screen layout with map and sidebar
- Provides status bar with state-based messages
- Shows empty sidebar initially
- Displays found segments in sidebar after map interaction
- Includes undo and save buttons
- Handles segment selection UI

### Route Builder Map
- Extends base map view with route builder functionality
- Handles tap events for point selection
- Displays selected points and route markers
- Shows visual feedback for user interactions

### State Management
- Uses Provider pattern for state management
- Implements RouteBuilderState for tracking current state
- Manages transitions between states:
  - Awaiting start point
  - Choosing next segment

## UI Components

### Main Screen Layout
- Map view (expanded)
- Sidebar (300px width)
- Status bar (40px height)

### Sidebar States
- Empty (initial state)
- No segments found
- List of found segments with:
  - Segment name
  - Point count
  - Direction indicator
  - Action buttons

### Status Messages
- "Click on the map to select a starting point"
- "Select a segment to continue building the route"

## Technical Implementation

### Segment Search
- 10-meter radius search
- One-way segment handling:
  - Only includes if first point is within radius
- Bidirectional segment handling:
  - Includes if either first or last point is within radius
- Efficient distance calculations using latlong2

### State Transitions
- Initial state: awaiting start point
- After valid tap: choosing next segment
- After undo: returns to initial state
- After save: returns to initial state

### Error Handling
- Graceful handling of no segments found
- Clear user feedback
- Non-blocking UI during operations 