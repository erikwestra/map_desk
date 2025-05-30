# MapDesk v006 Implementation Plan

## Overview
Add a "View" menu with four items and implement placeholder views for Segment Library and Route Builder features.

## Menu Structure
```
View
├── Map View              ⌘1
├── Import Track          ⌘2
├── Segment Library       ⌘3
└── Route Builder         ⌘4
```

## Implementation Tasks

### 1. Menu Integration
- Add "View" menu to PlatformMenuBar
- Implement keyboard shortcuts (⌘1-4)
- Add menu item handlers

### 2. View Management
- Create ViewState enum for tracking current view
- Implement view switching logic
- Add view state management to MapService

### 3. Placeholder Views
- Create basic placeholder widgets:
  - SegmentLibraryView
  - RouteBuilderView
- Add minimal UI elements:
  - Title header
  - "Coming soon" message
  - Basic layout structure

### 4. Navigation
- Implement view switching mechanism
- Handle view transitions

## Success Metrics
- [ ] View menu appears in menu bar
- [ ] All menu items respond to clicks
- [ ] Keyboard shortcuts work (⌘1-4)
- [ ] Placeholder views display correctly
- [ ] View switching works smoothly

## Dependencies
- No new external dependencies required

## Notes
- Keep placeholder views minimal but professional
- Maintain consistent styling with existing UI
- Focus on clean navigation between views
- Prepare architecture for future feature implementation 