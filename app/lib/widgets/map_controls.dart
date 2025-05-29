import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapControls extends StatelessWidget {
  final MapController mapController;

  const MapControls({
    super.key,
    required this.mapController,
  });

  void _onZoomIn() {
    final currentZoom = mapController.zoom;
    mapController.move(mapController.center, currentZoom + 1);
  }

  void _onZoomOut() {
    final currentZoom = mapController.zoom;
    mapController.move(mapController.center, currentZoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          _MapControlButton(
            icon: Icons.add,
            onPressed: _onZoomIn,
          ),
          const SizedBox(height: 8),
          _MapControlButton(
            icon: Icons.remove,
            onPressed: _onZoomOut,
          ),
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MapControlButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 18,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
} 