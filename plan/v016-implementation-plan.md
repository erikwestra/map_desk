# v016 Implementation Plan

## Core Purpose
This phase implements the map interaction functionality, allowing users to:
1. Select a starting point on the map
2. Find nearby segments within a 10-meter radius
3. Display these segments in the sidebar for selection

## Key Components
1. **Map Interaction**
   - Implements tap handling on the map only when in `awaitingStartPoint` state
   - Ignores taps when in `choosingNextSegment` state
   - Validates tap points against map boundaries
   - Transitions state from `awaitingStartPoint` to `choosingNextSegment` after valid tap

2. **Segment Finding**
   - Searches for segments within 10 meters of the selected point
   - For one-way segments: only includes segment if its first point is within radius
   - For bidirectional segments: includes segment if either first or last point is within radius
   - Updates sidebar with found segments

3. **Visual Feedback**
   - Shows selected point on the map
   - Displays found segments in the sidebar
   - Provides clear indication of segment direction and type

## Success Criteria
- Map taps are properly handled
- Segments are correctly found within radius
- Sidebar updates with found segments
- Visual feedback is clear and intuitive
- State transitions work correctly
- Performance is maintained with large datasets

## Technical Notes
- Use efficient spatial search algorithms
- Handle edge cases (no segments found, invalid points)
- Maintain responsive UI during searches
- Follow existing styling patterns

## Dependencies
- No new dependencies required
- Uses existing:
  - `flutter_map`
  - `latlong2`
  - `provider` 