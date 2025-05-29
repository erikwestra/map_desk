# MapDesk v003 Implementation Plan: Database Foundation

## 🎯 MVP Scope

Building upon the functionality built so far, v003 will add SQLite database support as the foundation for segment management. This version will:

1. Set up SQLite database infrastructure
2. Implement database migrations system
3. Create segment data model
4. Add basic database operations

We will defer the following features to future versions:
- Segment creation UI
- Segment management UI
- Route building from segments
- Route export functionality
- Advanced segment filtering and searching
- Segment direction management (A→B, B→A)
- Complex segment metadata
- Route optimization
- Multiple route management
- Advanced UI customization

## 📁 Project Structure Updates

```
app/
├── lib/
│   ├── models/
│   │   ├── gpx_track.dart       # Existing GPX models
│   │   └── segment.dart         # NEW: Segment data model
│   └── services/
│       ├── gpx_service.dart     # Existing GPX service
│       ├── map_service.dart     # Existing map service
│       └── database_service.dart # NEW: Database operations
```

## 🔧 Technical Implementation

### New Data Models

```dart
class Segment {
  final String id;
  final String name;
  final List<GpxPoint> points;
  final DateTime createdAt;
}
```

### Database Structure
The SQLite database will be stored in:
```
~/Library/Application Support/com.example.mapdesk/databases/segments.db
```

Database schema (v1):
```sql
CREATE TABLE segments (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  points TEXT NOT NULL,  -- JSON-encoded list of GpxPoints
  created_at INTEGER NOT NULL  -- Unix timestamp
);
```

### Database Migrations
We'll implement a version-based migration system:

```dart
class DatabaseMigration {
  static const int currentVersion = 1;
  
  static Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 1) {
      // Initial schema
      await db.execute('''
        CREATE TABLE segments (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          points TEXT NOT NULL,
          created_at INTEGER NOT NULL
        )
      ''');
    }
    
    // Future migrations would go here:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE segments ADD COLUMN description TEXT');
    // }
  }
}
```

The migration system will:
- Track database version in a metadata table
- Run migrations in sequence
- Support adding new tables and columns
- Handle data transformations if needed
- Preserve existing data during updates

### New Dependencies
```yaml
dependencies:
  sqflite: ^2.3.2  # SQLite database
  path_provider: ^2.1.2  # For getting app support directory
  path: ^1.8.3  # For path manipulation
```

## 🚀 Implementation Phases

### Phase 1: Database Foundation
1. Add SQLite dependencies
2. Create segment data model
3. Implement database service
4. Set up migration system
5. Add basic CRUD operations

## 📈 Success Metrics

The v003 update will be considered successful when:
1. Database is properly initialized in the app support directory
2. Migration system works correctly
3. Basic CRUD operations function reliably
4. No impact on existing app functionality
5. Clean error handling for database operations

## ⚠️ Known Limitations

1. No UI for segment management
2. No segment creation functionality
3. No segment viewing capabilities
4. Basic error handling only
5. No data validation beyond SQL constraints

## 🔄 Future Enhancements

1. Segment creation UI (v004)
2. Segment management UI (v005)
3. Route building from segments
4. Route export functionality
5. Advanced segment metadata
6. Advanced filtering and search
7. Route statistics and analysis 