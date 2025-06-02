# MapDesk v024 Implementation Plan

## Overview
Version v024 implements a multi-window architecture for MapDesk, allowing users to work with different modes (Segment Library, Import Track, Route Builder, and Map View) in separate windows. This enhances productivity by enabling simultaneous access to different features.

## Menu Structure
```
MapDesk (Application Menu)
├── About MapDesk
└── Quit                    ⌘Q

File
├── Open                    ⌘O
└── Close Window           ⌘W

Edit
├── Undo                    ⌘Z
└── Clear Track             ⌘⌫

Database
├── Reset Database
├── ──────────────────────
├── Export Segments
└── Import Segments

Window
├── Segment Library         ⌘1
├── Import Track            ⌘2
├── Route Builder           ⌘3
└── Map View                ⌘4
```

## Implementation Details

### 1. Window Management Service
- Create `WindowManager` service using the `window_manager` package to:
  - Create and manage separate windows for each mode
  - Handle window show/hide operations from the menu
  - Ensure windows maintain their state when hidden/shown

### 2. Window Types
- **Segment Library Window**
  - Default window on app launch
  - Uses existing functionality from `lib/modes/segment_library/screens/segment_library_screen.dart`
  - No changes to core functionality
  - Simply moved into its own window

- **Import Track Window**
  - Dedicated window for track import
  - Uses existing functionality from `lib/modes/import_track/screens/import_track_screen.dart`
  - No changes to core functionality
  - Simply moved into its own window

- **Route Builder Window**
  - Route creation interface
  - Uses existing functionality from `lib/modes/route_builder/screens/route_builder_screen.dart`
  - No changes to core functionality
  - Simply moved into its own window

- **Map View Window**
  - Map visualization
  - Uses existing functionality from `lib/modes/map_view/screens/map_view_screen.dart`
  - No changes to core functionality
  - Simply moved into its own window

### 3. Window Communication
- New segments created in the track importer are shown immediately in the segment library

## File Structure
```
app/
├── lib/
│   ├── core/
│   │   └── services/
│   │       └── window_manager.dart
│   └── windows/
│       ├── segment_library/    # existing functionality copied from lib/modes/segment_library
│       ├── import_track/       # existing functionality copied from lib/modes/import_track
│       ├── route_builder/      # existing functionality copied from lib/modes/route_builder
│       └── map_view/          # existing functionality copied from lib/modes/map_view
```

## Success Criteria
- [ ] App launches with Segment Library window
- [ ] All windows can be opened from menu
- [ ] Windows maintain state when hidden/shown
- [ ] Windows communicate state changes
- [ ] Database operations work across windows
- [ ] Keyboard shortcuts work as specified
- [ ] All windows maintain proper state

## Dependencies
- `window_manager` for window control
- `provider` for state management

## Notes
- Focus on native macOS window behavior
- Maintain clean separation between windows
- Ensure robust state management
- Prioritize user experience
 