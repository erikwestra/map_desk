import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'mode_service.dart';

/// Service that manages the application menu bar.
class MenuService {
  /// Builds the application menu bar
  static List<PlatformMenu> buildMenuBar(BuildContext context) {
    final currentMode = context.read<ModeService>().currentMode?.modeName;

    return [
      // MapDesk menu
      PlatformMenu(
        label: 'MapDesk',
        menus: [
          PlatformMenuItem(
            label: 'Quit',
            shortcut: const SingleActivator(LogicalKeyboardKey.keyQ, meta: true),
            onSelected: () => SystemNavigator.pop(),
          ),
        ],
      ),
      
      // File menu
      PlatformMenu(
        label: 'File',
        menus: [
          PlatformMenuItem(
            label: 'Open',
            shortcut: const SingleActivator(LogicalKeyboardKey.keyO, meta: true),
            onSelected: () {
              // TODO: Implement file open
            },
          ),
          PlatformMenuItem(
            label: 'Save Route',
            shortcut: const SingleActivator(LogicalKeyboardKey.keyS, meta: true),
            onSelected: () {
              // TODO: Implement save route
            },
          ),
        ],
      ),
      
      // Edit menu
      PlatformMenu(
        label: 'Edit',
        menus: [
          PlatformMenuItem(
            label: 'Undo',
            shortcut: const SingleActivator(LogicalKeyboardKey.keyZ, meta: true),
            onSelected: () {
              // TODO: Implement undo
            },
          ),
          PlatformMenuItem(
            label: 'Clear Track',
            shortcut: const SingleActivator(LogicalKeyboardKey.backspace, meta: true),
            onSelected: () {
              // TODO: Implement clear track
            },
          ),
        ],
      ),
      
      // Mode menu
      PlatformMenu(
        label: 'Mode',
        menus: [
          PlatformMenuItem(
            label: 'View Map',
            shortcut: const SingleActivator(LogicalKeyboardKey.digit1, meta: true),
            onSelected: () {
              context.read<ModeService>().switchMode('View');
            },
          ),
          PlatformMenuItem(
            label: 'Import Track',
            shortcut: const SingleActivator(LogicalKeyboardKey.digit2, meta: true),
            onSelected: () {
              context.read<ModeService>().switchMode('Import');
            },
          ),
          PlatformMenuItem(
            label: 'Browse Segments',
            shortcut: const SingleActivator(LogicalKeyboardKey.digit3, meta: true),
            onSelected: () {
              context.read<ModeService>().switchMode('Browse');
            },
          ),
          PlatformMenuItem(
            label: 'Create Route',
            shortcut: const SingleActivator(LogicalKeyboardKey.digit4, meta: true),
            onSelected: () {
              context.read<ModeService>().switchMode('Create');
            },
          ),
        ],
      ),
      
      // Database menu
      PlatformMenu(
        label: 'Database',
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'Reset Database',
                onSelected: () {
                  // TODO: Implement reset database
                },
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'Export Segments',
                onSelected: () {
                  // TODO: Implement export segments
                },
              ),
              PlatformMenuItem(
                label: 'Import Segments',
                onSelected: () {
                  // TODO: Implement import segments
                },
              ),
            ],
          ),
        ],
      ),
      
      // Window menu
      PlatformMenu(
        label: 'Window',
        menus: [
          PlatformMenuItem(
            label: 'MapDesk',
            onSelected: () {
              // TODO: Implement window focus
            },
          ),
        ],
      ),
    ];
  }
} 