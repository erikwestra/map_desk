// Model class for items that can be selected in the left panel
import 'package:flutter/material.dart';

enum SelectableItemType {
  file,
  segment,
}

class SelectableItem {
  final String id;
  final String title;
  final SelectableItemType type;
  final dynamic data; // The actual data (SimpleGpxTrack or Segment)

  const SelectableItem({
    required this.id,
    required this.title,
    required this.type,
    required this.data,
  });

  // Factory constructor for file items
  factory SelectableItem.file(String id, String title, dynamic data) {
    return SelectableItem(
      id: id,
      title: title,
      type: SelectableItemType.file,
      data: data,
    );
  }

  // Factory constructor for segment items
  factory SelectableItem.segment(String id, String title, dynamic data) {
    return SelectableItem(
      id: id,
      title: title,
      type: SelectableItemType.segment,
      data: data,
    );
  }
} 