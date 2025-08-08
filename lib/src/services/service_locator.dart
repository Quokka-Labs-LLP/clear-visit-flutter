import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/data/repo_impl/auth_repo_impl.dart';
import '../features/auth/domain/repo/auth_repo.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/home/presentation/bloc/home_bloc.dart';
import '../features/home/data/repo_impl/summary_repo_impl.dart';
import '../features/home/domain/repo/summary_repo.dart';
import '../features/profile/data/repo_impl/profile_repo_impl.dart';
import '../features/profile/domain/repo/profile_repo.dart';
import '../shared_pref_services/shared_pref_base_service.dart';
import '../shared_pref_services/shared_pref_service.dart';
import 'api_services/dio_client.dart';

final serviceLocator = GetIt.instance;

Future<void> init() async {
  SharedPreferenceService sharedPref = SharedPreferenceService();
  serviceLocator.registerSingleton<SharedPreferenceBaseService>(sharedPref);
  serviceLocator<SharedPreferenceBaseService>().initialize();
  serviceLocator.registerLazySingleton<Dio>(() => DioClient().provideDio());
  serviceLocator.registerLazySingleton<AuthRepo>(() => AuthRepoImpl());
  serviceLocator.registerLazySingleton<ProfileRepo>(() => ProfileRepoImpl());
  serviceLocator.registerLazySingleton<SummaryRepo>(() => SummaryRepoImpl());
  serviceLocator.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  serviceLocator.registerLazySingleton<HomeBloc>(() => HomeBloc());
  serviceLocator.registerLazySingleton<AuthBloc>(() => AuthBloc());
}

void disposeServices() {
  /// dispose the service if any service has disposable objects.
}
