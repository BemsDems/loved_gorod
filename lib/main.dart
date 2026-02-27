import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loved_gorod/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:loved_gorod/features/issues_map/presentation/bloc/issues_bloc.dart';

import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/issues_map/presentation/pages/map_screen.dart';
import 'firebase_options.dart';

import 'dart:async';

import 'core/utils/app_bloc_observer.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Step 1: Настройка глобального перехвата ошибок
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('[GLOBAL FATAL ERROR] Описание: ${details.exception} | StackTrace: ${details.stack}');
    };

    Bloc.observer = AppBlocObserver();
    debugPrint('APP STARTING...');
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await di.init(); // Initialize Dependency Injection

    runApp(const MyApp());
  }, (error, stack) {
    debugPrint('[GLOBAL FATAL ERROR] Описание: $error | StackTrace: $stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(const AuthSubscriptionRequested()),
        ),
        BlocProvider<IssuesBloc>(
          create: (_) => di.sl<IssuesBloc>()..add(const IssuesSubscriptionRequested()),
        ),
      ],
      child: MaterialApp(
        title: 'Любимый город',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            primary: const Color.fromRGBO(103, 58, 183, 1),
            secondary: Colors.blueAccent,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        home: const _AuthWrapper(),
      ),
    );
  }
}

class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        debugPrint('[AUTH WRAPPER] State: $state');
        if (state is AuthAuthenticated) {
          return const MapScreen();
        } else if (state is AuthUnauthenticated) {
          return const LoginScreen();
        }
        // AuthInitial or AuthLoading — show a splash/loading screen
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
