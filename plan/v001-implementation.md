# MapDesk MVP Plan

## Project Overview

MapDesk is a minimal desktop mapping application for macOS that focuses on **GPX data visualization and basic map interaction**. Following the philosophy of "content is central" from the project exploration, this MVP prioritizes **map data and GPX tracks** over complex features.

## 🌟 North Star Purpose

To create a focused, distraction-free desktop mapping application that allows users to:
- View interactive maps
- Load and visualize GPX tracks
- Perform basic map navigation

The MVP is deliberately minimal, designed for iterative expansion, and focused on core mapping functionality.

## 🧠 Design Philosophy

- **Map data is central** — the platform revolves around geographic visualization
- **Minimalism by default** — no complex UI, social features, or unnecessary widgets
- **Clarity over complexity** — clean, intuitive map interaction
- **Desktop-first** — optimized for macOS desktop experience
- **Built to grow** — architecture supports future feature expansion

## 🎯 MVP Scope (Ruthlessly Minimal)

### Core Features (Must Have)

#### 1. **Interactive Map Display**
- OpenStreetMap integration using flutter_map
- Pan and zoom functionality
- Clean, full-screen map interface
- Basic map controls (zoom in/out buttons)

#### 2. **GPX File Loading**
- Minimal menu bar with File > Open GPX option
- File picker to select GPX files from local system
- Parse and display GPX tracks on the map
- Show track as colored line overlay
- Fit map view to loaded track bounds

#### 3. **Basic Map Navigation**
- Mouse/trackpad pan and zoom only
- Floating zoom controls (+/- buttons)

#### 4. **Minimal Menu Bar**
- File menu with "Open GPX..." and "Quit" options
- Standard macOS menu bar behavior
- Keyboard shortcuts (⌘O for Open, ⌘Q for Quit)

### 🚫 Explicitly Excluded from MVP

- Multiple map providers (only OpenStreetMap)
- GPX editing or creation
- Track analysis (distance, elevation, etc.)
- Waypoint management
- Multiple track loading
- Track styling options
- Export functionality
- Settings/preferences
- Complex menu structure or additional menus
- Track metadata display
- Search functionality
- Bookmarks or saved locations
- Keyboard navigation (arrow keys, +/- zoom)
- Reset view to default location feature

## 📁 File Structure

```
app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── gpx_track.dart       # GPX data model
│   ├── services/
│   │   ├── gpx_service.dart     # GPX file parsing
│   │   └── map_service.dart     # Map state management
│   ├── widgets/
│   │   ├── map_view.dart        # Main map widget
│   │   ├── map_controls.dart    # Zoom controls
│   │   └── menu_bar.dart        # Application menu bar
│   └── screens/
│       └── home_screen.dart     # Main app screen
├── pubspec.yaml                 # Dependencies
└── assets/
    └── icons/                   # App icons
```

## 🎨 UI Design Approach

### Layout Philosophy
- **Full-screen map** — map takes up entire window below menu bar
- **Minimal menu bar** — only essential File menu options
- **Floating controls** — minimal UI overlays on map
- **macOS native** — follows macOS design patterns
- **Mouse/trackpad focused** — optimized for pointer interaction

### Visual Design
- Clean, minimal interface
- Map occupies 100% of screen real estate below menu bar
- Floating action buttons for essential controls
- Subtle shadows and transparency for overlays
- System colors and fonts
- Standard macOS menu bar styling

### Control Placement
```
┌─────────────────────────────────────┐
│ File                                │ ← Menu bar
├─────────────────────────────────────┤
│                             [+]     │ ← Floating controls
│                             [-]     │
│                                     │
│           MAP AREA                  │
│                                     │
│                                     │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

## 🏗️ App Organization

### Architecture Pattern
- **Widget-based architecture** following Flutter best practices
- **Service layer** for business logic (GPX parsing, map state)
- **Model layer** for data structures
- **Stateful widgets** for interactive components

### State Management
- **Built-in Flutter state management** (setState)
- **Provider pattern** for sharing map state between widgets
- No external state management libraries (keeping it simple)

### Data Flow
1. User selects File > Open GPX → Menu action
2. GPX file parsed → GPXService
3. Track data stored → MapService
4. Map updated → MapView widget
5. UI reflects changes → Map displays track

## 🔧 Technical Dependencies

### Required Packages
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_map: ^6.0.1           # OpenStreetMap integration
  latlong2: ^0.8.1              # Coordinate handling
  file_picker: ^6.1.1           # File selection
  xml: ^6.3.0                   # GPX parsing
  provider: ^6.1.1              # State management
```

### Platform Requirements
- macOS 10.14+ (Mojave)
- Flutter 3.8.0+
- Dart 3.0+

## 📱 User Interface Specifications

### Main Screen Layout
- **Minimal menu bar** with File menu
- **Full-screen map view** below menu bar
- **Zoom controls** (top-right corner)
- **Minimal visual chrome** to maximize map space

### Menu Bar Structure
```
File
├── Open GPX...    ⌘O
├── ─────────────
└── Quit           ⌘Q
```

### Color Scheme
- **Primary**: System blue (#007AFF)
- **Background**: Map tiles (OpenStreetMap default)
- **Track color**: Bright red (#FF3B30) for visibility
- **Controls**: Semi-transparent white backgrounds
- **Menu bar**: Standard macOS appearance

### Typography
- **System font** (SF Pro on macOS)
- **Menu text**: Standard macOS menu styling
- **Button text**: 14pt medium weight
- **No text overlays** on map (keeping it clean)

## 🎯 Success Metrics for MVP

### Functional Success
- [ ] App launches without errors
- [ ] Menu bar displays with File menu
- [ ] File > Open GPX opens file picker and loads tracks
- [ ] File > Quit closes the application
- [ ] Map displays and is interactive (pan/zoom)
- [ ] GPX file can be selected and loaded via menu
- [ ] Track displays correctly on map
- [ ] Map fits to track bounds automatically
- [ ] Menu keyboard shortcuts work (⌘O, ⌘Q)
- [ ] Floating zoom controls work (+/- buttons)

### User Experience Success
- [ ] Intuitive without instructions
- [ ] Responsive interaction (smooth pan/zoom)
- [ ] Clean, distraction-free interface
- [ ] Works reliably with common GPX files
- [ ] Follows macOS conventions

## 📋 Implementation Notes

### Critical Decisions
- **Single track only** — simplifies state management
- **No persistence** — tracks loaded per session only
- **OpenStreetMap only** — reduces complexity
- **No track editing** — view-only functionality
- **Minimal menu bar** — only essential File menu options

### Technical Constraints
- macOS desktop only (no mobile optimization)
- Local file access only (no cloud integration)
- Standard GPX format only (no proprietary formats)
- English language only (no internationalization)

### Menu Bar Implementation
- Use Flutter's native menu bar support for macOS
- Standard File menu with Open and Quit actions
- Menu keyboard shortcuts follow macOS conventions (⌘O, ⌘Q only)
- File > Open GPX triggers same functionality as before

This MVP plan prioritizes getting a working, useful mapping application with minimal complexity while maintaining a clear path for future enhancement. 