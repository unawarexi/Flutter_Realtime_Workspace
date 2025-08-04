import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'package:flutter_realtime_workspace/core/network/pull_refresh.dart';
import "splash_screen.dart";

// Global keys for app-wide access
class GlobalKeys {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
}

// Global refresh wrapper that provides refresh functionality to entire app
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

// Provider for sharing refresh functionality
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

// Root app wrapper that includes MaterialApp and splash screen
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
  // Initialize network module with retry config and baseUrl from env
  // NetworkModule.initialize(
  //   baseUrl: Environment.baseUrl,
  //   retryConfig: RetryPresets.aggressive,
  // );

  // Now the splash screen is inside MaterialApp context
  runApp(const RootApp());
}
