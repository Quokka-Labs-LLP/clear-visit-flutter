
import 'dart:async';

import 'package:base_architecture/src/app/router/route_const.dart';
import 'package:base_architecture/src/features/auth/presentation/view/onboarding_succes_page.dart';
import 'package:base_architecture/src/features/auth/presentation/view/setup_user_page.dart';
import 'package:base_architecture/src/features/auth/presentation/view/sign_in_screen.dart';
import 'package:base_architecture/src/features/home/presentation/view/recording_page.dart';
import 'package:base_architecture/src/features/profile/presentation/bloc/view/pages/add_doctor_page.dart';
import 'package:base_architecture/src/features/profile/presentation/bloc/view/pages/doctors_listing_page.dart';
import 'package:base_architecture/src/features/profile/data/model/doctor_model.dart';
import 'package:base_architecture/src/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:base_architecture/src/features/home/presentation/view/home_page.dart';
import 'package:base_architecture/src/features/home/presentation/view/summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lifecycle/lifecycle.dart';
import '../../features/profile/presentation/bloc/view/pages/profile_page.dart';
import '../../features/splash/presentation/view/splash_screen.dart';

import '../../services/service_locator.dart';
import '../../shared/widgets/page_not_found.dart';
import '../../shared_pref_services/shared_pref_base_service.dart';
import '../../shared_pref_services/shared_pref_keys.dart';

class NavigationManager {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  final GoRouter router = GoRouter(
    initialLocation: RouteConst.splashScreen,
    navigatorKey: navigatorKey,
    observers: [
      GoRouterObserver(),
      defaultLifecycleObserver,
    ],
    errorBuilder: (final context, final state) => const PageNotFound(),
    routes: <RouteBase>[
      GoRoute(
        path: RouteConst.start,
        name: RouteConst.start,
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
        builder: (context, state) {
          final isOnboarding = state.extra as bool? ?? true;
          return SetupUserPage(isOnboarding: isOnboarding);
        },
      ),
      GoRoute(
        path: RouteConst.homePage,
        name: RouteConst.homePage,
        builder: (_, _) {
        return  HomePage(
        );        HomePage();
        },
      ),
      GoRoute(
        path: RouteConst.addDoctorPage,
        name: RouteConst.addDoctorPage,
        builder: (context, state) {
          final doctor = state.extra as DoctorModel?;
          return BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(),
            child: AddDoctorPage(doctor: doctor),
          );
        },
      ),
      GoRoute(
        path: RouteConst.doctorsListingPage,
        name: RouteConst.doctorsListingPage,
        builder: (context, state) {
          final selectionMode = (state.extra as bool?) ?? false;
          return BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(),
            child: DoctorsListingPage(selectionMode: selectionMode),
          );
        },
      ),
      GoRoute(
        path: RouteConst.onboardingSuccess,
        name: RouteConst.onboardingSuccess,
        builder: (_, _) {
          return OnboardingSuccessPage();
        },
      ),
      GoRoute(
        path: RouteConst.profileScreen,
        name: RouteConst.profileScreen,
        builder: (_, _) {
          return const ProfilePage();
        },
      ),
      GoRoute(
        path: RouteConst.recordingScreen,
        name: RouteConst.recordingScreen,
        builder: (context, state) {
          final doctorId = state.extra as String?;
          return RecordingPage(doctorId: doctorId);
        },
      ),
      GoRoute(
        path: RouteConst.summaryScreen,
        name: RouteConst.summaryScreen,
        builder: (context, state) {
          return const SummaryScreen();
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
