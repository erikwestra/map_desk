# MapDesk v024 Implementation Plan

## Overview
Version v024 implements a unified window interface with a three-panel layout: a left sidebar for the segment library, a central map view, and a right sidebar for route builder options. The content of each panel changes contextually based on the current mode, but their positions remain constant. A status bar at the bottom provides additional information and controls.

## Window Layout
```
+------------------+--------------------------------------------------+------------------+
|                  |                                                  |                  |
|   Segment        |                                                  |   Route          |
|   Library        |                      Map                         |   Builder        |
|   Sidebar        |                                                  |   Sidebar        |
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
  - Visible in Import and Browse modes
  - Hidden in View and Create modes
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

### Right Sidebar (Route Builder)
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
    - Import: Track import and segment creation (left sidebar visible)
    - Browse: Segment library browsing (left sidebar visible)
    - Create: Route creation mode (right sidebar only)
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

### 1. Layout Management
- Implement responsive layout system
- Handle sidebar visibility based on current mode
- Maintain panel proportions
- Support window resizing
- Smooth transitions when showing/hiding sidebars

### 2. Mode Management
- Track current application mode
- Update panel content based on mode
- Maintain state between mode changes
- Handle mode transitions
- Implement mode selector in status bar
- Sync mode state between menu and status bar
- Control sidebar visibility based on mode

### 3. Panel Communication
- Real-time updates between panels
- State synchronization
- Event handling
- Data flow management

## File Structure
```
app/
├── lib/
│   ├── core/
│   │   ├── services/
│   │   │   ├── layout_service.dart
│   │   │   └── mode_service.dart
│   │   └── models/
│   │       └── app_state.dart
│   ├── widgets/
│   │   ├── left_sidebar.dart
│   │   ├── right_sidebar.dart
│   │   ├── map_view.dart
│   │   └── status_bar.dart
│   └── modes/
│       ├── segment_library/
│       ├── import_track/
│       └── route_builder/
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

## Dependencies
- `provider`