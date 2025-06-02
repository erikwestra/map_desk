import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'mode_service.dart';

/// Service that manages the application menu bar.
class MenuService extends ChangeNotifier {
  /// Menu item IDs for consistent reference
  static const String menuItemQuit = 'quit';
  static const String menuItemOpen = 'open';
  static const String menuItemSaveRoute = 'save_route';
  static const String menuItemUndo = 'undo';
  static const String menuItemClearTrack = 'clear_track';
  static const String menuItemViewMap = 'view_map';
  static const String menuItemImportTrack = 'import_track';
  static const String menuItemBrowseSegments = 'browse_segments';
  static const String menuItemCreateRoute = 'create_route';
  static const String menuItemResetDatabase = 'reset_database';
  static const String menuItemExportSegments = 'export_segments';
  static const String menuItemImportSegments = 'import_segments';

  /// Builds the application menu bar
  static List<PlatformMenu> buildMenuBar(BuildContext context) {
    final modeService = context.read<ModeService>();
    final currentMode = modeService.currentMode;

    return [
      // MapDesk menu
      PlatformMenu(
        label: 'MapDesk',
        menus: [
          PlatformMenuItem(
            label: 'Quit',
            shortcut: const SingleActivator(LogicalKeyboardKey.keyQ, meta: true),
            onSelected: () {
              SystemNavigator.pop();
            },
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
              currentMode?.handleEvent('menu_open', null);
            },
          ),
          PlatformMenuItem(
            label: 'Save Route',
            shortcut: const SingleActivator(LogicalKeyboardKey.keyS, meta: true),
            onSelected: () {
              currentMode?.handleEvent('menu_save_route', null);
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
              currentMode?.handleEvent('menu_undo', null);
            },
          ),
          PlatformMenuItem(
            label: 'Clear Track',
            shortcut: const SingleActivator(LogicalKeyboardKey.backspace, meta: true),
            onSelected: () {
              currentMode?.handleEvent('menu_clear_track', null);
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
            onSelected: () => modeService.switchMode('View'),
          ),
          PlatformMenuItem(
            label: 'Import Track',
            shortcut: const SingleActivator(LogicalKeyboardKey.digit2, meta: true),
            onSelected: () => modeService.switchMode('Import'),
          ),
          PlatformMenuItem(
            label: 'Browse Segments',
            shortcut: const SingleActivator(LogicalKeyboardKey.digit3, meta: true),
            onSelected: () => modeService.switchMode('Browse'),
          ),
          PlatformMenuItem(
            label: 'Create Route',
            shortcut: const SingleActivator(LogicalKeyboardKey.digit4, meta: true),
            onSelected: () => modeService.switchMode('Create'),
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
              // No-op, just shows the window name
            },
          ),
        ],
      ),
    ];
  }
} 