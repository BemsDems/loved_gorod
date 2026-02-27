import 'dart:async';
import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

abstract class IAuthRepository {
  Stream<UserEntity?> get userStream;
  Future<Either<String, UserEntity>> login(String email, String password);
  Future<Either<String, UserEntity>> register(String name, String email, String password);
  Future<void> logout();
  UserEntity? getCurrentUser();
}
