import 'package:forest_guard/src/bloc/bloc/detecting_bloc/detecting_bloc.dart';
import 'package:forest_guard/src/bloc/bloc/sqflite_bloc/sqflite_bloc.dart';
import 'package:forest_guard/src/constants/screen_params.dart';
import 'package:forest_guard/src/repositories/verified_trucks_sqflite_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

final sl = GetIt.instance;

Future<void> init(Database database) async {
  //!Build
  sl.registerSingleton<Database>(database);
  sl.registerLazySingleton<ScreenParams>(() => ScreenParams());
  //!Repositories
  sl.registerSingleton<VerifiedTrucksSqfliteRepository>(
      VerifiedTrucksSqfliteRepositoryImpl());
  //!Blocs
  sl.registerFactory(() => SqfliteBloc(sqfliteRepository: sl()));
  sl.registerFactory(() => DetectingBloc());
}
