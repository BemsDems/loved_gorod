import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/issues_map/data/datasources/issues_remote_data_source.dart';
import '../../features/issues_map/data/repositories/issues_repository_impl.dart';
import '../../features/issues_map/domain/repositories/i_issues_repository.dart';
import '../../features/issues_map/domain/usecases/issues_usecases.dart';
import '../../features/issues_map/presentation/bloc/issues_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- External ---
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseDatabase.instance);

  // --- Features ---
  
  // Auth
  sl.registerFactory(() => AuthBloc(
        getAuthStreamUseCase: sl(),
        logoutUseCase: sl(),
      ));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetAuthStreamUseCase(sl()));
  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  
  // Issues Map
  sl.registerFactory(() => IssuesBloc(
        getIssuesStreamUseCase: sl(),
        createIssueUseCase: sl(),
        voteIssueUseCase: sl(),
      ));
  sl.registerLazySingleton(() => GetIssuesStreamUseCase(sl()));
  sl.registerLazySingleton(() => CreateIssueUseCase(sl()));
  sl.registerLazySingleton(() => VoteIssueUseCase(sl()));
  sl.registerLazySingleton<IIssuesRepository>(() => IssuesRepositoryImpl(sl()));
  sl.registerLazySingleton<IssuesRemoteDataSource>(() => IssuesRemoteDataSourceImpl(sl()));
}
