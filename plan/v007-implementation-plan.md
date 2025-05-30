# MapDesk v007 Implementation Plan

## Overview
Version 007 reorganizes the import track screen to include a top information panel and a right-side segment list, while maintaining the main map view. This version focuses on improving the user interface organization and file handling workflow.

## Screen Layout Changes

### Import Track Screen Structure
```
ImportTrackView
├── ImportTrackTopPanel
│   ├── FileInfo
│   │   ├── FileName (or "No file selected")
│   │   └── FileControls (Open/Close button)
└── MainContent
    ├── MapView (left side)
    │   ├── FlutterMap
    │   │   ├── TileLayer
    │   │   ├── PolylineLayer
    │   │   └── CircleLayer
    │   └── MapControls
    └── ImportTrackSegmentList (right side)
        └── Vertical list of segment names
```

## Implementation Details

### New Components

#### ImportTrackTopPanel Widget
- Horizontal panel spanning full width
- Contains file information and controls
- Shows "No file selected" when empty
- Displays filename when file is loaded
- Includes Open/Close button as needed

#### ImportTrackSegmentList Widget
- Vertical list on right side of screen
- Simple list of segment names
- Scrollable container
- Placeholder for future segment functionality

### File Handling Changes
- Remove automatic file picker on menu selection
- Add "Open..." button to top panel that:
  - Opens the file picker dialog
  - Filters for GPX files
  - Loads selected file into the map view
  - Updates the top panel to show filename
- Implement file close functionality
- Update file state management

### Layout Implementation
- Use Row/Column for main layout structure
- Implement proper constraints for panel sizes
- Ensure responsive layout behavior
- Maintain map view proportions

## Technical Requirements

### Widget Updates
- Modify `ImportTrackView` to support new layout
- Create new `ImportTrackTopPanel` widget
- Create new `ImportTrackSegmentList` widget
- Update existing map view constraints

### State Management
- Add file state tracking to ImportService
- Implement file open/close handlers
- Prepare segment list state structure
- Update view state management

### UI Components
- Implement consistent styling
- Use system fonts and colors
- Follow macOS design guidelines
- Maintain accessibility support

## Success Criteria
- [ ] Top panel displays correctly
- [ ] File state shows properly
- [ ] Open/Close controls work
- [ ] Segment list displays on right
- [ ] Map view maintains functionality
- [ ] Layout is responsive
- [ ] UI follows macOS guidelines

## Future Considerations
- Segment list item styling
- Segment selection handling
- Segment details display
- List item interactions
- Segment management features

## Notes
- Focus on layout structure first
- Keep segment list simple for now
- Maintain existing map functionality
- Prepare for future segment features 