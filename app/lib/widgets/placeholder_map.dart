import 'package:flutter/material.dart';
import '../models/gpx_track.dart';

/// Placeholder widget for the map area in Phase 1
class PlaceholderMap extends StatelessWidget {
  final GpxTrack? loadedTrack;
  final String? errorMessage;

  const PlaceholderMap({
    super.key,
    this.loadedTrack,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF5F5F5), // Light gray background
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main placeholder text
            const Text(
              'Map goes here',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: Color(0xFF8E8E93), // Medium gray
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Status information
            if (errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (loadedTrack != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'GPX file loaded successfully',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1C1C1E), // Dark gray
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTrackInfo(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrackInfo() {
    if (loadedTrack == null) return const SizedBox.shrink();

    return Column(
      children: [
        _buildInfoRow('Track Name:', loadedTrack!.name),
        const SizedBox(height: 4),
        _buildInfoRow('Track Points:', loadedTrack!.info),
        if (loadedTrack!.description != null) ...[
          const SizedBox(height: 4),
          _buildInfoRow('Description:', loadedTrack!.description!),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8E8E93), // Medium gray
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1C1C1E), // Dark gray
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
} 