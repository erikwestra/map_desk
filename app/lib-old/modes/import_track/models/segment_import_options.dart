/// Model for segment import options
enum SegmentDirection {
  oneWay,
  bidirectional,
}

class SegmentImportOptions {
  final String segmentName;
  final SegmentDirection direction;
  final int nextSegmentNumber;
  
  const SegmentImportOptions({
    required this.segmentName,
    required this.direction,
    required this.nextSegmentNumber,
  });

  // Create a default instance
  factory SegmentImportOptions.defaults() {
    return const SegmentImportOptions(
      segmentName: '',
      direction: SegmentDirection.oneWay,
      nextSegmentNumber: 1,
    );
  }

  // Create a copy with modified fields
  SegmentImportOptions copyWith({
    String? segmentName,
    SegmentDirection? direction,
    int? nextSegmentNumber,
  }) {
    return SegmentImportOptions(
      segmentName: segmentName ?? this.segmentName,
      direction: direction ?? this.direction,
      nextSegmentNumber: nextSegmentNumber ?? this.nextSegmentNumber,
    );
  }
} 