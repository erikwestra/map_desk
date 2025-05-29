# MapDesk Phase 1 Implementation Plan

## Project Overview

MapDesk Phase 1 focuses on establishing the **foundational application structure** with menu bar functionality and GPX file loading capabilities. This phase creates the basic app framework with a placeholder map area, setting up the architecture for Phase 2's map integration.

## 🌟 Phase 1 Purpose

To create the foundational desktop application that:
- Establishes the basic app structure and menu system
- Implements GPX file loading and parsing
- Creates the UI framework for future map integration
- Validates the core architecture patterns

Phase 1 is deliberately focused on infrastructure, designed to prove the app concept and prepare for Phase 2's map functionality.

## 🧠 Design Philosophy

- **Foundation first** — establish solid app architecture
- **Menu-driven interaction** — macOS-native menu bar experience
- **File handling focus** — robust GPX parsing and validation
- **Architecture validation** — prove patterns before complexity
- **Built to extend** — clean handoff to Phase 2

## 🎯 Phase 1 Scope (Foundation Only)

### Core Features (Must Have)

#### 1. **Application Structure**
- Basic Flutter macOS desktop app
- Clean window with menu bar
- Placeholder content area with "Map goes here" message
- Standard macOS window behavior

#### 2. **Menu Bar Implementation**
- File menu with "Open GPX..." and "Quit" options
- Standard macOS menu bar behavior
- Keyboard shortcuts (⌘O for Open, ⌘Q for Quit)
- Native macOS menu integration

#### 3. **GPX File Loading**
- File picker to select GPX files from local system
- GPX file parsing and validation
- Basic error handling for invalid files
- Display loaded track information in placeholder area
- Store parsed track data for Phase 2

#### 4. **Basic UI Framework**
- Main screen layout with placeholder map area
- Status display for loaded GPX files
- Error messaging for file loading issues
- Clean, minimal interface ready for map integration

### 🚫 Explicitly Excluded from Phase 1

- Map display (placeholder only)
- Map navigation or interaction
- Track visualization on maps
- Zoom controls
- Map providers or tiles
- Geographic coordinate display
- Track styling or rendering
- Multiple track loading
- Track analysis features

## 📁 File Structure

```
app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── gpx_track.dart       # GPX data model
│   ├── services/
│   │   └── gpx_service.dart     # GPX file parsing
│   ├── widgets/
│   │   ├── placeholder_map.dart # "Map goes here" widget
│   │   └── menu_bar.dart        # Application menu bar
│   └── screens/
│       └── home_screen.dart     # Main app screen
├── pubspec.yaml                 # Dependencies
└── assets/
    └── icons/                   # App icons
```

## 🎨 UI Design Approach

### Layout Philosophy
- **Placeholder-driven** — clear space reserved for future map
- **Menu-centric** — primary interaction through menu bar
- **Status-aware** — clear feedback on file loading state
- **macOS native** — follows macOS design patterns

### Visual Design
- Clean, minimal interface
- Large placeholder area for future map (with centered text)
- Standard macOS menu bar styling
- System colors and fonts
- Clear status messaging

### Phase 1 Layout
```
┌─────────────────────────────────────┐
│ File                                │ ← Menu bar
├─────────────────────────────────────┤
│                                     │
│                                     │
│           "Map goes here"           │ ← Placeholder area
│                                     │
│         [GPX file status]           │ ← Status display
│                                     │
│                                     │
└─────────────────────────────────────┘
```

## 🏗️ App Organization

### Architecture Pattern
- **Widget-based architecture** following Flutter best practices
- **Service layer** for GPX parsing business logic
- **Model layer** for GPX data structures
- **Stateful widgets** for file loading state

### State Management
- **Built-in Flutter state management** (setState)
- Simple state for file loading status
- No external state management libraries (keeping it simple)

### Data Flow
1. User selects File > Open GPX → Menu action
2. File picker opens → User selects GPX file
3. GPX file parsed → GPXService
4. Track data stored → App state
5. UI updates → Status display shows loaded file info

## 🔧 Technical Dependencies

### Required Packages
```yaml
dependencies:
  flutter:
    sdk: flutter
  file_picker: ^6.1.1           # File selection
  xml: ^6.3.0                   # GPX parsing
```

### Platform Requirements
- macOS 10.14+ (Mojave)
- Flutter 3.8.0+
- Dart 3.0+

## 📱 User Interface Specifications

### Main Screen Layout
- **Menu bar** with File menu
- **Large placeholder area** with "Map goes here" text
- **Status area** showing loaded GPX file information
- **Minimal visual chrome** to focus on functionality

### Menu Bar Structure
```
File
├── Open GPX...    ⌘O
├── ─────────────
└── Quit           ⌘Q
```

### Placeholder Content
- Centered "Map goes here" text in large, light gray font
- Below that, status information about loaded GPX file:
  - File name
  - Number of track points
  - Basic track info (if loaded)
- Clean, readable typography

### Color Scheme
- **Primary**: System blue (#007AFF)
- **Background**: Light gray (#F5F5F5)
- **Placeholder text**: Medium gray (#8E8E93)
- **Status text**: Dark gray (#1C1C1E)
- **Menu bar**: Standard macOS appearance

### Typography
- **System font** (SF Pro on macOS)
- **Placeholder text**: 24pt light weight
- **Status text**: 16pt regular weight
- **Menu text**: Standard macOS menu styling

## 🎯 Success Metrics for Phase 1

### Functional Success
- [ ] App launches without errors
- [ ] Menu bar displays with File menu
- [ ] File > Open GPX opens file picker
- [ ] File > Quit closes the application
- [ ] GPX file can be selected via file picker
- [ ] Valid GPX files parse successfully
- [ ] Invalid files show appropriate error messages
- [ ] Menu keyboard shortcuts work (⌘O, ⌘Q)
- [ ] Loaded file information displays in placeholder area
- [ ] App maintains loaded file state during session

### User Experience Success
- [ ] Intuitive menu-driven workflow
- [ ] Clear feedback on file loading status
- [ ] Clean, professional interface
- [ ] Follows macOS conventions
- [ ] Ready for Phase 2 map integration

## 📋 Implementation Notes

### Critical Decisions
- **Placeholder-first approach** — establish UI framework before map complexity
- **Single track only** — simplifies state management
- **No persistence** — tracks loaded per session only
- **Minimal dependencies** — only essential packages for Phase 1
- **Menu-driven workflow** — primary interaction through File menu

### Technical Constraints
- macOS desktop only (no mobile optimization)
- Local file access only (no cloud integration)
- Standard GPX format only (no proprietary formats)
- English language only (no internationalization)

### Phase 2 Preparation
- GPX data models designed for map integration
- UI layout reserves space for map component
- Service architecture ready for map state management
- Clean separation between file handling and future map logic

### Menu Bar Implementation
- Use Flutter's native menu bar support for macOS
- Standard File menu with Open and Quit actions
- Menu keyboard shortcuts follow macOS conventions (⌘O, ⌘Q only)
- File > Open GPX triggers file picker and parsing workflow

This Phase 1 plan establishes the foundational application structure and file handling capabilities, creating a solid base for Phase 2's map integration while validating the core architecture and user workflow. 