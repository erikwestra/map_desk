# MapDesk v023 Implementation Plan

## Overview
This version focuses on improving the user experience of the segment library and track import functionality with three key enhancements:
1. Auto-focus on segment name field in both segment edit dialog and segment options dialog
2. Re-openable segment options dialog during track import
3. Search filter for segment library with Return/Enter key activation

## Implementation Steps

### 1. Auto-focus Segment Name Field
- Modify both the segment edit dialog (in segment library) and segment options dialog (in track importer) to automatically focus the name field when opened
- Use Flutter's `autofocus` property on the TextField widget in both dialogs
- Ensure the keyboard appears automatically on desktop for both dialogs
- Test focus behavior with keyboard navigation in both contexts
- Maintain consistent focus behavior across both dialogs

### 2. Re-openable Segment Options Dialog
- Add a gear icon button next to the file name in the track import view using Flutter's `IconButton`
- Use the appropriate gear icon from Material Icons
- Connect the button to the existing segment options dialog
- Style the button to match macOS design guidelines
- Ensure the button is properly aligned with the file name
- Add hover effects for better user feedback

### 3. Segment Library Search Filter
- Add a search TextField above the segment list
- Implement filtering when user presses Return/Enter key
- Create a new `SegmentSearchField` widget
- Add clear button to reset search
- Style the search field to match macOS design
- Ensure proper keyboard navigation between search and list
- Implement case-insensitive search
- Add visual feedback when no results are found
- Add visual indicator that Return/Enter is needed to search

## UI Changes

### Segment Edit Dialog and Segment Options Dialog
- Add `autofocus: true` to the name TextField in both dialogs
- Ensure proper keyboard focus management in both contexts
- Maintain consistent focus behavior between both dialogs

### Track Import View
- Add gear icon button next to file name using `IconButton`
- Implement proper spacing and alignment
- Add tooltip to explain button function
- Style button with macOS-appropriate hover effects

### Segment Library
- Add search field at the top of the list
- Style with macOS-appropriate appearance
- Add clear button (x) when text is entered
- Show "No results found" message when appropriate
- Add visual indicator that Return/Enter is needed to search
- Style the search field to indicate it's a search input

## Success Criteria
- [ ] Segment name field automatically focuses when either dialog opens
- [ ] Focus behavior is consistent between both dialogs
- [ ] Keyboard appears automatically in both contexts
- [ ] Gear icon appears next to file name in track import view
- [ ] Clicking gear icon re-opens segment options dialog
- [ ] Search field appears above segment list
- [ ] Search filters segments only when Return/Enter is pressed
- [ ] Search is case-insensitive
- [ ] Clear button resets search
- [ ] Search field indicates Return/Enter is needed to search
- [ ] All UI elements follow macOS design guidelines
- [ ] Keyboard navigation works properly throughout
- [ ] No regression in existing functionality

## Technical Notes
- Use Flutter's built-in focus management consistently across both dialogs
- Use standard Flutter widgets (`IconButton`) for the gear icon
- Implement proper state management for search filter
- Handle Return/Enter key press in search field
- Ensure smooth performance with large segment lists
- Follow macOS HIG for icon and button styling
- Maintain existing keyboard shortcuts 