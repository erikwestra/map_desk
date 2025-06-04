import 'segment.dart';

/// Represents a segment that is part of a route, along with its direction
class SegmentInRoute {
  final Segment segment;
  final String direction;  // "forward" or "backward"

  SegmentInRoute(this.segment, this.direction);
} 