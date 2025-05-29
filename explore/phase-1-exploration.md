# MapDesk: GPX Route Viewer for macOS (Flutter)

## 🔭 North Star

**To create the fastest, cleanest way to view GPX routes on a Mac.**  
A lightweight, local-first desktop app that allows users to drop in a `.gpx` file and immediately visualize the route on an interactive map using online basemaps.

The app is designed for users such as cyclists, hikers, and route planners who want a distraction-free, frictionless way to view GPX tracks without unnecessary features.

---

## 🎯 MVP Purpose

The app is:

- Built using **Flutter**, targeting **macOS desktop**.
- **Single-purpose**: visualizing GPX files on a map.
- Designed to be **simple**, **fast**, and **easy to use**.
- Focused on **local file use** and **online basemap rendering**.
- **Does not** support editing, cloud sync, or file management beyond import.

---

## ✨ Core Features

### 1. Import GPX Files
- Supports drag-and-drop and manual file selection.
- Parses `.gpx` files to extract route and (optionally) metadata.

### 2. Map Display
- Renders the GPX route over an interactive map (e.g., OpenStreetMap).
- Automatically centers and zooms to the bounds of the track.

### 3. Basic Route Info (Optional)
- Displays simple details if available:  
  - Total distance  
  - Elevation gain  
  - Number of points  

---

## 🧱 Design Principles

| Principle               | Description                                                                 |
|-------------------------|-----------------------------------------------------------------------------|
| Clarity over complexity | UI should be self-evident with zero onboarding friction.                   |
| Speed & responsiveness  | File import and map rendering should feel instant.                         |
| Local-first             | No backend or cloud integration. Files are imported directly from the user.|
| Online maps allowed     | Basemap tiles are fetched live via the internet (e.g., OpenStreetMap).     |
| Single-purpose focus    | No note-taking, tagging, syncing, or GPX editing.                          |

---

## 🧩 MVP Component Overview

| Component             | Description                                                                  |
|-----------------------|------------------------------------------------------------------------------|
| GPX Import Interface  | Drag-and-drop or file picker for opening `.gpx` files                        |
| GPX Parser            | Extracts route data from the GPX file, optionally simplifies for performance |
| Map Renderer          | Displays the route on an interactive basemap                                |
| Route Summary Panel   | (Optional) Displays distance, elevation, and point count                     |

---

## 🚫 Explicitly Out of Scope

- User accounts or authentication  
- GPX editing or annotation  
- Document/note-taking features  
- Persistent file libraries  
- Offline tile caching (can be explored post-MVP)  
- Custom map theming or overlays  

---

## 🚀 Future Extensions (Post-MVP Ideas)

- Elevation profile display  
- Support for viewing multiple GPX tracks simultaneously  
- Offline map support through tile caching  
- Snapshot/export of map view as image  
- Mobile/tablet version using Flutter's cross-platform ability  

---

## ✅ Summary Statement

This MVP is a **clean, fast Mac desktop app built in Flutter** to visualize GPX tracks on an interactive online map. It emphasizes **clarity, simplicity, and performance**, avoiding feature bloat while providing essential GPX route visualization.

---

## 📝 Next Steps for Implementation Planning

A second LLM or developer could now proceed to:

- Select appropriate Flutter plugins for:
  - File import
  - GPX parsing
  - Map rendering
- Define the app's UI layout and interaction flow
- Outline a milestone-based build plan
- Create a wireframe or visual mockup if needed 