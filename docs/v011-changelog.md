# MapDesk v011 Changelog

## Overview
Version v011 enhances the segment mode functionality with improved UI and interaction patterns. The implementation focuses on a cleaner interface for segment management and more intuitive track splitting workflow.

## File Structure
```
app/
├── lib/
│   ├── models/
│   │   ├── segment.dart              # Segment data model with direction field
│   │   └── splittable_gpx_track.dart # Track splitting functionality
│   ├── services/
│   │   └── import_service.dart       # Import workflow and segment management
│   └── widgets/
│       ├── import_track_segment_list.dart  # Segment list display
│       └── import_track_top_panel.dart     # Top control panel
```

## Implementation Details

### Models
- **Segment Model**
  - Added direction field ('oneWay' or 'bidirectional')
  - Enhanced JSON serialization for direction
  - Improved point handling and validation

- **SplittableGpxTrack**
  - Added `removePointsUpTo` method for segment deletion
  - Enhanced point selection and management
  - Improved track splitting functionality

### Services
- **ImportService**
  - Enhanced segment creation with direction support
  - Improved segment deletion workflow
  - Added status message management
  - Implemented track point removal after segment save/delete
  - Added state management for segment operations

### UI Components
- **ImportTrackTopPanel**
  - Added text-based Save and Delete buttons
  - Implemented Options button with icon
  - Added status display with right alignment
  - Improved button spacing and layout

- **ImportTrackSegmentList**
  - Simplified segment display to show only names
  - Added dividers between list items
  - Optimized vertical spacing
  - Removed delete functionality from list items

## User Interface
- **Top Panel**
  - Status message right-aligned with 10px gap to buttons
  - Text buttons for Save and Delete actions
  - Icon button for Options
  - Clean, minimal design

- **Segment List**
  - Simple list of segment names
  - Thin dividers between items
  - Compact vertical spacing
  - No delete functionality in list

## Workflow
1. User loads GPX file
2. Selects start point of segment
3. Selects end point of segment
4. Can save segment (removes points from track)
5. Can delete segment (removes points from track)
6. Can modify segment options
7. Track updates to start from end of saved/deleted segment

## Technical Notes
- Segment deletion and saving use same point removal logic
- Track state maintained after segment operations
- Status messages update based on current operation
- Clean separation between UI and business logic 