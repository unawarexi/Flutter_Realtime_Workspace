import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'package:flutter_realtime_workspace/core/network/pull_refresh.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Wrap the app with GlobalRefreshWrapper for app-wide pull-to-refresh
  runApp(
    const GlobalRefreshWrapper(
      child: App(),
    ),
  );
}
