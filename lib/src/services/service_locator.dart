import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../features/auth/data/repo_impl/sample_repo_impl.dart';
import '../features/auth/domain/repo/auth_repo.dart';
import 'api_services/dio_client.dart';

final serviceLocator = GetIt.instance;

Future<void> init() async {
  serviceLocator..registerLazySingleton<Dio>(() => DioClient().provideDio())
  ..registerLazySingleton<AuthRepo>(() => SampleRepoImpl());
}

void disposeServices() {
  /// dispose the service if any service has disposable objects.
}
