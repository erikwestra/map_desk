# MapDesk v008 Changelog

## Overview
Version 008 focuses on two main features:
1. Simplifying the segment data model by removing descriptions
2. Adding an "Import Track Options" modal dialog for GPX file import configuration

## Implementation Details

### Data Model Changes

#### Segment Model (`app/lib/models/segment.dart`)
- Removed `description` field from `Segment` class
- Updated constructor and factory methods
- Simplified serialization methods
- Maintained backward compatibility with existing segments

#### New TrackImportOptions Model (`app/lib/models/track_import_options.dart`)
```dart
enum TrackDirection { forward, backward }

class TrackImportOptions {
  final String defaultSegmentName;
  final TrackDirection trackDirection;
  
  // Constructor and factory methods
  // copyWith method for immutable updates
}
```

### Database Changes

#### Database Migration (`app/lib/services/database_service.dart`)
- Incremented database version from 1 to 2
- Added migration to remove description field:
  1. Create new table without description
  2. Copy existing data
  3. Drop old table
  4. Rename new table
- Preserved all existing segment data

### UI Components

#### Import Track Options Dialog (`app/lib/widgets/import_track_options_dialog.dart`)
- Modal dialog for configuring track import
- Fields:
  - Default segment name (text input)
  - Track direction (radio buttons: forward/backward)
- Form validation
- Cancel/Import buttons
- macOS-native styling

#### Segment Splitter (`app/lib/widgets/segment_splitter.dart`)
- Simplified segment creation dialog
- Removed description field
- Maintained existing point selection functionality
- Clean, minimal interface

#### Import Track Segment List (`app/lib/widgets/import_track_segment_list.dart`)
- Updated to show only segment name and info
- Removed description display
- Maintained delete functionality
- Consistent macOS styling

#### Import Track Top Panel (`app/lib/widgets/import_track_top_panel.dart`)
- Added import options dialog integration
- Shows dialog after file selection
- Applies options before track import
- Maintains existing file handling

### Service Layer

#### Import Service (`app/lib/services/import_service.dart`)
- Added `TrackImportOptions` support
- New methods:
  - `setImportOptions()`
  - `get importOptions`
- Maintains options state
- Resets options on track clear

## File Structure
```
app/
├── lib/
│   ├── models/
│   │   ├── segment.dart              # Updated segment model
│   │   └── track_import_options.dart # New import options model
│   ├── services/
│   │   └── database_service.dart     # Updated with migration
│   └── widgets/
│       ├── import_track_options_dialog.dart  # New dialog
│       ├── import_track_segment_list.dart    # Updated list
│       ├── import_track_top_panel.dart       # Updated panel
│       └── segment_splitter.dart             # Updated splitter
└── docs/
    └── v008-changelog.md             # This changelog
```

## UI/UX Changes

### Import Workflow
1. User selects GPX file
2. Import options dialog appears
3. User configures:
   - Default segment name
   - Track direction
4. Track is imported with selected options
5. Segments can be created with simplified interface

### Visual Changes
- Removed description fields from all segment-related UI
- Added new import options dialog
- Maintained consistent macOS styling
- Clean, minimal interface throughout

## Technical Implementation

### Database Migration
- Version increment: 1 → 2
- Migration handles existing data
- Preserves all segment information
- No data loss during upgrade

### State Management
- Import options stored in `ImportService`
- Options persist during import session
- Reset on track clear
- Provider pattern for state updates

### Error Handling
- Form validation in options dialog
- Graceful cancellation
- Data preservation during migration
- Clear user feedback

## Testing Coverage
- Database migration
- Import options persistence
- Segment creation workflow
- UI component updates
- Error scenarios
- Data integrity 