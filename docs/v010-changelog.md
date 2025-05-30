# MapDesk v010 Changelog

## Overview
Version v010 focuses on improving the track loading and zoom behavior in the import workflow. Instead of zooming to the entire track bounds, the application now creates a rectangle using the start and end points of the track, expands it by 10%, and zooms to that area. This change makes it easier for users to select and work with the start and end points of tracks.

## Implementation Details

### File Structure
```
app/
├── lib/
│   ├── services/
│   │   └── import_service.dart     # Updated with new zoom behavior
│   └── widgets/
│       └── import_map_view.dart    # Updated with pixel-based point selection
└── docs/
    └── v010-changelog.md          # This changelog
```

### Service Layer

#### ImportService (`app/lib/services/import_service.dart`)
- Added `calculateTrackEndpointsBounds()` method that:
  - Creates a rectangle using only the start and end points
  - Calculates the center point of the bounds
  - Expands the bounds by 10% in both dimensions
  - Returns the expanded bounds for zooming
- Modified `zoomToTrackBounds()` to use the new bounds calculation
- Maintains existing track loading and selection functionality

### Widget Layer

#### ImportMapView (`app/lib/widgets/import_map_view.dart`)
- Implemented pixel-based point selection with:
  - 20-pixel click tolerance
  - Screen coordinate conversion for accurate distance calculation
  - Pythagorean theorem for distance measurement
- Maintains existing track visualization:
  - Red color for unselected portions
  - Blue color for selected portions
  - Clear markers for start and end points

### Screen Structure
```
ImportTrackView
├── ImportTrackTopPanel
└── Row
    ├── ImportMapView (expanded)
    └── ImportTrackSegmentList
```

### Key Changes
1. **Zoom Behavior**
   - Now focuses on start/end points instead of entire track
   - 10% expansion for better visibility
   - Smoother zoom transitions

2. **Point Selection**
   - Pixel-based click detection (20px tolerance)
   - More accurate point selection
   - Better handling of different zoom levels

3. **Visual Feedback**
   - Clear start/end point markers
   - Color-coded track segments
   - Improved selection visibility

## Technical Implementation

### Bounds Calculation
```dart
LatLngBounds? calculateTrackEndpointsBounds() {
  if (_track == null || _track!.points.isEmpty) return null;
  
  // Get first and last points
  final firstPoint = _track!.points.first.toLatLng();
  final lastPoint = _track!.points.last.toLatLng();
  
  // Create bounds rectangle
  final bounds = LatLngBounds.fromPoints([firstPoint, lastPoint]);
  
  // Calculate the center point
  final center = LatLng(
    (bounds.north + bounds.south) / 2,
    (bounds.east + bounds.west) / 2,
  );
  
  // Calculate the size of the bounds
  final latSpan = bounds.north - bounds.south;
  final lngSpan = bounds.east - bounds.west;
  
  // Expand by 10%
  final expandedLatSpan = latSpan * 1.1;
  final expandedLngSpan = lngSpan * 1.1;
  
  // Create new expanded bounds
  return LatLngBounds(
    LatLng(center.latitude - expandedLatSpan / 2, center.longitude - expandedLngSpan / 2),
    LatLng(center.latitude + expandedLatSpan / 2, center.longitude + expandedLngSpan / 2),
  );
}
```

### Point Selection
```dart
void _handleMapTap(LatLng point, List<LatLng> trackPoints, bool startOrEndOnly) {
  if (widget.onPointSelected == null) return;

  final importService = context.read<ImportService>();
  final mapController = importService.mapController;

  // Find the closest point within tolerance
  double minDistance = double.infinity;
  int? closestIndex;
  
  for (int i = 0; i < trackPoints.length; i++) {
    final trackPoint = trackPoints[i];
    // Convert points to screen coordinates
    final pointScreen = mapController.latLngToScreenPoint(point);
    final trackPointScreen = mapController.latLngToScreenPoint(trackPoint);
    
    // Calculate pixel distance
    final dx = pointScreen.x - trackPointScreen.x;
    final dy = pointScreen.y - trackPointScreen.y;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    if (distance < minDistance) {
      minDistance = distance;
      closestIndex = i;
    }
  }
  
  // Check if the closest point is within tolerance
  if (closestIndex != null && minDistance <= _clickTolerance) {
    // If startOrEndOnly is true, only allow selecting first or last point
    if (startOrEndOnly) {
      if (closestIndex != 0 && closestIndex != trackPoints.length - 1) {
        return; // Ignore clicks on points that aren't first or last
      }
    }
    widget.onPointSelected!(closestIndex);
  }
}
```

## Dependencies
- No new external dependencies required
- Uses existing map and import services
- Maintains compatibility with current GPX parsing 