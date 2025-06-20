import 'package:go_router/go_router.dart';
import 'package:qoe_app/routes/navigation_keys.dart';
import 'package:qoe_app/routes/route_names.dart';
import 'package:qoe_app/screens/onboarding/onboarding_screen.dart';
import 'package:qoe_app/screens/settings/settings_screen.dart';
import 'package:qoe_app/screens/speed_test/speed_test_screen.dart';
import 'package:qoe_app/screens/splash.dart';
import 'package:qoe_app/screens/wrapper.dart';
import 'package:qoe_app/widgets/dashboard.dart';

class RouterClass {
  static RouterClass? _instance;

  RouterClass._();

  static RouterClass get instance {
    _instance ??= RouterClass._();
    return _instance!;
  }

  GoRouter getRoutes() {
    return GoRouter(
      debugLogDiagnostics: true,
      initialLocation: RoutePath.home,
      navigatorKey: rootNavigatorKey,
      redirect: (context, state) async {
        return null;
      },
      routes: [
        GoRoute(
          path: RoutePath.splash,
          builder: (context, state) {
            return const SplashScreen();
          },
        ),
        GoRoute(
          path: RoutePath.onboarding,
          builder: (context, state) {
            return const OnboardingScreen();
          },
        ),

        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return Wrapper(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              navigatorKey: shellNavigator1Key,
              routes: [
                GoRoute(
                  path: RoutePath.home,
                  builder: (context, state) {
                    return const NetworkDashboardScreen();
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: shellNavigatorKey,
              routes: [
                GoRoute(
                  name: RoutePath.speedTest,
                  path: RoutePath.speedTest,
                  builder: (context, state) {
                    return const SpeedTestScreen();
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: shellNavigator2Key,
              routes: [
                GoRoute(
                  name: RoutePath.settings,
                  path: RoutePath.settings,
                  builder: (context, state) {
                    return const SettingsScreen();
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  GoRouter get routes => getRoutes();
}
