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
  - "Reset View" (placeholder)
    - Action: Reset map to default view
    - Shortcut: ⌘R

#### Import Menu
- Label: "Import"
- Menu Items:
  - "Import File" (placeholder)
    - Action: Open file picker
    - Shortcut: ⌘I

#### Segment Menu
- Label: "Segment"
- Menu Items:
  - "New Segment" (placeholder)
    - Action: Create new segment
    - Shortcut: ⌘N

#### Route Menu
- Label: "Route"
- Menu Items:
  - "New Route" (placeholder)
    - Action: Start new route
    - Shortcut: ⌘N

### Menu Integration
- Update `main.dart` to use the mode menu builder
- Add mode-specific menu to the menu bar
- Position menu to the right of the "Mode" menu
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

### Menu Item Actions
- Define action handlers for each menu item
- Implement proper error handling
- Provide user feedback for actions
- Support keyboard shortcuts

## Success Criteria
- Mode-specific menus appear correctly
- Menu items respond to user interaction
- Keyboard shortcuts work as expected
- Menu state updates properly with mode changes
- Clean, maintainable code structure
- No impact on existing functionality

## Dependencies
- No new external dependencies required
- Uses existing:
  - Flutter platform menu system
  - Provider for state management
  - Existing mode service 