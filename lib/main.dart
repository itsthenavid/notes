import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/note_provider.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'utils/app_logger.dart';
import 'constants/app_constants.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeApp();

  final noteProvider = await _initializeProviders();

  runApp(
    ChangeNotifierProvider.value(
      value: noteProvider,
      child: const NotesApp(),
    ),
  );
}

Future<void> _initializeApp() async {
  try {
    AppLogger.section('App Initialization');

    await _setupSystemUI();
    await _initializeServices();

    AppLogger.success('App initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize app', e, stackTrace);
  }
}

Future<void> _setupSystemUI() async {
  try {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    AppLogger.info('System UI configured');
  } catch (e) {
    AppLogger.error('Failed to setup system UI', e);
  }
}

Future<void> _initializeServices() async {
  try {
    final storage = StorageService.instance;
    await storage.init();
    AppLogger.success('Storage service initialized');
  } catch (e) {
    AppLogger.error('Failed to initialize services', e);
  }
}

Future<NoteProvider> _initializeProviders() async {
  try {
    final noteProvider = NoteProvider();
    await noteProvider.init();
    AppLogger.success('Note provider initialized');
    return noteProvider;
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize providers', e, stackTrace);
    return NoteProvider();
  }
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      scrollBehavior: const CustomScrollBehavior(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  const CustomScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.unknown,
      };

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}
