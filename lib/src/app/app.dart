import 'package:base_architecture/src/app/theme/bloc/theme_bloc.dart';
import 'package:base_architecture/src/app/theme/bloc/theme_state.dart';
import 'package:base_architecture/src/app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../services/service_locator.dart' as service_locator;
import 'locale/locales.dart';
import 'router/router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    service_locator.init();
  }

  @override
  void dispose() {
    // Uncomment the below line if you listing internet status
    service_locator.disposeServices();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    /// MARK: - Add Localization & Router configuration
    return MultiBlocProvider(
      providers:[
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider(create: (context) => AuthBloc()),
      ] ,
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            theme: lightTheme,
            scaffoldMessengerKey: NavigationManager.scaffoldMessengerKey,
            darkTheme: darkTheme,
            themeMode: state.themeMode,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],

            supportedLocales: AppLocalizations.getSupportedLocales(),
            debugShowCheckedModeBanner: false,
            routerConfig: NavigationManager().router,
          );
        },
      ),
    );
  }
}
