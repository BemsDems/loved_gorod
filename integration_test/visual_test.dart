import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:loved_gorod/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Visual Auth and Registration Flow Test', (WidgetTester tester) async {
    // Step 1: Launch App
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 4));

    // Step 2: Test Login Error
    final emailField = find.byType(TextFormField).first;
    final passwordField = find.byType(TextFormField).last;
    final loginButton = find.widgetWithText(FilledButton, 'Войти');

    await tester.enterText(emailField, 'test_error123@mail.ru');
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    await tester.enterText(passwordField, 'wrongpassword');
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    
    // Wait for the SnackBar/Error message
    await Future.delayed(const Duration(seconds: 4));

    // Step 3: Test Registration
    final goToRegister = find.text('Создать сейчас');
    await tester.tap(goToRegister);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));

    final fioFieldReg = find.byType(TextFormField).at(0);
    final emailFieldReg = find.byType(TextFormField).at(1);
    final passwordFieldReg = find.byType(TextFormField).at(2);
    final registerButton = find.widgetWithText(FilledButton, 'Зарегистрироваться');

    await tester.enterText(fioFieldReg, 'Тестовый Пользователь');
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    await tester.enterText(emailFieldReg, 'testuser_${DateTime.now().millisecondsSinceEpoch}@example.com');
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    await tester.enterText(passwordFieldReg, 'Password123!');
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Step 4: Check Redirect and Success SnackBar
    await Future.delayed(const Duration(seconds: 5));

    // Application should be on the Map screen now
    // We leave it open as requested
    await Future.delayed(const Duration(seconds: 10));
  });
}
