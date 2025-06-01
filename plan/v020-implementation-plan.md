# v020 Implementation Plan

## Core Purpose
This phase implements an optimized spatial search system for finding nearby segments using SQLite's range query capabilities and bounding box calculations.

## Key Components
1. **Database Schema Enhancement**
   - Add new columns to segment table:
     - `start_lat` (REAL)
     - `start_lng` (REAL)
     - `end_lat` (REAL)
     - `end_lng` (REAL)
   - Create indexes on these columns for optimized range queries
   - Implement database migration to calculate and populate these values for existing segments

2. **Spatial Search Implementation**
   - Implement bounding box calculation:
     - Calculate horizontal and vertical deltas for 10-meter radius
     - Convert deltas to latitude/longitude offsets
     - Generate bounding box coordinates
   - Implement two-phase search strategy:
     1. Fast initial filtering using SQLite range queries
     2. Precise distance calculation for remaining candidates

3. **Search Algorithm**
   ```dart
   // Phase 1: Bounding Box Search
   final bounds = calculateBoundingBox(clickPoint, 10.0);
   final candidates = await database.query(
     'segment',
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
     // For one-way segments, only check the starting point
     if (!segment.isBidirectional) {
       return isWithinDistance(clickPoint, segment.startPoint, 10.0);
     }
     // For bidirectional segments, check both start and end points
     return isWithinDistance(clickPoint, segment.startPoint, 10.0) ||
            isWithinDistance(clickPoint, segment.endPoint, 10.0);
   }).toList();
   ```

## Success Criteria
- Initial bounding box search completes within 50ms
- Total search time (including precise distance check) under 100ms
- Memory usage remains stable during extended use
- Search results are accurate within 10-meter radius
- UI remains responsive during searches
- Database migration completes successfully for existing segments

## Technical Notes
- Use SQLite's built-in indexing capabilities for range queries
- Implement efficient coordinate conversion for delta calculations
- Consider using prepared statements for repeated queries
- Add performance metrics logging
- Handle edge cases (e.g., segments crossing the date line)

## Dependencies
- Uses existing:
  - `latlong2` for coordinate calculations
  - `provider` for state management
  - `sqflite` for database operations

## Migration Strategy
1. Create new table with updated schema
2. Copy existing data
3. Calculate and populate new coordinate columns
4. Create indexes
5. Verify data integrity
6. Switch to new table 