import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_realtime_workspace/global/notification_provider.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'package:flutter_realtime_workspace/core/network/pull_refresh.dart';
import "splash_screen.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';


//------------------------------------- Global keys for app-wide access
class GlobalKeys {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
}

//------------------------------- Global refresh wrapper that provides refresh functionality to entire app
class GlobalRefreshWrapper extends StatefulWidget {
  final Widget child;
  const GlobalRefreshWrapper({super.key, required this.child});

  @override
  State<GlobalRefreshWrapper> createState() => _GlobalRefreshWrapperState();
}

class _GlobalRefreshWrapperState extends State<GlobalRefreshWrapper> {
  final GlobalRefreshController _globalController = GlobalRefreshController();

  @override
  void dispose() {
    _globalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshProvider(
      controller: _globalController,
      child: widget.child,
    );
  }
}

//-------------------------------- Provider for sharing refresh functionality
class RefreshProvider extends InheritedWidget {
  final GlobalRefreshController controller;

  const RefreshProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  static RefreshProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RefreshProvider>();
  }

  @override
  bool updateShouldNotify(RefreshProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}

//------------------------------------- Root app wrapper that includes MaterialApp and splash screen
class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeamSpot',
      navigatorKey: GlobalKeys.navigatorKey,
      scaffoldMessengerKey: GlobalKeys.scaffoldMessengerKey,
      theme: ThemeData(
        primaryColor: const Color(0xFF0A0E1A),
        scaffoldBackgroundColor: const Color(0xFFE2E8F0),
        // Add other theme properties as needed
      ),
      home: const TeamSpotSplashScreen(
        nextScreen: GlobalRefreshWrapper(
          child: App(),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

//======================================== Main entry point for the app
// Initializes Firebase, app check, and starts the app with Riverpod provider scope
// Also loads environment variables from .env file
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  runApp(
    const ProviderScope(
      child: _AppInitializer(),
    ),
  );
}

//------------------------------------- App initializer that handles async initialization
// This is separated to avoid async gaps in the main widget tree
// It initializes the notification service and sets up the app state
class _AppInitializer extends ConsumerStatefulWidget {
  const _AppInitializer({super.key});

  @override
  ConsumerState<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<_AppInitializer> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    await ref.read(notificationProvider.notifier).initialize();
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return const RootApp();
  }
}
  
  // Initialize network module with retry config and baseUrl from env
  // NetworkModule.initialize(
  //   baseUrl: Environment.baseUrl,
  //   retryConfig: RetryPresets.aggressive,
  // );

