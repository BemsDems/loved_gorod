import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  UserEntity? _mapFirebaseUser(user) {
    if (user == null) return null;
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'Пользователь',
    );
  }

  @override
  Stream<UserEntity?> get userStream {
    return remoteDataSource.userStream.map(_mapFirebaseUser);
  }

  @override
  UserEntity? getCurrentUser() {
    return _mapFirebaseUser(remoteDataSource.getCurrentUser());
  }

  @override
  Future<Either<String, UserEntity>> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      return Right(_mapFirebaseUser(user)!);
    } catch (e) {
      debugPrint('[DATA LAYER ERROR] Class: AuthRepositoryImpl | Method: login | Exception: $e');
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Either<String, UserEntity>> register(String name, String email, String password) async {
    try {
      final user = await remoteDataSource.register(name, email, password);
      return Right(_mapFirebaseUser(user)!);
    } catch (e) {
      debugPrint('[DATA LAYER ERROR] Class: AuthRepositoryImpl | Method: register | Exception: $e');
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }
}
