import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'mode_service.dart';
import '../main.dart';
import 'segment_import_service.dart';
import 'segment_export_service.dart';
import 'database_service.dart';

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
    final serviceProvider = context.read<ServiceProvider>();

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
                onSelected: () async {
                  // Show confirmation dialog
                  final shouldReset = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset Database'),
                      content: const Text('Are you sure you want to delete all segments? This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.error,
                          ),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );

                  if (shouldReset == true) {
                    try {
                      await serviceProvider.databaseService.deleteAllSegments();
                      // Refresh the segment list in the sidebar
                      await serviceProvider.segmentSidebarService.refreshSegments();
                    } catch (e) {
                      print('MenuService: Failed to reset database: $e');
                      // TODO: Show error message to user
                    }
                  }
                },
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'Export Segments',
                onSelected: () async {
                  try {
                    final segments = await serviceProvider.segmentService.getAllSegments();
                    if (segments.isEmpty) {
                      // Show message that there are no segments to export
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Export Segments'),
                            content: const Text('There are no segments to export.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                      return;
                    }

                    final exportService = SegmentExportService();
                    await exportService.exportToGeoJSON(segments);
                  } catch (e) {
                    print('MenuService: Failed to export segments: $e');
                    // TODO: Show error message to user
                  }
                },
              ),
              PlatformMenuItem(
                label: 'Import Segments',
                onSelected: () async {
                  try {
                    final importService = SegmentImportService(serviceProvider.databaseService);
                    await importService.importFromGeoJSON(context);
                    // Refresh the segment list in the sidebar
                    await serviceProvider.segmentSidebarService.refreshSegments();
                  } catch (e) {
                    print('MenuService: Failed to import segments: $e');
                    // TODO: Show error message to user
                  }
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