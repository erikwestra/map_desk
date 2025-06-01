# MapDesk v014 Implementation Plan: Segment Library

## Overview
Implement a segment library interface that allows users to view, manage, and manipulate segments. The interface will feature a sidebar with an alphabetical list of segments and a main map view showing the currently selected segment.

## Code Organization

### Directory Structure
```
lib/
├── core/
│   └── models/
│       └── segment.dart          # Existing segment model
├── modes/
│   └── segment_library/         # Main segment library module
│       ├── segment_library.dart # Entry point and exports
│       ├── services/           # Business logic
│       │   └── segment_library_service.dart
│       ├── screens/            # UI screens
│       │   └── segment_library_screen.dart
│       └── widgets/            # Reusable components
│           ├── segment_library_list.dart
│           ├── segment_library_map.dart
│           └── segment_library_toolbar.dart
```

### Module Integration
- The segment library will be implemented as a module in `lib/modes/segment_library/`
- Existing placeholder screen will be replaced with full implementation
- Module will be self-contained with clear public API
- Will integrate with existing map and database infrastructure
- Will use existing core models from `lib/core/models/`

### SegmentLibraryService Responsibilities
- Fetch and maintain alphabetical list of segments
- Manage currently selected segment state
- Handle segment deletion with proper UI feedback
- Coordinate segment edits and updates
- Provide segment data to map view
- Handle error states

## UI Components

### Main Layout
- Split view with resizable sidebar (left) and map area (right)
- Sidebar width: 300px by default, resizable
- Map area fills remaining space

### Sidebar
- Alphabetical list of segments
- Each segment entry shows:
  - Segment name
  - Visual indicator for selected state
- Scrollable list with smooth scrolling

### Map Area
- Full map view showing selected segment
- Segment displayed with:
  - Primary line in system blue
  - Direction arrows along the path
  - Start/end markers

### Toolbar
Positioned above map, includes:
- Delete segment button (trash icon)
- Edit segment button (pencil icon)

## Implementation Steps

1. **Data Layer**
   - Use existing Segment model from `lib/core/models/segment.dart`
   - Implement SegmentLibraryService in `lib/modes/segment_library/services/` with:
     - Methods for fetching alphabetical segment list
     - Selected segment state management
     - Delete segment with confirmation
     - Edit segment details
     - Error handling and loading states
   - Implement segment management operations using existing database tables

2. **UI Components**
   - Replace placeholder in `lib/modes/segment_library/screens/`
   - Create SegmentLibraryScreen widget
   - Implement resizable sidebar
   - Build segment library list widget in `lib/modes/segment_library/widgets/`
   - Create segment library map view
   - Implement segment library toolbar with action buttons

3. **State Management**
   - Use SegmentLibraryService as the single source of truth
   - Implement segment selection logic
   - Handle segment deletion
   - Handle segment editing
   - Manage loading and error states

4. **Map Integration**
   - Extend BaseMapView for segment library map
   - Implement segment rendering on map
   - Add direction arrows
   - Show start/end markers
   - Handle map interactions

5. **User Interactions**
   - Implement segment selection
   - Add segment deletion confirmation
   - Create segment edit dialog

## Success Criteria

1. **Data**
   - [ ] CRUD operations working correctly
   - [ ] Data integrity maintained

2. **UI**
   - [ ] Sidebar displays alphabetical segment list
   - [ ] Map shows selected segment correctly
   - [ ] Toolbar buttons functional
   - [ ] Resizable sidebar works
   - [ ] Smooth scrolling in segment list

3. **Functionality**
   - [ ] Segment selection works
   - [ ] Segment deletion works with confirmation
   - [ ] Segment editing saves changes
   - [ ] Map updates with segment changes

4. **Performance**
   - [ ] Smooth scrolling with large segment lists
   - [ ] Responsive map updates
   - [ ] Efficient database queries
   - [ ] Memory usage optimized

## Technical Notes

### State Management
- Use Provider pattern for state management
- Implement proper error handling
- Handle edge cases (no segments, failed operations)

### Map Rendering
- Use efficient polyline rendering
- Implement proper zoom levels for segment view
- Handle map bounds updates
- Optimize marker placement

### Database Operations
- Use transactions for multi-step operations
- Implement proper indexing
- Handle concurrent operations
- Maintain data consistency

### UI/UX Considerations
- Follow macOS design guidelines
- Implement proper keyboard shortcuts
- Provide visual feedback for actions
- Handle error states gracefully 