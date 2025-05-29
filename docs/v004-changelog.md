# MapDesk v004 Changelog

## Implemented Features

- **Split Mode Toggle:** A toggle in the toolbar allows users to enter split mode.
- **Segment Creation UI:** Users can select start and end points on a loaded GPX track to create segments.
- **Segment Naming and Storage:** Segments can be named and saved, with optional descriptions.
- **Visual Feedback:** Selected points are highlighted, and a controls overlay guides the user through the segment creation process.

## Technical Layout

- **MapView:** Manages the map display and split mode state. It includes a `MarkerLayer` for clickable track points when in split mode.
- **SegmentSplitter:** Handles the UI logic for segment creation, including the controls overlay and segment naming dialog.
- **MapService:** Manages the map controller, track data, and segment storage.

## File Structure

```
app/
├── lib/
│   ├── models/
│   │   ├── gpx_track.dart       # GPX data models
│   │   └── segment.dart         # Segment model
│   ├── services/
│   │   ├── gpx_service.dart     # GPX file parsing
│   │   ├── map_service.dart     # Map state management
│   │   └── database_service.dart # Database service
│   ├── widgets/
│   │   ├── map_view.dart        # Map widget
│   │   ├── map_controls.dart    # Map controls
│   │   └── segment_splitter.dart # Segment splitting UI
│   └── screens/
│       └── home_screen.dart     # Main app screen
├── pubspec.yaml                 # Dependencies
└── docs/
    └── v004-changelog.md        # Changelog for v004
``` 