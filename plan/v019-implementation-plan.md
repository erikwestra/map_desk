# v019 Implementation Plan

## Overview
v019 adds mode-specific menus to the application menu bar, providing context-sensitive actions for each mode. The menus are dynamically created based on the current application mode.

## File Structure
```
app/
├── lib/
│   ├── modes/
│   │   ├── map/
│   │   │   └── menus/
│   │   │       └── map_menu.dart         # Map mode menu items
│   │   ├── import_track/
│   │   │   └── menus/
│   │   │       └── import_menu.dart      # Import mode menu items
│   │   ├── segment_library/
│   │   │   └── menus/
│   │   │       └── segment_menu.dart     # Segment library menu items
│   │   └── route_builder/
│   │       └── menus/
│   │           └── route_menu.dart       # Route builder menu items
│   └── shared/
│       └── menus/
│           └── mode_menu_builder.dart    # Menu builder utility
```

## Implementation Details

### Mode Menu Builder
- Create a utility class to build mode-specific menus
- Implement a method to get the appropriate menu based on current mode
- Handle menu item creation and event handling
- Support keyboard shortcuts for menu items

### Mode-Specific Menus

#### Map Menu
- Label: "Map"
- Menu Items:
  - "Load GPX Track"
    - Action: Open file picker for GPX files
    - Shortcut: ⌘O
    - Note: Replaces "Open" command from File menu

#### Import Menu
- Label: "Import"
- Menu Items:
  - "Load GPX Track"
    - Action: Open file picker for GPX files
    - Shortcut: ⌘O
    - Note: Replaces "Open" button in track importer

#### Segment Menu
- Label: "Segment"
- Menu Items:
  - "Edit Segment"
    - Action: Edit currently selected segment
    - Shortcut: ⌘E
    - Note: Replaces pencil icon in segment library
    - Enabled only when a segment is selected

#### Route Menu
- Label: "Route"
- Menu Items:
  - "Save Track"
    - Action: Save current track as GPX
    - Shortcut: ⌘S
    - Note: Replaces Save Track button in status bar
    - Enabled only when track has segments
  - "Clear"
    - Action: Clear current track
    - Shortcut: ⌘⌫
    - Note: Replaces Clear button in status bar
    - Enabled only when track has segments

### Menu Integration
- Update `main.dart` to use the mode menu builder
- Add mode-specific menu to the right of the "Mode" menu
- Remove File menu (functionality moved to Map menu)
- Update UI to remove redundant buttons:
  - Remove Open button from track importer
  - Remove pencil icon from segment library
  - Remove Save Track and Clear buttons from route builder status bar
- Ensure proper menu state management

## Technical Approach

### Menu Creation Strategy
- Create menus dynamically based on current mode
- Use a factory pattern to generate appropriate menu items
- Maintain clean separation between menu definition and action handling
- Support for future menu item additions

### State Management
- Use existing `ModeService` to determine current mode
- Implement menu state updates through provider pattern
- Ensure proper menu updates on mode changes
- Handle menu item enabled/disabled states based on context

### Menu Item Actions
- Define action handlers for each menu item
- Implement proper error handling
- Provide user feedback for actions
- Support keyboard shortcuts
- Maintain existing functionality while moving to menu-based approach

## Success Criteria
- Mode-specific menus appear correctly
- Menu items respond to user interaction
- Keyboard shortcuts work as expected
- Menu state updates properly with mode changes
- Menu items are enabled/disabled appropriately
- Existing functionality works through menu items
- UI is cleaner with redundant buttons removed
- Clean, maintainable code structure
- No impact on existing functionality

## Dependencies
- No new external dependencies required
- Uses existing:
  - Flutter platform menu system
  - Provider for state management
  - Existing mode service
  - File picker functionality
  - GPX handling services 