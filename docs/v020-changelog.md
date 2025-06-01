# v020 Changelog

## Overview
This version implements an optimized spatial search system for finding nearby segments using SQLite's range query capabilities and bounding box calculations.

## File Structure
```
app/
├── lib/
│   ├── core/
│   │   ├── models/
│   │   │   └── segment.dart           # Updated with coordinate fields
│   │   └── services/
│   │       ├── database_service.dart  # Added migration for coordinate fields
│   │       └── segment_service.dart   # Added spatial search functionality
│   └── modes/
│       └── route_builder/
│           ├── screens/
│           │   └── route_builder_screen.dart  # Uses spatial search for map clicks
│           └── services/
│               └── route_builder_service.dart # Updated to use new spatial search
```

## Implementation Details

### Database Schema Enhancement
- Added new columns to segment table:
  - `start_lat` (REAL)
  - `start_lng` (REAL)
  - `end_lat` (REAL)
  - `end_lng` (REAL)
- Created indexes for optimized range queries:
  - `idx_start_coords` on (start_lat, start_lng)
  - `idx_end_coords` on (end_lat, end_lng)
- Implemented database migration (v5) to calculate and populate coordinate values for existing segments

### Spatial Search Implementation
- Added `BoundingBox` class for spatial search area calculation
- Implemented two-phase search strategy:
  1. Fast initial filtering using SQLite range queries
  2. Precise distance calculation for remaining candidates
- Added coordinate conversion utilities for accurate distance calculations
- Integrated with route builder for map click handling

### Route Builder Integration
- Updated `RouteBuilderService` to use new spatial search
- Maintains existing UI/UX with improved performance
- Handles both one-way and bidirectional segments
- Preserves segment direction handling in preview generation

## Technical Details

### Bounding Box Calculation
```dart
BoundingBox calculateBoundingBox(LatLng point, double radiusMeters) {
  final latDelta = radiusMeters / 111320.0;
  final lngDelta = radiusMeters / (111320.0 * math.cos(point.latitude * math.pi / 180.0));
  return BoundingBox(
    left: point.longitude - lngDelta,
    right: point.longitude + lngDelta,
    bottom: point.latitude - latDelta,
    top: point.latitude + latDelta,
  );
}
```

### Search Algorithm
```dart
// Phase 1: Bounding Box Search
final bounds = calculateBoundingBox(point, radiusMeters);
final candidates = await db.query(
  'segments',
  where: '''
    (start_lng >= ? AND start_lng <= ? AND start_lat >= ? AND start_lat <= ?)
    OR
    (end_lng >= ? AND end_lng <= ? AND end_lat >= ? AND end_lat <= ?)
  ''',
  whereArgs: [
    bounds.left, bounds.right, bounds.bottom, bounds.top,
    bounds.left, bounds.right, bounds.bottom, bounds.top,
  ],
);

// Phase 2: Precise Distance Check
final matches = candidates.where((segment) {
  if (!segment.isBidirectional) {
    return isWithinDistance(clickPoint, segment.startPoint, radiusMeters);
  }
  return isWithinDistance(clickPoint, segment.startPoint, radiusMeters) ||
         isWithinDistance(clickPoint, segment.endPoint, radiusMeters);
}).toList();
```

## Dependencies
- Uses existing:
  - `latlong2` for coordinate calculations
  - `provider` for state management
  - `sqflite` for database operations 