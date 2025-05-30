# MapDesk v009 Changelog

## Overview
Version 009 implements the track import and segment creation workflow, allowing users to load GPX tracks and create segments by selecting endpoints. The implementation includes a clean separation of concerns between services, widgets, and models.

## File Structure
```
app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   ├── simple_gpx_track.dart # Basic GPX track model
│   │   ├── splittable_gpx_track.dart # Track with selection support
│   │   ├── segment.dart         # Segment model
│   │   └── segment_import_options.dart # Segment creation options
│   ├── services/
│   │   ├── gpx_service.dart     # GPX file parsing
│   │   └── import_service.dart  # Track import and segment creation
│   ├── widgets/
│   │   ├── import_map_view.dart # Main import screen
│   │   ├── import_track_top_panel.dart # Top control panel
│   │   └── import_segment_options_dialog.dart # Segment options dialog
│   └── screens/
│       └── home_screen.dart     # Main app screen
```

## Implementation Details

### Models

#### SimpleGpxTrack
- Basic GPX track model with name, description, and points
- Used for initial track loading and parsing

#### SplittableGpxTrack
- Extends SimpleGpxTrack with selection capabilities
- Tracks start and end point indices
- Manages selected points for segment creation

#### Segment
- Represents a created segment with:
  - Name and number
  - Direction (one-way/bidirectional)
  - Start and end points
  - Track points

#### SegmentImportOptions
- Configuration for segment creation:
  - Segment name
  - Direction (one-way/bidirectional)
- Includes default values and copy functionality

### Services

#### ImportService
- Manages the track import workflow
- Handles track loading and clearing
- Manages segment creation state
- Tracks current segment number
- Provides status messages
- Controls map view and zoom
- Manages segment list

Key features:
- State management (noFile, fileLoaded, endpointSelected, segmentSelected)
- Segment number tracking and incrementing
- Status message updates
- Track point selection
- Map bounds and zoom control

### Widgets

#### ImportMapView
- Main import screen widget
- Displays track and segments
- Handles point selection
- Shows status messages
- Manages map interaction

#### ImportTrackTopPanel
- Top control panel for import screen
- Shows track information
- Provides clear and reset buttons
- Displays current status

#### ImportSegmentOptionsDialog
- Dialog for segment creation options
- Configures segment name
- Sets segment direction
- Returns updated options

## User Interface

### Import Screen Layout
- Full-screen map view
- Top panel with controls and status
- Track points displayed as circles
- Selected points highlighted in blue
- Unselected points shown in red
- Endpoints marked with green circles

### Interaction Flow
1. Load GPX track
2. Select first endpoint
3. Configure segment options
4. Select second endpoint
5. Create segment
6. Repeat for additional segments

### Status Messages
- No file: Empty
- File loaded: "Click on one end of the track to start splitting"
- Endpoint selected: "Click on endpoint to create segment [name] [number]"
- Segment selected: "Creating segment [name] [number]"

## Technical Details

### State Management
- Uses ChangeNotifier for state updates
- Tracks import state and options
- Manages segment list
- Updates UI through notifications

### Map Integration
- Uses flutter_map for map display
- Manages map controller
- Handles bounds and zoom
- Supports point selection

### Segment Creation
- Supports one-way and bidirectional segments
- Tracks segment numbers
- Maintains segment list
- Preserves track data

### Error Handling
- Graceful track loading
- Valid point selection
- State transition management
- Map controller error recovery 