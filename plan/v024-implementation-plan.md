# MapDesk v024 Implementation Plan

## Overview
Version v024 implements a unified window interface with a three-panel layout: a left sidebar for the segment library, a central map view, and a right sidebar for route builder options. The content of each panel changes contextually based on the current mode, but their positions remain constant. A status bar at the bottom provides additional information and controls.

## Window Layout
```
+------------------+--------------------------------------------------+------------------+
|                  |                                                  |                  |
|   Segment        |                                                  |   Current        |
|   Library        |                      Map                         |     Route        |
|                  |                                                  |                  |
|                  |                                                  |                  |
|                  |                                                  |                  |
+------------------+--------------------------------------------------+------------------+
| Status message...                                       [View][Import][Browse][Create] |
+----------------------------------------------------------------------------------------+
```

## Panel Descriptions

### Left Sidebar (Segment Library)
- **Primary Purpose**: Display and manage track segments
- **Content**:
  - List of available segments
  - Segment details and metadata
  - Import controls (when in import mode)
  - Search and filter options
- **Behavior**:
  - Visible in Import, Browse, and Create modes
  - Hidden in View mode
  - Maintains state when hidden/shown
  - Updates in real-time during track import

### Central Map
- **Primary Purpose**: Visual display and interaction
- **Content**:
  - GPX track visualization
  - Import circles and track preview (import mode)
  - Route builder track (route mode)
  - Map controls and zoom
- **Behavior**:
  - Always visible
  - Updates based on current mode
  - Maintains view state between mode changes
  - Expands to fill available space when sidebars are hidden

### Right Sidebar (Current Route)
- **Primary Purpose**: Route creation and editing
- **Content**:
  - Route builder options
  - Segment selection controls
  - Route parameters
  - Generation controls
- **Behavior**:
  - Visible only in Create mode
  - Hidden in all other modes
  - Context-sensitive options
  - Updates based on selected segments

### Status Bar
- **Primary Purpose**: Information and controls
- **Layout**:
  - Left side: Status message and progress information
  - Right side: Mode selector (segmented control)
- **Mode Selector**:
  - Segmented control with four modes:
    - View: Basic map viewing mode (both sidebars hidden)
    - Import: Track import and segment creation (Segment Library sidebar visible)
    - Browse: Segment library browsing (Segment Library sidebar visible)
    - Create: Route creation mode (both sidebars visible)
  - Always visible
  - One-click mode switching
  - Clear visual indication of current mode
- **Status Message**:
  - Shows current operation status
  - Displays progress information
  - Provides feedback for user actions
  - Updates in real-time

## Menu Structure
```
MapDesk (Application Menu)
├── About MapDesk
└── Quit                    ⌘Q

File
├── Open                    ⌘O
└── Save Route             ⌘S

Edit
├── Undo                    ⌘Z
└── Clear Track             ⌘⌫

Mode
├── View Map               ⌘1
├── Import Track           ⌘2
├── Browse Segments        ⌘3
└── Create Route           ⌘4

Database
├── Reset Database
├── ──────────────────────
├── Export Segments
└── Import Segments
```

## Implementation Details

### 1. Mode Management (Strategy Pattern)
- **Mode Controller Interface**
  - Define common interface for all mode controllers
  - Handle mode-specific behavior
  - Manage mode-specific state
  - Provide content for shared layout components

- **Mode Controllers** (Replacing Mode-Specific Services)
  - **ViewModeController**
    - Handles basic map viewing
    - Manages map bounds and zoom
    - Controls map interaction behavior
    - Provides content for map view
    - No sidebars visible
    - Replaces functionality from map_service.dart

  - **ImportModeController**
    - Manages track import process
    - Provides content for segment library sidebar
    - Handles import-specific map interactions
    - Manages import circles and preview
    - Provides content for map view
    - Replaces functionality from import_service.dart

  - **BrowseModeController**
    - Manages segment library browsing
    - Provides content for segment library sidebar
    - Handles segment selection
    - Manages map display of selected segments
    - Provides content for map view
    - Replaces functionality from segment_library_service.dart

  - **CreateModeController**
    - Manages route creation
    - Provides content for current route sidebar
    - Handles route-specific map interactions
    - Manages route generation and editing
    - Provides content for map view
    - Replaces functionality from route_builder_service.dart

