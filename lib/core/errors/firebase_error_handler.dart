import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseErrorHandler {
  static String getMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Пользователь не найден';
        case 'wrong-password':
          return 'Неверный пароль';
        case 'invalid-email':
          return 'Некорректный email';
        case 'user-disabled':
          return 'Этот аккаунт заблокирован';
        case 'too-many-requests':
          return 'Слишком много попыток. Попробуйте позже.';
        case 'email-already-in-use':
          return 'Этот email уже используется';
        case 'weak-password':
          return 'Слишком слабый пароль';
        case 'operation-not-allowed':
          return 'Операция не разрешена';
        case 'network-request-failed':
          return 'Ошибка сети. Проверьте подключение.';
        case 'invalid-credential':
          return 'Неверные учетные данные. Проверьте почту и пароль.';
        default:
          return 'Ошибка авторизации: ${error.message}';
      }
    } else if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Нет доступа. Проверьте права в Realtime Database.';
        case 'unavailable':
          return 'Сервис временно недоступен';
        case 'network-error':
          return 'Ошибка сети. Проверьте подключение.';
        default:
          return 'Ошибка сервера: ${error.message}';
      }
    }
    
    return 'Неизвестная ошибка: ${error.toString()}';
  }
}
