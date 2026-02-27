import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetAuthStreamUseCase _getAuthStreamUseCase;
  final LogoutUseCase _logoutUseCase;
  
  late StreamSubscription<UserEntity?> _userSubscription;

  AuthBloc({
    required GetAuthStreamUseCase getAuthStreamUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _getAuthStreamUseCase = getAuthStreamUseCase,
        _logoutUseCase = logoutUseCase,
        super(const AuthInitial()) {
    
    on<AuthSubscriptionRequested>(_onAuthSubscriptionRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
  }

  void _onAuthSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) {
    _userSubscription = _getAuthStreamUseCase().listen((user) {
      add(AuthUserChanged(user));
    });
  }

  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logoutUseCase();
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
