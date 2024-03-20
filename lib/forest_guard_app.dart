import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_guard/injection.dart';
import 'package:forest_guard/src/bloc/bloc/detecting_bloc/detecting_bloc.dart';
import 'package:forest_guard/src/bloc/bloc/is_detecting_cubit/is_detecting.dart';
import 'package:forest_guard/src/bloc/bloc/sqflite_bloc/sqflite_bloc.dart';
import 'package:forest_guard/src/ui/call_authorities%20_view/call_authorities_view.dart';
import 'package:forest_guard/src/ui/home_view/home_view.dart';
import 'package:forest_guard/src/ui/home_view/widgets/create_test_data.dart';
import 'package:forest_guard/src/ui/initial_view/initial_view.dart';
import 'package:forest_guard/src/ui/verified_trucks_view/verified_trucks_view.dart';

class ForestGuardApp extends StatelessWidget {
  const ForestGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<DetectingBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<SqfliteBloc>()..add(SqfliteGetAll()),
        ),
        BlocProvider(
          create: (context) => IsDetectingCubit()..stopDetecting(),
        ),
      ],
      child: MaterialApp(
        title: 'Forest Guard',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green[800]!),
          useMaterial3: true,
        ),
        routes: {
          '/': (context) => const InitialView(),
          'home_view': (context) => const HomeView(),
          'verified_trucks_view': (context) => const VerifiedTrucksView(),
          'call_authorities_view': (context) => const CallAuthorities(),
          'create_test_data_view': (context) => const CreateTestData(),
        },
      ),
    );
  }
}
