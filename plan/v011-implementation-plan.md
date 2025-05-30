# MapDesk v011 Implementation Plan

## Overview
Version v011 focuses on enhancing the segment mode functionality with direction support and improved segment management controls. This version adds a direction field to segments, improves the status display, and adds new segment management buttons.

## Features

### 1. Segment Direction Field
- Add `direction` field to `Segment` model with two possible values:
  - `oneWay`: Segment can only be traversed in one direction
  - `bidirectional`: Segment can be traversed in both directions
- Update database schema to include new field
- Note: Direction field already exists in segment options dialog
- Default to `bidirectional` for new segments

### 2. Enhanced Status Display
- Modify status label in segment mode to show:
  - Format: "Main Street 1" (segment name + space + segment number)
- Add three new buttons to the right of status label:
  - Delete
  - Save
  - Options
- Style buttons to match existing UI

### 3. Delete Segment Functionality
- Implement delete button action to:
  - Remove current segment from track
  - Update track to start at end of deleted segment
  - Automatically select next segment start point
  - Update UI to reflect changes
- Add confirmation dialog before deletion
- Handle edge cases (first/last segment)

### 4. Save Segment Functionality
- Implement save button action to:
  - Create new segment in database
  - Add segment to right-hand side segment list
  - Update track to start at end of saved segment
  - Automatically select next segment start point
  - Increment segment number
  - Update UI to reflect changes
- Add success feedback
- Handle database errors gracefully

### 5. Segment Options Integration
- Reuse existing segment options dialog
- Ensure options are preserved when saving
- Update UI when options change
- Maintain consistency between dialog and saved data

## Technical Implementation

### Database Changes
```sql
ALTER TABLE segments ADD COLUMN direction TEXT NOT NULL DEFAULT 'bidirectional';
```

### Model Updates
```dart
class Segment {
  // ... existing fields ...
  final String direction; // 'oneWay' or 'bidirectional'
}
```

### UI Components
1. Status Bar Updates:
   - Modify existing status label
   - Add button row with consistent styling

2. Segment Options Dialog:
   - Update validation
   - Preserve existing options

### State Management
- Update segment state handling
- Add direction to segment creation/update logic
- Implement segment deletion logic
- Handle segment number management

## Success Metrics
- [ ] Direction field successfully added to segments
- [ ] Status display shows correct segment information
- [ ] Delete button properly removes segments
- [ ] Save button creates new segments correctly
- [ ] Options button shows and updates segment options
- [ ] Segment numbers increment correctly
- [ ] UI updates properly after all operations
- [ ] Database maintains data integrity
- [ ] All edge cases handled gracefully

## Dependencies
- No new external dependencies required
- Uses existing UI components
- Leverages current database structure

## Timeline
1. Database and Model Updates (Day 1)
2. UI Component Implementation (Day 2)
3. Segment Operations Implementation (Day 3)
4. Testing and Bug Fixes (Day 4)
5. Documentation and Final Review (Day 5)

## Notes
- Maintain existing error handling patterns
- Follow established UI/UX guidelines
- Ensure backward compatibility
- Document all new features
- Update user documentation 