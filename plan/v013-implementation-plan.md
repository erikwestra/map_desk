# MapDesk v013 Implementation Plan

## Overview
Version 013 of MapDesk implements unique segment name enforcement and enhanced import options, including the ability to set the next segment number. This version will require a database migration to enforce unique segment names and wipe existing segments.

## Database Changes

### Segment Table Migration
1. Create new segment table with unique name constraint
2. Drop existing segment table
3. Update database version number
4. Implement migration logic in DatabaseService

### Migration Steps
1. Create new table with unique constraint:
```sql
CREATE TABLE segments_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    track_id INTEGER NOT NULL,
    start_point_index INTEGER NOT NULL,
    end_point_index INTEGER NOT NULL,
    FOREIGN KEY (track_id) REFERENCES tracks(id)
);
```

2. Drop old table and rename new table
3. Update database version in DatabaseService
4. Add migration logic to handle the transition

## Import Options Dialog Updates

### UI Changes
1. Add "Next Segment Number" field to import options dialog
2. Add validation for segment number input
3. Update dialog layout to accommodate new field

### Functionality
1. Add next segment number to SegmentImportOptions model
2. Use next segment number from import options instead of current segment number from ImportService
3. Validate segment number input (must be positive integer)

### Segment Number Determination
1. When loading segment options dialog:
   - Query database for all segments with matching base name
   - Extract numbers from existing segment names
   - Set next segment number to highest existing number + 1
   - If no existing segments found, start with number 1
2. Update segment options dialog to show determined number
3. Allow user to override the determined number if desired

## Error Handling

### Duplicate Segment Names
1. Add validation before segment creation
2. Display error dialog when duplicate name detected
3. Show segment options dialog again to allow name changes
4. Keep existing segment name and number in dialog for reference

### Error Messages
1. "A segment with this name already exists"
2. "Please choose a different name for this segment"
3. "Segment names must be unique"

## Success Criteria
- [ ] Database migration successfully enforces unique segment names
- [ ] Existing segments are properly cleared during migration
- [ ] Import options dialog includes next segment number field
- [ ] Next segment number is automatically determined from existing segments
- [ ] Duplicate segment name errors are clearly displayed
- [ ] All error messages are user-friendly and actionable
- [ ] Database version is properly incremented

## Implementation Notes
- Test migration with various database states
- Verify segment number determination works with various naming patterns
- Validate error handling with various edge cases
- Ensure UI remains responsive during database operations 