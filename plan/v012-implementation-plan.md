# MapDesk v012 Implementation Plan

## Overview
Version v012 focuses on reorganizing the UI panels to improve the user experience and information hierarchy. The main changes involve:
1. Moving the import track status information to a bottom status bar
2. Creating a new filename panel in the upper-right corner
3. Reorganizing controls and information display

## UI Changes

### 1. Import Track Status Bar (Formerly Top Panel)
- **Location**: Bottom of the screen
- **Purpose**: Display current state of track processing, including import progress and segment splitting status
- **Components**:
  - Status text display
  - Action buttons
  - Error message display (when applicable)
- **Behavior**:
  - Always visible
  - Updates to show current processing state
  - Displays error messages when needed
  - Shows segment splitting progress and results

### 2. Import Track Filename Panel (New)
- **Location**: Upper-right corner, above segment list
- **Purpose**: Display current track file information and controls
- **Components**:
  - Filename display
  - Close button
  - Information button
- **Layout**:
  - Horizontal arrangement
  - Right-aligned
  - Compact design
  - Same width as segment list
- **Styling**:
  - Light background
  - Subtle border
  - System-appropriate padding

### 3. Segment List Adjustments
- **Changes**:
  - Move down slightly to accommodate new filename panel
  - Maintain existing functionality

## Implementation Steps

1. **Create New Filename Panel Widget**
   ```dart
   class ImportTrackFilenamePanel extends StatelessWidget {
     final String filename;
     final VoidCallback onClose;
     final VoidCallback onInfo;
     
     // Implementation details...
   }
   ```

2. **Modify Status Bar Widget**
   - Rename from `ImportTrackTopPanel` to `ImportTrackStatusBar`
   - Update positioning logic
   - Adjust animations for bottom placement

3. **Update Main Layout**
   - Add new filename panel to upper-right
   - Move status bar to bottom
   - Adjust segment list positioning

4. **State Management Updates**
   - Update provider/state management to handle new panel
   - Ensure proper state propagation
   - Maintain existing functionality

## Success Criteria

- [ ] Status bar appears at bottom of screen
- [ ] Filename panel appears in upper-right
- [ ] All controls function correctly
- [ ] Layout adjusts properly to window size
- [ ] No regression in existing functionality
- [ ] Smooth transitions between states
- [ ] Proper error handling maintained

## Dependencies
- No new external dependencies required
- Uses existing Flutter widgets and patterns

## Notes
- Maintain existing error handling
- Keep consistent with macOS design guidelines
- Ensure accessibility features are maintained
- Document any new patterns or approaches 