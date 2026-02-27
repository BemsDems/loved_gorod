import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:loved_gorod/main.dart' as app;
import 'package:loved_gorod/core/di/injection_container.dart' as di;
import 'package:firebase_core/firebase_core.dart';
import 'package:loved_gorod/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Visual Auth Flow Test', (WidgetTester tester) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await di.init();
    await tester.pumpWidget(const app.MyApp());
    await tester.pumpAndSettle();

    // Small delay before starting
    await Future.delayed(const Duration(seconds: 3));
    
    // Step 2. Invalid login test
    final emailField = find.widgetWithText(TextFormField, 'Email');
    final passwordField = find.widgetWithText(TextFormField, 'Пароль');
    
    // Since we have multiple buttons, we can rely on find.byType or text.
    // In login, the button is "Войти" within a FilledButton
    final loginBtn = find.widgetWithText(FilledButton, 'Войти');

    await tester.enterText(emailField, 'test_error123@mail.ru');
    await tester.pump();
    await Future.delayed(const Duration(seconds: 3));

    await tester.enterText(passwordField, 'wrongpassword');
    await tester.pump();
    await Future.delayed(const Duration(seconds: 3));

    await tester.tap(loginBtn);
    await tester.pump();
    
    // Wait for the snackbar to appear and stay
    await Future.delayed(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Step 3. Registration test
    final createAccountBtn = find.widgetWithText(TextButton, 'Создать сейчас');
    await tester.tap(createAccountBtn);
    await tester.pumpAndSettle();

    await Future.delayed(const Duration(seconds: 3));

    final fioField = find.widgetWithText(TextFormField, 'ФИО');
    final regEmailField = find.widgetWithText(TextFormField, 'Email');
    final regPasswordField = find.widgetWithText(TextFormField, 'Пароль');
    final regBtn = find.widgetWithText(FilledButton, 'Зарегистрироваться');

    final randomEmail = 'test_${DateTime.now().millisecondsSinceEpoch}@mail.ru';

    await tester.enterText(fioField, 'Test User');
    await tester.pump();
    await Future.delayed(const Duration(seconds: 3));

    await tester.enterText(regEmailField, randomEmail);
    await tester.pump();
    await Future.delayed(const Duration(seconds: 3));

    await tester.enterText(regPasswordField, 'password123');
    await tester.pump();
    await Future.delayed(const Duration(seconds: 3));

    // Scroll if needed (ensure button is visible)
    await tester.ensureVisible(regBtn);
    await tester.pumpAndSettle();

    await tester.tap(regBtn);
    await tester.pump();
    
    // Step 4. Check redirect
    await Future.delayed(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
