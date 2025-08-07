
import 'dart:async';

import 'package:base_architecture/src/app/router/route_const.dart';
import 'package:base_architecture/src/features/auth/presentation/view/setup_user_page.dart';
import 'package:base_architecture/src/features/auth/presentation/view/sign_in_screen.dart';
import 'package:base_architecture/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:base_architecture/src/features/home/presentation/view/add_doctor_page.dart';
import 'package:base_architecture/src/features/home/presentation/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lifecycle/lifecycle.dart';
import '../../features/splash/presentation/view/splash_screen.dart';

import '../../services/service_locator.dart';
import '../../shared/widgets/page_not_found.dart';
import '../../shared_pref_services/shared_pref_base_service.dart';
import '../../shared_pref_services/shared_pref_keys.dart';

class NavigationManager {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  final GoRouter router = GoRouter(
    initialLocation: RouteConst.start,
    navigatorKey: navigatorKey,
    observers: [
      GoRouterObserver(),
      defaultLifecycleObserver,
    ],
    errorBuilder: (final context, final state) => const PageNotFound(),
    routes: <RouteBase>[

      GoRoute(
        path: RouteConst.start,
        redirect: (ctx, state) async {
          final pref = serviceLocator<SharedPreferenceBaseService>();
          bool isLoggedIn = await pref.getAttribute(SharedPrefKeys.isLoggedIn, false);
          bool isOnboarded = await pref.getAttribute(SharedPrefKeys.isOnboarded, false);
          if (isLoggedIn) {
            if(isOnboarded) {
              return RouteConst.homePage;
            } else{
              return RouteConst.setupProfile;
            }
          } else {
            return RouteConst.loginPage;
          }
        },
      ),

      GoRoute(
        path: RouteConst.splashScreen,
        name: RouteConst.splashScreen,
        builder: (_, _) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: RouteConst.loginPage,
        name: RouteConst.loginPage,
        builder: (_, _) {
          return const SignInScreen();
        },
      ),
      GoRoute(
        path: RouteConst.setupProfile,
        name: RouteConst.setupProfile,
        builder: (_, _) {
          return const SetupUserPage();
        },
      ),
      GoRoute(
        path: RouteConst.homePage,
        name: RouteConst.homePage,
        builder: (_, _) {
        return  BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(),
            child: const HomePage(
            ),
          );          HomePage();
        },
      ),
      GoRoute(
        path: RouteConst.addDoctorPage,
        name: RouteConst.addDoctorPage,
        builder: (_, _) {
          return BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(),
            child: const AddDoctorPage(
            ),
          ); ;
        },
      ),


    ],
  );
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();



  static FutureOr<String?> _welcomeBuilder(BuildContext context, GoRouterState state) async {
    final pref = serviceLocator<SharedPreferenceBaseService>();
    bool isLoggedIn = await pref.getAttribute(SharedPrefKeys.isLoggedIn, false);
    bool isOnboarded = await pref.getAttribute(SharedPrefKeys.isOnboarded, false);
    if (isLoggedIn) {
      if(isOnboarded) {
        return RouteConst.homePage;
      } else{
        return RouteConst.setupProfile;
      }
    } else {
      return RouteConst.loginPage;
    }
    return null;
  }

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
