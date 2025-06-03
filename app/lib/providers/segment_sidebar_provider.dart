import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:map_desk/core/services/segment_service.dart';
import 'package:map_desk/services/segment_sidebar_service.dart';

/// Provider setup for the segment sidebar service.
class SegmentSidebarProvider extends StatelessWidget {
  final Widget child;

  const SegmentSidebarProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SegmentSidebarService(
        context.read<SegmentService>(),
      ),
      child: child,
    );
  }
} 