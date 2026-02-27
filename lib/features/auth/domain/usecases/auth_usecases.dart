import 'dart:async';
import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<String, UserEntity>> call(String email, String password) {
    return repository.login(email, password);
  }
}

class RegisterUseCase {
  final IAuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<String, UserEntity>> call(String name, String email, String password) {
    return repository.register(name, email, password);
  }
}

class LogoutUseCase {
  final IAuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() {
    return repository.logout();
  }
}

class GetAuthStreamUseCase {
  final IAuthRepository repository;

  GetAuthStreamUseCase(this.repository);

  Stream<UserEntity?> call() {
    return repository.userStream;
  }
}
