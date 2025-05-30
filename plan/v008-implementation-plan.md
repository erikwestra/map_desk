# MapDesk v008 Implementation Plan

## Overview
Version 008 focuses on two main features:
1. Simplifying the segment data model by removing descriptions
2. Adding an "Import Track Options" modal dialog for GPX file import configuration

## Feature 1: Simplified Segment Model

### Changes Required

#### 1. Update Segment Model
- Remove description field from `Segment` class
- Update any UI components that display segment descriptions
- Ensure segment list view only shows segment names

#### 2. Update ImportTrackSegmentList Widget
- Remove description display from list items
- Simplify segment list item layout

#### 3. Update ImportService
- Remove description handling from segment creation logic
- Update segment management methods to work with simplified model

### Implementation Steps
1. Modify `lib/models/segment.dart`:
   - Remove description field
   - Update constructor
   - Update any serialization methods

2. Update `lib/widgets/import_track_segment_list.dart`:
   - Remove description display from list items
   - Adjust layout for simpler display

3. Update `lib/services/import_service.dart`:
   - Remove description-related logic
   - Update segment creation methods
   - Update segment management methods

## Feature 2: Import Track Options Dialog

### New Components

#### 1. ImportTrackOptionsDialog Widget
- Modal dialog for track import configuration
- Fields for:
  - Default segment name
  - Track direction (forward/backward)
- Cancel and Import buttons
- Form validation

#### 2. TrackImportOptions Model
- New model class to store import options
- Fields:
  - defaultSegmentName (String)
  - trackDirection (enum: forward/backward)

#### 3. TrackImportOptions Storage
- Store options in `ImportService` as a non-static field
- Options are associated with the current GPX file only
- Options are reset when:
  - A new file is selected for import
  - The app is restarted

### Implementation Steps

#### 1. Create New Files
1. Create `lib/models/track_import_options.dart`:
   ```dart
   enum TrackDirection { forward, backward }
   
   class TrackImportOptions {
     final String defaultSegmentName;
     final TrackDirection trackDirection;
     
     TrackImportOptions({
       required this.defaultSegmentName,
       required this.trackDirection,
     });
   }
   ```

2. Create `lib/widgets/import_track_options_dialog.dart`:
   - Implement dialog UI
   - Form validation
   - Cancel/Proceed handling

#### 2. Update ImportService
1. Add methods to:
   - Show import options dialog
   - Store selected options
   - Apply options during track import

2. Update track import workflow:
   - Show dialog before file processing
   - Cancel import if dialog is cancelled
   - Apply options during import if proceeding

#### 3. Update ImportTrackTopPanel
1. Modify file opening logic to:
   - Show options dialog after file selection
   - Only proceed with import if dialog is confirmed
   - Store selected options for future use

## UI/UX Guidelines

### Import Track Options Dialog
- Use native macOS dialog styling
- Clear, concise labels
- Default values for all fields
- Proper keyboard navigation
- Clear button labels

### Segment List
- Simplified layout
- Clear segment names
- Maintain existing delete functionality
- Consistent macOS styling

## Success Criteria
- [ ] Segment model simplified (no descriptions)
- [ ] Segment list updated to show only names
- [ ] Import options dialog appears after file selection
- [ ] Dialog properly captures segment name and direction
- [ ] Import cancelled if dialog cancelled
- [ ] Options stored for future use
- [ ] UI follows macOS guidelines
- [ ] All existing functionality maintained

## Testing Plan
1. Test segment model changes:
   - Verify segment creation without descriptions
   - Check segment list display
   - Verify segment management functions

2. Test import options dialog:
   - Verify dialog appearance
   - Test form validation
   - Check cancel behavior
   - Verify options storage
   - Test with various input values

3. Integration testing:
   - Full import workflow
   - Option persistence
   - Error handling
   - UI consistency

## Notes
- Maintain backward compatibility with existing segments
- Consider future use of stored options
- Keep UI clean and minimal
- Follow macOS design guidelines
- Document any API changes 