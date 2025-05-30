# MapDesk v009 Implementation Plan

## Overview
Version 009 focuses on implementing a new track splitting visualization system that allows users to interactively select portions of a track by clicking on points. This version simplifies the track splitting process by focusing solely on visualization, without actual segment creation.

## Core Features
1. Track visualization with direction-based initial point selection
2. Interactive point selection with visual feedback
3. Dynamic track coloring based on selection

## Implementation Details

### Track Visualization

#### Track Display (`app/lib/widgets/track_display.dart`)
- Display entire track in red by default
- Set map bounds to track bounds on import
- Implement point selection visualization:
  - Selected point shown as blue circle
  - No other points displayed with circles
  - Click tolerance for point selection
- Track coloring:
  - Selected portion in blue
  - Remaining portion in red
- Direction-aware selection:
  - Forward: First point selected by default
  - Backward: Last point selected by default

### Data Model Updates

#### Track Model (`app/lib/models/track.dart`)
```dart
class Track {
  // Existing fields...
  
  // New fields
  int? selectedPointIndex;
  List<LatLng> selectedPoints;
  
  // New methods
  void selectPoint(int index);
  void clearSelection();
  List<LatLng> getPointsBeforeIndex(int index);
  List<LatLng> getPointsAfterIndex(int index);
}
```

### Service Layer Updates

#### Track Service (`app/lib/services/track_service.dart`)
- Add methods for point selection
- Implement point finding logic with tolerance
- Handle direction-based selection
- Manage track coloring state

### UI Components

#### Map View (`app/lib/widgets/map_view.dart`)
- Update to handle point selection
- Implement click detection with tolerance
- Manage track coloring
- Handle direction-based initial selection

#### Track Controls (`app/lib/widgets/track_controls.dart`)
- Add selection state display
- Show current selection information
- Provide clear selection option

## Technical Implementation

### Point Selection Logic
1. Calculate click tolerance based on zoom level
2. Find nearest track point within tolerance
3. Update selection state
4. Trigger track redraw

### Track Coloring
1. Split track into selected and unselected portions
2. Apply blue color to selected portion
3. Apply red color to unselected portion
4. Update map display

### Direction Handling
1. Check track direction on import
2. Set initial selection based on direction
3. Handle selection updates based on direction

## File Structure
```
app/
├── lib/
│   ├── models/
│   │   └── track.dart              # Updated track model
│   ├── services/
│   │   └── track_service.dart      # Updated track service
│   └── widgets/
│       ├── map_view.dart           # Updated map view
│       ├── track_display.dart      # New track display widget
│       └── track_controls.dart     # Updated track controls
└── plan/
    └── v009-implementation-plan.md # This implementation plan
```

## UI/UX Guidelines

### Track Visualization
- **Track Color**: Red (#FF0000) for unselected portions
- **Selected Portion**: Blue (#0000FF) for selected track
- **Selected Point**: Blue circle with 8px radius
- **Click Tolerance**: 10 pixels at current zoom level

### Interaction
- Click on track to select point
- Clear selection with dedicated button
- Automatic initial selection based on direction
- Smooth transitions for color changes

## Testing Requirements
1. Track import and display
2. Point selection accuracy
3. Direction-based initial selection
4. Track coloring updates
5. Click tolerance behavior
6. Performance with large tracks

## Success Metrics
- [ ] Track displays correctly in red
- [ ] Initial point selection works based on direction
- [ ] Point selection works within tolerance
- [ ] Track coloring updates correctly
- [ ] Map bounds set to track bounds
- [ ] Performance remains smooth with large tracks

## Future Considerations
- This version focuses solely on visualization
- Future versions will add segment creation
- Current implementation prepares for segment management
- UI/UX patterns established for future features 