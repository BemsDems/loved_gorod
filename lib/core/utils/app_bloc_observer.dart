import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    developer.log('BLOC EVENT: ${bloc.runtimeType} -> $event');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('[BLOC ERROR] Bloc: ${bloc.runtimeType} | Error: $error | StackTrace: $stackTrace');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // devlog optionally for state changes
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    developer.log('BLOC TRANSITION in ${bloc.runtimeType}: ${transition.currentState} -> ${transition.nextState}');
  }
}
