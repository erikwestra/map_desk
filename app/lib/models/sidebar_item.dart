/// Represents an item that can be displayed in a sidebar
class SidebarItem {
  final String type;      // e.g., 'current_track', 'segment'
  final dynamic value;     // The value for this item (e.g., segment ID, track name)
  final bool selectable;  // Whether this item can be selected

  const SidebarItem({
    required this.type,
    required this.value,
    this.selectable = true,
  });
} 