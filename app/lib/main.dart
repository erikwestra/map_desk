import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/mode_service.dart';
import 'services/layout_service.dart';
import 'services/menu_service.dart';
import 'services/database_service.dart';
import 'services/segment_service.dart';
import 'services/map_view_service.dart';
import 'services/segment_sidebar_service.dart';
import 'services/segment_import_service.dart';
import 'services/segment_export_service.dart';
import 'services/route_sidebar_service.dart';
import 'interfaces/mode_ui_context.dart';
import 'widgets/map_view.dart';
import 'widgets/status_bar.dart';
import 'widgets/segment_sidebar.dart';
import 'widgets/route_sidebar.dart';
import 'mode_controllers/browse_mode_controller.dart';
import 'mode_controllers/create_mode_controller.dart';
import 'mode_controllers/import_mode_controller.dart';
import 'mode_controllers/view_mode_controller.dart';
import 'services/status_bar_service.dart';

/// Global navigator key for accessing context from actions
final navigatorKey = GlobalKey<NavigatorState>();

/// Service provider that manages the lifecycle of our services
class ServiceProvider extends ChangeNotifier {
  late final DatabaseService databaseService;
  late final SegmentService segmentService;
  late final MapViewService mapViewService;
  late final StatusBarService statusBarService;
  late final SegmentSidebarService segmentSidebarService;
  late final SegmentImportService segmentImportService;
  late final SegmentExportService segmentExportService;
  late final ModeService modeService;
  late final RouteSidebarService routeSidebarService;

  ServiceProvider() {
    databaseService = DatabaseService();
    segmentService = SegmentService(databaseService);
    mapViewService = MapViewService();
    statusBarService = StatusBarService();
    segmentSidebarService = SegmentSidebarService(segmentService);
    segmentImportService = SegmentImportService(databaseService);
    segmentExportService = SegmentExportService();
    modeService = ModeService();
    routeSidebarService = RouteSidebarService();
  }

  /// Initialize all services
  Future<void> initialize() async {
    try {
      await databaseService.database;
    } catch (e, stackTrace) {
      rethrow;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final serviceProvider = ServiceProvider();
  await serviceProvider.initialize();

  // Create shared UI context
  final uiContext = ModeUIContext.defaultContext(
    modeService: serviceProvider.modeService,
    mapViewService: serviceProvider.mapViewService,
    statusBarService: serviceProvider.statusBarService,
    segmentSidebarService: serviceProvider.segmentSidebarService,
    routeSidebarService: serviceProvider.routeSidebarService,
  );

  // Create mode controllers
  final viewModeController = ViewModeController(uiContext);
  final importModeController = ImportModeController(uiContext);
  final browseModeController = BrowseModeController(uiContext);
  final createModeController = CreateModeController(uiContext);

  // Initialize mode service with controllers
  serviceProvider.modeService.initializeControllers({
    'View': viewModeController,
    'Import': importModeController,
    'Browse': browseModeController,
    'Create': createModeController,
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: serviceProvider),
        ChangeNotifierProvider.value(value: serviceProvider.modeService),
        ChangeNotifierProvider(create: (_) => LayoutService()),
        ChangeNotifierProvider(create: (_) => MenuService()),
        ChangeNotifierProvider.value(value: serviceProvider.mapViewService),
        ChangeNotifierProvider.value(value: serviceProvider.statusBarService),
        ChangeNotifierProvider.value(value: serviceProvider.segmentSidebarService),
        ChangeNotifierProvider.value(value: serviceProvider.routeSidebarService),
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
      navigatorKey: navigatorKey,
      title: 'MapDesk',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MapDeskHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapDeskHome extends StatelessWidget {
  const MapDeskHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ModeService, LayoutService, MapViewService>(
      builder: (context, modeService, layoutService, mapViewService, child) {
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
                  SegmentSidebar(),
                const Expanded(
                  child: MapView(),
                ),
                if (currentMode.showRightSidebar)
                  RouteSidebar(),
              ],
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: const StatusBar(),
                  ),
                  // Mode selector
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SegmentedButton<String>(
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
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final modeService = context.read<ModeService>();
    final currentMode = modeService.currentMode;
    if (currentMode == null) return;

    currentMode.handleEvent('menu_open', null);
  }
}

class SaveRouteAction extends Action<SaveRouteIntent> {
  @override
  void invoke(SaveRouteIntent intent) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final modeService = context.read<ModeService>();
    final currentMode = modeService.currentMode;
    if (currentMode == null) return;

    currentMode.handleEvent('menu_save_route', null);
  }
}

class UndoAction extends Action<UndoIntent> {
  @override
  void invoke(UndoIntent intent) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final modeService = context.read<ModeService>();
    final currentMode = modeService.currentMode;
    if (currentMode == null) return;

    currentMode.handleEvent('menu_undo', null);
  }
}

class ClearTrackAction extends Action<ClearTrackIntent> {
  @override
  void invoke(ClearTrackIntent intent) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final modeService = context.read<ModeService>();
    final currentMode = modeService.currentMode;
    if (currentMode == null) return;

    currentMode.handleEvent('menu_clear_track', null);
  }
}

class ViewModeAction extends Action<ViewModeIntent> {
  @override
  void invoke(ViewModeIntent intent) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final modeService = context.read<ModeService>();
    modeService.switchMode('View');
  }
}

class ImportModeAction extends Action<ImportModeIntent> {
  @override
  void invoke(ImportModeIntent intent) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final modeService = context.read<ModeService>();
    modeService.switchMode('Import');
  }
}

class BrowseModeAction extends Action<BrowseModeIntent> {
  @override
  void invoke(BrowseModeIntent intent) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final modeService = context.read<ModeService>();
    modeService.switchMode('Browse');
  }
}

class CreateModeAction extends Action<CreateModeIntent> {
  @override
  void invoke(CreateModeIntent intent) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final modeService = context.read<ModeService>();
    modeService.switchMode('Create');
  }
}

class QuitAction extends Action<QuitIntent> {
  @override
  void invoke(QuitIntent intent) {
    SystemNavigator.pop();
  }
}
