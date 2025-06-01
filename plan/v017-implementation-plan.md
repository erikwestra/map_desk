# v017 Implementation Plan

## Core Purpose
This phase implements segment selection and preview functionality, enabling users to:
1. Select segments from the list of found segments
2. Preview selected segments on the map
3. See how segments connect to the current track

## Key Components
1. **Segment Selection**
   - Enables selection of segments from the sidebar list
   - Only allows selection when in `choosingNextSegment` state
   - Provides visual feedback for selected segment

2. **Map Preview**
   - Shows the current track in blue
   - Displays selected segment in grey
   - Shows a grey line when a connecting segment is needed
   - Provides clear visual distinction between:
     - Current track (blue)
     - Preview (grey)

3. **Button Panel**
   - Updates based on segment selection state
   - Provides clear feedback about segment selection
   - Enables adding the selected segment to the track

## Success Criteria
- Segment selection works correctly
- Map preview shows current track and selected segment
- Connecting segments are clearly indicated
- Button panel updates appropriately
- Visual feedback is clear and intuitive
- Performance is maintained with large datasets

## Technical Notes
- Handle segment connectivity checks
- Maintain smooth transitions between states
- Ensure clear visual distinction between track and preview
- Follow existing styling patterns

## Dependencies
- No new dependencies required
- Uses existing:
  - `flutter_map`
  - `latlong2`
  - `provider` 