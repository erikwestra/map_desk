# MapDesk v014 Changelog

## Overview
Version 014 implements a complete track import workflow with segment creation capabilities. The implementation includes a robust service layer for managing track data, segment creation, and database operations, along with a user-friendly interface for track visualization and segment selection.

## File Structure
```
app/
├── lib/
│   ├── main.dart                 # App entry point with provider setup
│   ├── core/
│   │   ├── models/
│   │   │   ├── segment.dart      # Segment data model
│   │   │   ├── simple_gpx_track.dart  # Basic GPX track model
│   │   │   └── splittable_gpx_track.dart  # Track model with selection support
│   │   └── services/
│   │       ├── database_service.dart  # SQLite database operations
│   │       ├── gpx_service.dart  # GPX file parsing
│   │       └── segment_service.dart  # Segment CRUD operations
│   ├── modes/
│   │   ├── import_track/
│   │   │   ├── models/
│   │   │   │   ├── segment_import_options.dart  # Import configuration
│   │   │   │   └── selectable_item.dart  # UI selection model
│   │   │   ├── services/
│   │   │   │   └── import_service.dart  # Track import workflow
│   │   │   └── widgets/
│   │   │       └── import_track_options_dialog.dart  # Segment options UI
│   │   └── segment_library/
│   │       └── services/
│   │           └── segment_library_service.dart  # Library state management
│   └── screens/
│       └── home_screen.dart      # Main app screen with menu bar
```

## Implemented Features

### Track Import Workflow
- GPX file loading with native file picker
- Track visualization on map
- Interactive segment selection with start/end points
- Segment creation with customizable options
- Duplicate segment name prevention
- Automatic segment library updates

### Database Integration
- SQLite database for segment storage
- JSON serialization for track points
- Unique constraint on segment names
- Automatic database initialization
- Efficient segment CRUD operations

### User Interface
- Native macOS menu bar integration
- Track visualization with Flutter Map
- Interactive segment selection
- Import options dialog
- Status messages and error handling
- Segment library integration

### Service Layer
- `ImportService`: Manages track import workflow
- `SegmentService`: Handles segment database operations
- `SegmentLibraryService`: Manages segment library state
- `DatabaseService`: Core database operations
- `GpxService`: GPX file parsing

### Models
- `Segment`: Core segment data structure
- `SimpleGpxTrack`: Basic GPX track representation
- `SplittableGpxTrack`: Track with selection capabilities
- `SegmentImportOptions`: Import configuration
- `SelectableItem`: UI selection model

## Technical Details

### Database Schema
```sql
CREATE TABLE segments (
  id TEXT PRIMARY KEY,
  name TEXT UNIQUE,
  points TEXT,
  created_at INTEGER,
  direction TEXT
)
```

### Key Features
1. **Track Import**
   - GPX file selection
   - Track parsing and validation
   - Map visualization
   - Interactive point selection

2. **Segment Creation**
   - Start/end point selection
   - Custom segment naming
   - Direction specification
   - Duplicate name prevention
   - Automatic library updates

3. **Map Interaction**
   - Track bounds calculation
   - Automatic zoom to track
   - Point selection
   - Segment visualization
   - Pan and zoom controls

4. **Error Handling**
   - File loading errors
   - Database operation errors
   - Duplicate name detection
   - User feedback via snackbars

5. **State Management**
   - Track import state
   - Segment selection state
   - Map controller state
   - Library refresh state

## UI Components

### Main Screen
- Map view with track visualization
- Segment selection interface
- Status message display
- Menu bar integration

### Import Options Dialog
- Segment name input
- Direction selection
- Segment number management
- Validation and error display

### Menu Structure
```
MapDesk
├── Quit                    ⌘Q

File
├── Open                    ⌘O
└── Reset Database

Window
└── MapDesk
```

## Dependencies
- `flutter_map`: Map visualization
- `latlong2`: Geographic coordinates
- `file_selector`: Native file picking
- `xml`: GPX parsing
- `sqflite`: Database operations
- `provider`: State management 