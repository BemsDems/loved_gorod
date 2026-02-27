import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/firebase_error_handler.dart';

abstract class AuthRemoteDataSource {
  Stream<User?> get userStream;
  Future<User> login(String email, String password);
  Future<User> register(String name, String email, String password);
  Future<void> logout();
  User? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDataSourceImpl(this._firebaseAuth);

  @override
  Stream<User?> get userStream => _firebaseAuth.authStateChanges();

  @override
  User? getCurrentUser() => _firebaseAuth.currentUser;

  @override
  Future<User> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw Exception('User is null after login');
      }
      return credential.user!;
    } catch (e) {
      debugPrint('[DATA LAYER ERROR] Class: AuthRemoteDataSourceImpl | Method: login | Exception: $e');
      throw Exception(FirebaseErrorHandler.getMessage(e));
    }
  }

  @override
  Future<User> register(String name, String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw Exception('User is null after registration');
      }

      await credential.user!.updateDisplayName(name);
      await credential.user!.reload();
      
      return _firebaseAuth.currentUser!;
    } catch (e) {
      debugPrint('[DATA LAYER ERROR] Class: AuthRemoteDataSourceImpl | Method: register | Exception: $e');
      throw Exception(FirebaseErrorHandler.getMessage(e));
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
