# MapDesk v010 Implementation Plan

## Overview
Version v010 focuses on improving the track loading and zoom behavior to provide a better user experience when working with GPX tracks. Instead of zooming to the entire track bounds, the application will now create a rectangle using the start and end points of the track, expand it by 10%, and zoom to that area. This change will make it easier for users to select and work with the start and end points of tracks.

## Goals
- Improve track loading visualization by focusing on start and end points
- Create a more intuitive zoom level for track manipulation
- Maintain smooth performance during track loading
- Preserve existing track loading functionality while enhancing the zoom behavior

## Technical Implementation

### 1. ImportService Updates
- Add new method to calculate start and end point bounds
- Modify `zoomToTrackBounds()` to use start/end points instead of all points
- Implement 10% expansion logic for the bounds rectangle
- Update zoom level calculation based on new bounds

### 2. Map Service Updates
- Add new method to handle zoom to specific bounds
- Implement smooth zoom animation to new bounds
- Ensure proper coordinate conversion between GPX and map coordinates
- Add error handling for edge cases (single point tracks, invalid coordinates)

### 3. UI Updates
- Update loading indicator to show progress during zoom
- Add visual feedback when zooming to track bounds
- Ensure smooth transition between track loading and zoom

## Implementation Steps

1. **ImportService Modifications**
   ```dart
   // New method to calculate start/end bounds
   LatLngBounds calculateTrackEndpointsBounds() {
     if (_track == null || _track!.points.isEmpty) return null;
     
     // Get first and last points
     final firstPoint = _track!.points.first.toLatLng();
     final lastPoint = _track!.points.last.toLatLng();
     
     // Create bounds rectangle
     final bounds = LatLngBounds.fromPoints([firstPoint, lastPoint]);
     
     // Expand by 10%
     final expandedBounds = bounds.expand(0.1);
     
     return expandedBounds;
   }

   // Modified zoomToTrackBounds method
   void zoomToTrackBounds() {
     if (!_isMapReady || _track == null || _track!.points.isEmpty) return;
     try {
       final bounds = calculateTrackEndpointsBounds();
       if (bounds != null) {
         _mapController.fitBounds(bounds, options: const FitBoundsOptions(padding: EdgeInsets.all(50)));
       }
     } catch (e) {
       // If the map controller isn't ready yet, schedule another attempt
       _scheduleZoomToTrackBounds();
     }
   }
   ```

2. **Integration Points**
   - Update track loading flow to use new bounds calculation
   - Modify zoom behavior in map controller
   - Add error handling for edge cases

## Success Criteria
- [ ] Track loading zooms to start/end point rectangle
- [ ] Rectangle is properly expanded by 10%
- [ ] Zoom level is appropriate for track manipulation
- [ ] Smooth animation during zoom
- [ ] Proper error handling for edge cases:
  - [ ] Single point tracks
  - [ ] Invalid coordinates
  - [ ] Empty tracks
  - [ ] Map controller not ready
- [ ] No performance degradation
- [ ] All tests passing

## Dependencies
- No new external dependencies required
- Uses existing map and import services
- Maintains compatibility with current GPX parsing

## Notes
- Consider adding configuration option for expansion percentage
- May need to adjust zoom level calculation based on user feedback
- Consider adding visual indicators for start/end points
- May need to optimize for very long tracks

## Future Considerations
- Add user preference for zoom behavior
- Consider adding waypoint support
- Implement track segment handling
- Add support for multiple track loading 