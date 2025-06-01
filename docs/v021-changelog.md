# v021 Changelog

## Overview
Version 021 implements segment library import/export functionality, allowing users to save and load segment collections in GeoJSON format. This version adds a new "Database" menu with options to export and import segments.

## File Structure
```
app/
├── lib/
│   ├── core/
│   │   ├── models/
│   │   │   └── segment.dart           # Segment data model
│   │   └── services/
│   │       ├── database_service.dart  # Database operations
│   │       ├── segment_export_service.dart  # GeoJSON export
│   │       └── segment_import_service.dart  # GeoJSON import
│   ├── modes/
│   │   └── segment_library/
│   │       └── services/
│   │           └── segment_library_service.dart  # Library state management
│   └── main.dart                      # App entry point with menu structure
```

## Menu Structure
```
Database
├── Reset Database
├── Export Segments
└── Import Segments
```

## Implementation Details

### Database Menu
- Added new "Database" menu to the main menu bar
- Grouped menu items into logical sections
- Implemented native macOS menu integration

### Export Functionality
- Created `SegmentExportService` for handling exports
- Implemented GeoJSON export with the following structure:
  ```json
  {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "properties": {
          "id": "string",
          "name": "string",
          "direction": "string"
        },
        "geometry": {
          "type": "LineString",
          "coordinates": [
            [longitude, latitude, elevation?],
            ...
          ]
        }
      }
    ]
  }
  ```
- Added file save dialog with `.geojson` extension
- Implemented error handling and user feedback

### Import Functionality
- Created `SegmentImportService` for handling imports
- Implemented GeoJSON import with validation:
  - Validates FeatureCollection structure
  - Validates Feature properties
  - Validates LineString geometry
  - Handles elevation data
- Added file open dialog with `.geojson` extension
- Added confirmation dialog for replacing existing segments
- Implemented error handling and user feedback

### Data Model Integration
- Updated `Segment` model to support GeoJSON import/export
- Maintained compatibility with existing database schema
- Preserved elevation data in segment points

### User Interface
- Added error dialogs for failed operations
- Implemented confirmation dialog for destructive operations
- Used system colors for warning/error states
- Maintained native macOS look and feel

### Error Handling
- File operation errors
- JSON parsing errors
- Data validation errors
- Database operation errors
- User feedback for all error cases

## Dependencies
- `file_selector: ^1.0.1` - Native file dialogs
- `latlong2: ^0.9.1` - Geographic coordinates
- `sqflite_common_ffi: ^2.3.2` - Database operations 