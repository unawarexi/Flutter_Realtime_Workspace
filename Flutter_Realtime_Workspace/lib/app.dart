import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_realtime_workspace/core/config/themes/app_theme.dart';
import 'package:flutter_realtime_workspace/features/authentication/presentation/login.dart';
import 'package:flutter_realtime_workspace/screens/onboarding_screens/onboarding_screens.dart';
import 'package:flutter_realtime_workspace/shared/components/custom_bottom_navigiation.dart';
import 'package:flutter_realtime_workspace/shared/styles/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_realtime_workspace/core/services/storage_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: TAppTheme.lightTheme,
        darkTheme: TAppTheme.darkTheme,
        builder: (context, child) {
          final Brightness brightness =
              MediaQuery.of(context).platformBrightness;

          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: brightness == Brightness.dark
                  ? TColors.backgroundDarkAlt
                  : TColors.backgroundLight,
              statusBarIconBrightness: brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
              statusBarBrightness: brightness == Brightness.dark
                  ? Brightness.dark
                  : Brightness.light,
            ),
          );
          return child!;
        },
        home: FutureBuilder<bool>(
          future: StorageService.isAuthenticated(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show splash/loading
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.data == true) {
              // User is authenticated, go to main app
              return const BottomNavigationBarWidget();
            }
            // Not authenticated, show onboarding
            return const OnboardingScreen();
          },
        ),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/onboarding':
              return MaterialPageRoute(
                builder: (context) => const OnboardingScreen(),
              );
            case '/signup':
              return MaterialPageRoute(
                builder: (context) => const Authentication(),
              );
            case '/home':
              return MaterialPageRoute(
                builder: (context) => const BottomNavigationBarWidget(),
              );
            default:
              return MaterialPageRoute(
                builder: (context) => const OnboardingScreen(),
              );
          }
        },
      ),
    );
  }
}
