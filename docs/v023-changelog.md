# MapDesk v023 Changelog

## Overview
Version v023 focuses on improving the user experience of the segment library and track import functionality with three key enhancements:
1. Auto-focus on segment name field in both segment edit dialog and segment options dialog
2. Re-openable segment options dialog during track import
3. Search filter for segment library with Return/Enter key activation

## Implementation Details

### 1. Auto-focus Segment Name Field
- Modified both dialogs to automatically focus the name field when opened:
  - `ImportTrackOptionsDialog` in import track mode
  - `SegmentLibraryEditDialog` in segment library mode
- Added `autofocus: true` to the name TextField in both dialogs
- Ensured consistent focus behavior between both dialogs
- Keyboard appears automatically in both contexts

### 2. Re-openable Segment Options Dialog
- Added gear icon button next to file name in track import view
- Modified `ImportService.showSegmentOptionsDialog()` to allow showing dialog regardless of segment name state
- Added tooltip to explain button function
- Styled button with macOS-appropriate hover effects
- Properly aligned button with file name
- Integrated with existing segment options functionality

### 3. Segment Library Search Filter
- Added search TextField above segment list in `SegmentLibraryList`
- Implemented filtering when user presses Return/Enter key
- Added clear button to reset search
- Styled search field to match macOS design:
  - Rounded corners (20px radius)
  - Light gray text and icons
  - Minimal "Search" label
  - Clear button appears when text is entered
- Implemented case-insensitive search
- Added visual feedback when no results are found
- Added visual indicator that Return/Enter is needed to search

### File Structure
```
app/
├── lib/
│   ├── modes/
│   │   ├── import_track/
│   │   │   ├── services/
│   │   │   │   └── import_service.dart         # Track import workflow management
│   │   │   ├── widgets/
│   │   │   │   ├── import_track_options_dialog.dart  # Segment options dialog
│   │   │   │   └── import_track_selection_panel.dart # File/segment selection panel
│   │   │   └── models/
│   │   │       └── segment_import_options.dart # Import options model
│   │   └── segment_library/
│   │       ├── services/
│   │       │   └── segment_library_service.dart # Segment library state management
│   │       └── widgets/
│   │           ├── segment_library_list.dart    # Segment list with search
│   │           └── segment_library_edit_dialog.dart # Segment edit dialog
│   └── core/
│       └── models/
│           └── segment.dart                    # Segment data model
```

### Screen Structure
- **Import Track Mode**
  - Left panel: File and segment selection with gear icon for options
  - Main area: Map view for track visualization
  - Bottom: Status bar with segment creation controls

- **Segment Library Mode**
  - Left panel: Search field and segment list
  - Main area: Map view for segment visualization
  - Bottom: Status bar with segment management controls

### Widget Hierarchy
```
ImportTrackView
├── ImportTrackSelectionPanel
│   └── ListTile (with gear icon)
├── ImportTrackMapView
└── ImportTrackStatusBar

SegmentLibraryScreen
├── SegmentLibraryList
│   ├── TextField (search)
│   └── ListView (segments)
├── SegmentLibraryMap
└── StatusBar
```

### Service Architecture
- **ImportService**
  - Manages track import workflow
  - Handles segment creation and options
  - Maintains track and segment state
  - Provides map control functionality

- **SegmentLibraryService**
  - Manages segment library state
  - Handles segment CRUD operations
  - Provides segment filtering and selection

### Data Models
- **SegmentImportOptions**
  - `segmentName`: String
  - `direction`: SegmentDirection (oneWay/bidirectional)
  - `nextSegmentNumber`: int

- **Segment**
  - `name`: String
  - `direction`: String
  - `points`: List<SegmentPoint>
  - `id`: String

### UI/UX Improvements
- Consistent focus behavior across dialogs
- Improved segment options accessibility
- Enhanced segment search functionality
- macOS-native styling and interactions
- Clear visual feedback for user actions 