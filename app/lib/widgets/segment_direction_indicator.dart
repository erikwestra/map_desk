import 'package:flutter/material.dart';

/// A widget that displays the direction of a segment using a line with arrowheads.
/// Shows a green dot at start and red dot at end, with arrow(s) indicating direction.
/// Direction can be:
/// - 'oneWay': shows right arrow only
/// - 'backward': shows left arrow only
/// - 'bidirectional': shows both arrows
class SegmentDirectionIndicator extends StatelessWidget {
  final String direction;
  final double size;

  const SegmentDirectionIndicator({
    super.key,
    required this.direction,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    const grayColor = Color(0xFF757575); // Mid gray color

    Widget directionIndicator;
    if (direction == 'oneWay') {
      // For oneWay segments, show forward direction
      directionIndicator = Positioned(
        right: 5,
        top: 8,
        child: Icon(
          Icons.arrow_forward,
          size: 16,
          color: grayColor,
        ),
      );
    } else if (direction == 'backward') {
      directionIndicator = Positioned(
        left: 6,
        top: 8,
        child: Icon(
          Icons.arrow_back,
          size: 16,
          color: grayColor,
        ),
      );
    } else if (direction == 'bidirectional') {
      directionIndicator = Stack(
        children: [
          Positioned(
            left: 6,
            top: 8,
            child: Icon(
              Icons.arrow_back,
              size: 16,
              color: grayColor,
            ),
          ),
          Positioned(
            right: 5,
            top: 8,
            child: Icon(
              Icons.arrow_forward,
              size: 16,
              color: grayColor,
            ),
          ),
        ],
      );
    } else {
      directionIndicator = const SizedBox.shrink();
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Main line
          Center(
            child: Container(
              height: 2,
              width: 32,
              color: grayColor,
            ),
          ),
          // Start dot (green)
          Positioned(
            left: 0,
            top: 12,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // End dot (red)
          Positioned(
            right: 0,
            top: 12,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Direction indicators
          directionIndicator,
        ],
      ),
    );
  }
} 