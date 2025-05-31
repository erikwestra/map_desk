/// Model for segment import options
enum SegmentDirection {
  oneWay,
  bidirectional,
}

class SegmentImportOptions {
  final String segmentName;
  final SegmentDirection direction;
  
  const SegmentImportOptions({
    required this.segmentName,
    required this.direction,
  });

  // Create a default instance
  factory SegmentImportOptions.defaults() {
    return const SegmentImportOptions(
      segmentName: '',
      direction: SegmentDirection.oneWay,
    );
  }

  // Create a copy with modified fields
  SegmentImportOptions copyWith({
    String? segmentName,
    SegmentDirection? direction,
  }) {
    return SegmentImportOptions(
      segmentName: segmentName ?? this.segmentName,
      direction: direction ?? this.direction,
    );
  }
} 