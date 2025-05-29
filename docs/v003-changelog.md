# MapDesk v003 Changelog

## Overview
Version 003 of MapDesk implements a robust database system for storing and managing GPX track segments. This version focuses on data persistence and efficient segment management.

## Technical Implementation

### Database System
- **SQLite Database**: Located at `~/Library/Containers/com.example.mapDesk/Data/Library/Application Support/com.example.mapDesk/databases/segments.db`
- **Schema Version**: 1.0
- **Tables**:
  - `segments`: Stores individual track segments
  - `segment_points`: Stores points within segments
  - `segment_metadata`: Stores additional segment information

### Core Components

#### Database Service
- **File**: `app/lib/services/database_service.dart`
- **Purpose**: Manages all database operations
- **Key Features**:
  - Database initialization and migration
  - CRUD operations for segments
  - Transaction support
  - Error handling and logging

#### Segment Models
- **File**: `app/lib/models/segment.dart`
- **Purpose**: Defines data structures for segments
- **Key Classes**:
  - `Segment`: Core segment data model
  - `SegmentPoint`: Individual point within a segment
  - `SegmentMetadata`: Additional segment information

#### GPX Service Integration
- **File**: `app/lib/services/gpx_service.dart`
- **Purpose**: Handles GPX file processing
- **Key Features**:
  - GPX file parsing
  - Segment extraction
  - Database integration

## File Structure

```
app/
├── lib/
│   ├── services/
│   │   ├── database_service.dart    # Database operations
│   │   └── gpx_service.dart         # GPX file handling
│   ├── models/
│   │   └── segment.dart             # Segment data models
│   └── main.dart                    # App entry point
└── pubspec.yaml                     # Dependencies
```

## Dependencies
- `sqflite: ^2.3.0` - SQLite database support
- `path: ^1.8.3` - Path manipulation
- `xml: ^6.3.0` - GPX file parsing

## Database Schema

### segments Table
```sql
CREATE TABLE segments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);
```

### segment_points Table
```sql
CREATE TABLE segment_points (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    segment_id INTEGER NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    elevation REAL,
    timestamp INTEGER,
    FOREIGN KEY (segment_id) REFERENCES segments (id)
);
```

### segment_metadata Table
```sql
CREATE TABLE segment_metadata (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    segment_id INTEGER NOT NULL,
    key TEXT NOT NULL,
    value TEXT,
    FOREIGN KEY (segment_id) REFERENCES segments (id)
);
```

## Implementation Details

### Database Operations
- **Initialization**: Database is created on first app launch
- **Migrations**: Schema version tracking and migration support
- **Transactions**: All write operations use transactions
- **Error Handling**: Comprehensive error handling and logging

### Data Flow
1. GPX file is loaded through the file picker
2. GPX service parses the file and extracts segments
3. Database service stores segments and their points
4. UI components retrieve data through database service

### Security
- Database file is stored in app's sandboxed container
- All database operations are performed within transactions
- Input validation and sanitization implemented

### Performance
- Indexed queries for efficient segment retrieval
- Batch operations for point insertion
- Efficient memory management for large GPX files 