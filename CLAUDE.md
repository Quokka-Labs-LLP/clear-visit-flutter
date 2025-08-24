# Claude AI Assistant Configuration

## Project Overview
**base_architecture** - A Flutter mobile application with Firebase integration, authentication, and clean architecture patterns.

## Development Commands
- **Build**: `flutter build apk` or `flutter build ios`
- **Run**: `flutter run` (dev) or `flutter run --release`
- **Clean**: `flutter clean && flutter pub get`
- **Test**: `flutter test`
- **Analyze**: `flutter analyze`
- **Format**: `dart format .`

## Project Structure
```
lib/
├── main.dart (production entry)
├── main_dev.dart (development entry)
└── src/
    ├── app/ (app configuration)
    │   ├── locale/ (internationalization)
    │   ├── router/ (navigation)
    │   └── theme/ (app theming with BLoC)
    ├── features/ (feature modules)
    │   ├── auth/ (authentication)
    │   └── splash/ (splash screen)
    ├── services/ (core services)
    │   ├── api_services/ (Dio HTTP client)
    │   ├── db_services/ (Hive database)
    │   └── service_locator.dart (GetIt DI)
    └── shared/ (shared utilities)
        ├── constants/
        ├── models/
        ├── utilities/
        └── widgets/
```

## Key Technologies & Dependencies
- **State Management**: flutter_bloc (BLoC pattern)
- **HTTP Client**: dio with request interceptors
- **Local Storage**: hive_flutter, shared_preferences
- **Navigation**: go_router
- **Dependency Injection**: get_it
- **Firebase**: firebase_core, firebase_auth, cloud_firestore
- **Authentication**: google_sign_in, firebase_auth
- **UI/UX**: lottie, flutter_svg, shimmer, google_fonts
- **Connectivity**: connectivity_plus
- **Media**: record, just_audio, ffmpeg_kit_flutter
- **Utils**: permission_handler, path_provider, share_plus

## Architecture Pattern
Clean Architecture with feature-based organization:
- **Data Layer**: Models, Repository Implementations
- **Domain Layer**: Entities, Repository Interfaces  
- **Presentation Layer**: BLoC, Views, Widgets

## Development Environment
- **Flutter**: 3.32.4
- **Dart**: 3.8.1
- **Min SDK**: >=3.8.1 <4.0.0

## Configuration Files
- **Environment**: `.env` (production), `.env.dev` (development)
- **Firebase**: `GoogleService-Info.plist` (iOS), `google-services.json` (Android)
- **Native Splash**: Configured in pubspec.yaml

## Firebase Integration
- Authentication (Google Sign-in)
- Cloud Firestore database
- Firebase Storage
- App Check for security

## Common Development Tasks
1. **Adding new features**: Follow clean architecture in `lib/src/features/`
2. **Database operations**: Use Hive with code generation
3. **API calls**: Implement through Dio client with interceptors
4. **State management**: Create BLoC for complex state logic
5. **Dependency injection**: Register services in `service_locator.dart`

## Building & Deployment
- Run `flutter clean && flutter pub get` before building
- Use `flutter build apk --release` for Android production builds
- Use `flutter build ios --release` for iOS production builds
- Ensure Firebase configuration files are properly placed

## Notes
- Project uses both development and production entry points
- Internationalization support with multiple languages (English, Arabic, French)
- Audio recording and playback capabilities integrated
- PDF generation and printing support
- Comprehensive error logging with ql_logger_flutter