// TrackImportOptions model for storing GPX import configuration
enum TrackDirection { forward, backward }

class TrackImportOptions {
  final String defaultSegmentName;
  final TrackDirection trackDirection;
  
  TrackImportOptions({
    required this.defaultSegmentName,
    required this.trackDirection,
  });

  // Create a default instance
  factory TrackImportOptions.defaults() {
    return TrackImportOptions(
      defaultSegmentName: 'New Segment',
      trackDirection: TrackDirection.forward,
    );
  }

  // Create a copy with modified fields
  TrackImportOptions copyWith({
    String? defaultSegmentName,
    TrackDirection? trackDirection,
  }) {
    return TrackImportOptions(
      defaultSegmentName: defaultSegmentName ?? this.defaultSegmentName,
      trackDirection: trackDirection ?? this.trackDirection,
    );
  }
} 