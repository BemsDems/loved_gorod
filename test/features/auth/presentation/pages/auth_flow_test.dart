import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:loved_gorod/features/auth/domain/entities/user_entity.dart';
import 'package:loved_gorod/features/auth/domain/usecases/auth_usecases.dart';
import 'package:loved_gorod/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:loved_gorod/features/auth/presentation/pages/login_screen.dart';
import 'package:loved_gorod/features/auth/presentation/pages/register_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockGetAuthStreamUseCase extends Mock implements GetAuthStreamUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockGetAuthStreamUseCase mockGetAuthStreamUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late AuthBloc authBloc;

  final sl = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(const AuthSubscriptionRequested());
  });

  setUp(() async {
    await sl.reset();
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockGetAuthStreamUseCase = MockGetAuthStreamUseCase();
    mockLogoutUseCase = MockLogoutUseCase();

    sl.registerLazySingleton<LoginUseCase>(() => mockLoginUseCase);
    sl.registerLazySingleton<RegisterUseCase>(() => mockRegisterUseCase);
    sl.registerLazySingleton<GetAuthStreamUseCase>(() => mockGetAuthStreamUseCase);
    sl.registerLazySingleton<LogoutUseCase>(() => mockLogoutUseCase);

    when(() => mockGetAuthStreamUseCase()).thenAnswer((_) => Stream.value(null));

    authBloc = AuthBloc(
      getAuthStreamUseCase: mockGetAuthStreamUseCase,
      logoutUseCase: mockLogoutUseCase,
    );
    
    sl.registerFactory(() => authBloc);
  });

  Widget createWidgetUnderTest(Widget child) {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: child,
      ),
    );
  }

  testWidgets('LoginScreen shows error when login fails with invalid data', (WidgetTester tester) async {
    // Arrange
    when(() => mockLoginUseCase(any(), any()))
        .thenAnswer((_) async => const Left('Неверный пароль'));

    await tester.pumpWidget(createWidgetUnderTest(const LoginScreen()));

    // Act
    await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
    await tester.enterText(find.byType(TextFormField).last, 'wrong_password');
    await tester.tap(find.byType(FilledButton));
    await tester.pump(); // Start loading
    await tester.pump(); // Finish loading and show snackbar

    // Assert
    expect(find.text('Неверный пароль'), findsOneWidget);
  });

  testWidgets('RegisterScreen registers successfully with valid data', (WidgetTester tester) async {
    // Arrange
    final testUser = UserEntity(
      id: '123',
      email: 'test@test.com',
      displayName: 'Test User',
    );

    when(() => mockRegisterUseCase(any(), any(), any()))
        .thenAnswer((_) async => Right(testUser));

    await tester.pumpWidget(createWidgetUnderTest(const RegisterScreen()));

    // Act
    // RegisterScreen has 3 text fields: FIO, Email, Password
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'Иван Иванов');
    await tester.enterText(textFields.at(1), 'test@test.com');
    await tester.enterText(textFields.at(2), 'password123');
    
    await tester.tap(find.byType(FilledButton));
    await tester.pump(); // Start loading
    await tester.pump(); // Finish loading and show snackbar

    // Assert
    expect(find.text('Успех!'), findsOneWidget);
    expect(find.text('Аккаунт создан. Вы вошли в систему.'), findsOneWidget);
  });
}