### 2. Shared Components
- **Map View**
  - Mode-agnostic map display
  - Delegates all interactions to current mode controller
  - Renders content provided by mode controller
  - Handles basic map operations (pan, zoom)

- **Segment Library Sidebar**
  - Mode-agnostic container
  - Displays content provided by mode controller
  - Handles basic layout and scrolling
  - Delegates interactions to mode controller

- **Current Route Sidebar**
  - Mode-agnostic container
  - Displays content provided by mode controller
  - Handles basic layout and scrolling
  - Delegates interactions to mode controller

### 3. State Management
- **App State**
  - Current mode
  - Mode-specific state
  - Shared state (map position, etc.)
  - User preferences

- **Mode State**
  - Each mode controller manages its own state
  - State persists during mode switches
  - Clean state transitions between modes

## File Structure
```
app/
├── lib/
│   ├── core/
│   │   ├── services/
│   │   │   ├── layout_service.dart
│   │   │   ├── mode_service.dart
│   │   │   └── app_state.dart
│   │   ├── interfaces/
│   │   │   └── mode_controller.dart
│   │   └── widgets/
│   │       ├── map_view.dart
│   │       ├── segment_library_sidebar.dart
│   │       ├── current_route_sidebar.dart
│   │       └── status_bar.dart
│   ├── modes/
│   │   ├── view/
│   │   │   ├── models/
│   │   │   │   └── view_state.dart
│   │   │   ├── view_mode_controller.dart    # Replaces map_service.dart
│   │   │   └── widgets/                     # ...current widgets in modes/map/widgets
│   │   ├── import/
│   │   │   ├── models/
│   │   │   │   ├── segment_import_options.dart
│   │   │   │   └── selectable_item.dart
│   │   │   ├── import_mode_controller.dart  # Replaces import_service.dart
│   │   │   └── widgets/                     # ...current widgets in modes/import_track/widgets
│   │   ├── browse/
│   │   │   ├── models/
│   │   │   │   └── browse_state.dart
│   │   │   ├── browse_mode_controller.dart  # Replaces segment_library_service.dart
│   │   │   └── widgets/                     # ...current widgets in modes/segment_library/widgets
│   │   └── create/
│   │       ├── models/
│   │       │   └── create_state.dart
│   │       ├── create_mode_controller.dart  # Replaces route_builder_service.dart
│   │       └── widgets/                     # ...current widgets in modes/route_builder/widgets
```

## Success Criteria
- [ ] Three-panel layout works correctly
- [ ] Sidebar visibility changes automatically with mode
- [ ] Content updates correctly in each mode
- [ ] State is maintained between mode changes
- [ ] Real-time updates work across panels
- [ ] Window resizing handles layout properly
- [ ] Keyboard shortcuts work as specified
- [ ] Status bar provides relevant information
- [ ] Mode transitions are smooth
- [ ] All panels maintain proper state
- [ ] Mode selector works correctly
- [ ] Status messages are clear and informative
- [ ] Mode-specific behavior is properly isolated
- [ ] Shared components remain mode-agnostic
- [ ] State management works correctly across mode switches

## Dependencies
- `provider` for state management
- `flutter_map` for map display
- `latlong2` for coordinate handling

## Notes
- Focus on native macOS behavior
- Maintain clean separation between modes
- Ensure robust state management
- Prioritize user experience
- Handle window resizing gracefully
- Preserve state across mode changes
- Follow macOS UI guidelines for segmented controls
- Sidebar visibility is mode-dependent, not user-controlled
- Use Strategy Pattern to isolate mode-specific logic
- Keep shared components mode-agnostic
- Implement clean interfaces between modes and shared components