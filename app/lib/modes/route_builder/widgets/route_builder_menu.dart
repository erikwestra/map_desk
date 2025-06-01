// Menu items for the route builder mode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/route_builder_service.dart';

class RouteBuilderMenu {
  static PlatformMenu buildMenu(BuildContext context) {
    return PlatformMenu(
      label: 'Route',
      menus: [
        PlatformMenuItem(
          label: 'Undo',
          shortcut: const SingleActivator(LogicalKeyboardKey.keyZ, meta: true),
          onSelected: () {
            context.read<RouteBuilderService>().undo();
          },
        ),
        PlatformMenuItem(
          label: 'Add Segment',
          shortcut: const SingleActivator(LogicalKeyboardKey.enter),
          onSelected: () {
            final routeBuilder = context.read<RouteBuilderService>();
            if (routeBuilder.selectedSegment != null) {
              routeBuilder.addSelectedSegmentToRoute();
            }
          },
        ),
        PlatformMenuItem(
          label: 'Save Track',
          shortcut: const SingleActivator(LogicalKeyboardKey.keyS, meta: true),
          onSelected: () {
            context.read<RouteBuilderService>().save();
          },
        ),
        PlatformMenuItem(
          label: 'Clear Track',
          shortcut: const SingleActivator(LogicalKeyboardKey.keyK, meta: true),
          onSelected: () {
            context.read<RouteBuilderService>().clear();
          },
        ),
      ],
    );
  }
} 