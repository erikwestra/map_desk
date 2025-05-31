// Model class for items that can be selected in the left panel
import 'package:flutter/material.dart';
import '../../../core/models/segment.dart';
import '../../../core/models/simple_gpx_track.dart';

enum SelectableItemType {
  file,
  segment,
}

class SelectableItem {
  final String id;
  final String name;
  final SelectableItemType type;
  final dynamic data; // The actual data (SimpleGpxTrack or Segment)

  const SelectableItem({
    required this.id,
    required this.name,
    required this.type,
    required this.data,
  });

  // Factory constructor for file items
  factory SelectableItem.file(String id, String name, SimpleGpxTrack track) {
    return SelectableItem(
      id: id,
      name: name,
      type: SelectableItemType.file,
      data: track,
    );
  }

  // Factory constructor for segment items
  factory SelectableItem.segment(String id, String name, Segment segment) {
    return SelectableItem(
      id: id,
      name: name,
      type: SelectableItemType.segment,
      data: segment,
    );
  }
} 