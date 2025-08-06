
import 'package:base_architecture/src/features/auth/presentation/view/sign_in_screen.dart';
import 'package:base_architecture/src/shared/constants/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lifecycle/lifecycle.dart';
import '../../features/splash/presentation/view/splash_screen.dart';

import '../../shared/widgets/page_not_found.dart';

class NavigationManager {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  final GoRouter router = GoRouter(
    initialLocation: '/',
    navigatorKey: navigatorKey,
    observers: [
      GoRouterObserver(),
      defaultLifecycleObserver,
    ],
    errorBuilder: (final context, final state) => const PageNotFound(),
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: RouteConst.splashScreen,
        builder: (_, _) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/signIn',
        name: RouteConst.signInScreen,
        builder: (_, _) {
          return const SignInScreen();
        },
      ),


    ],
  );
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

/// MARK: - Observing Navigation Stack
class GoRouterObserver extends NavigatorObserver {
  @override
  void didPush(final Route<dynamic> route, final Route<dynamic>? previousRoute) {
    debugPrint('Pushed: ${route.settings.name}, with arguments: ${route.settings.arguments}');
  }

  @override
  void didPop(final Route<dynamic> route, final Route<dynamic>? previousRoute) {
    debugPrint('Popped: ${route.settings.name}, with arguments: ${route.settings.arguments}');
  }

  @override
  void didRemove(final Route<dynamic> route, final Route<dynamic>? previousRoute) {
    debugPrint('Removed: ${route.settings.name}, with arguments: ${route.settings.arguments}');
  }

  @override
  void didReplace({final Route<dynamic>? newRoute, final Route<dynamic>? oldRoute}) {
    debugPrint('Replaced: ${newRoute?.settings.name}, with arguments: ${newRoute?.settings.arguments}');
  }
}
