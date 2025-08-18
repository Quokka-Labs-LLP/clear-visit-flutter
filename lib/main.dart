import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';


import 'firebase_options.dart';
import 'src/app/app.dart';
import 'src/services/db_services/db_init.dart';
import 'src/shared/utilities/debug_logger.dart';

void main() async {
  runZonedGuarded(
    () async {
      initializeApp();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      

      await DatabaseService.init();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      /// MARK:- Load environment file
      await dotenv.load();
      await manageSplashDelay(duration: const Duration(seconds: 2));
      runApp(const App());
    },
    (final error, final stack) {
      /// MARK:- To trace crash if happen
      printError(error.toString());
      printError(stack.toString());
    },
  );
}

/// MARK: - To show splash screen until flutter Initialized.
WidgetsBinding initializeApp() {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  return binding;
}

Future manageSplashDelay({final Duration duration = Duration.zero}) async {
  if (duration.inMilliseconds > 0) {
    await Future.delayed(duration);
  }
  FlutterNativeSplash.remove();
}
