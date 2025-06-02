import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/services/mode_service.dart';
import 'core/services/layout_service.dart';
import 'core/services/menu_service.dart';
import 'modes/view/view_mode_controller.dart';
import 'modes/import/import_mode_controller.dart';
import 'modes/browse/browse_mode_controller.dart';
import 'modes/create/create_mode_controller.dart';

void main() {
  final modeService = ModeService();
  final layoutService = LayoutService();
  
  // Register all mode controllers
  modeService.registerMode(ViewModeController());
  modeService.registerMode(ImportModeController());
  modeService.registerMode(BrowseModeController());
  modeService.registerMode(CreateModeController());
  
  // Start in View mode
  modeService.switchMode('View');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: modeService),
        ChangeNotifierProvider.value(value: layoutService),
      ],
      child: const MapDeskApp(),
    ),
  );
}

class MapDeskApp extends StatelessWidget {
  const MapDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MapDesk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MapDeskHome(),
    );
  }
}

class MapDeskHome extends StatelessWidget {
  const MapDeskHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ModeService, LayoutService>(
      builder: (context, modeService, layoutService, child) {
        final currentMode = modeService.currentMode;
        if (currentMode == null) {
          return const Center(child: Text('No mode selected'));
        }

        return PlatformMenuBar(
          menus: MenuService.buildMenuBar(context),
          child: Scaffold(
            body: Row(
              children: [
                if (currentMode.showLeftSidebar)
                  SizedBox(
                    width: 250,
                    child: currentMode.buildLeftSidebar(context),
                  ),
                Expanded(
                  child: currentMode.buildMapContent(context),
                ),
                if (currentMode.showRightSidebar)
                  SizedBox(
                    width: 250,
                    child: currentMode.buildRightSidebar(context),
                  ),
              ],
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Mode-specific status bar content
                  currentMode.buildStatusBarContent(context),
                  // Mode selector
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'View', label: Text('View')),
                      ButtonSegment(value: 'Import', label: Text('Import')),
                      ButtonSegment(value: 'Browse', label: Text('Browse')),
                      ButtonSegment(value: 'Create', label: Text('Create')),
                    ],
                    selected: {currentMode.modeName},
                    onSelectionChanged: (Set<String> selection) {
                      if (selection.isNotEmpty) {
                        modeService.switchMode(selection.first);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class MapDeskScaffold extends StatelessWidget {
  final Widget child;

  const MapDeskScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        // File menu shortcuts
        const SingleActivator(LogicalKeyboardKey.keyO, meta: true): OpenFileIntent(),
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true): SaveRouteIntent(),
        
        // Edit menu shortcuts
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true): UndoIntent(),
        const SingleActivator(LogicalKeyboardKey.backspace, meta: true): ClearTrackIntent(),
        
        // Mode menu shortcuts
        const SingleActivator(LogicalKeyboardKey.digit1, meta: true): ViewModeIntent(),
        const SingleActivator(LogicalKeyboardKey.digit2, meta: true): ImportModeIntent(),
        const SingleActivator(LogicalKeyboardKey.digit3, meta: true): BrowseModeIntent(),
        const SingleActivator(LogicalKeyboardKey.digit4, meta: true): CreateModeIntent(),
        
        // Quit shortcut
        const SingleActivator(LogicalKeyboardKey.keyQ, meta: true): QuitIntent(),
      },
      child: Actions(
        actions: {
          OpenFileIntent: OpenFileAction(),
          SaveRouteIntent: SaveRouteAction(),
          UndoIntent: UndoAction(),
          ClearTrackIntent: ClearTrackAction(),
          ViewModeIntent: ViewModeAction(),
          ImportModeIntent: ImportModeAction(),
          BrowseModeIntent: BrowseModeAction(),
          CreateModeIntent: CreateModeAction(),
          QuitIntent: QuitAction(),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: child,
          ),
        ),
      ),
    );
  }
}

// Intent classes
class OpenFileIntent extends Intent {}
class SaveRouteIntent extends Intent {}
class UndoIntent extends Intent {}
class ClearTrackIntent extends Intent {}
class ViewModeIntent extends Intent {}
class ImportModeIntent extends Intent {}
class BrowseModeIntent extends Intent {}
class CreateModeIntent extends Intent {}
class QuitIntent extends Intent {}

// Action classes
class OpenFileAction extends Action<OpenFileIntent> {
  @override
  void invoke(OpenFileIntent intent) {
    // TODO: Implement file open
  }
}

class SaveRouteAction extends Action<SaveRouteIntent> {
  @override
  void invoke(SaveRouteIntent intent) {
    // TODO: Implement save route
  }
}

class UndoAction extends Action<UndoIntent> {
  @override
  void invoke(UndoIntent intent) {
    // TODO: Implement undo
  }
}

class ClearTrackAction extends Action<ClearTrackIntent> {
  @override
  void invoke(ClearTrackIntent intent) {
    // TODO: Implement clear track
  }
}

class ViewModeAction extends Action<ViewModeIntent> {
  @override
  void invoke(ViewModeIntent intent) {
    // TODO: Switch to View mode
  }
}

class ImportModeAction extends Action<ImportModeIntent> {
  @override
  void invoke(ImportModeIntent intent) {
    // TODO: Switch to Import mode
  }
}

class BrowseModeAction extends Action<BrowseModeIntent> {
  @override
  void invoke(BrowseModeIntent intent) {
    // TODO: Switch to Browse mode
  }
}

class CreateModeAction extends Action<CreateModeIntent> {
  @override
  void invoke(CreateModeIntent intent) {
    // TODO: Switch to Create mode
  }
}

class QuitAction extends Action<QuitIntent> {
  @override
  void invoke(QuitIntent intent) {
    SystemNavigator.pop();
  }
}
