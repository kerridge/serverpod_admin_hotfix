import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_dashboard/src/controller/auth_controller.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'auth_controller_test.mocks.dart';

@GenerateMocks([
  ServerpodClientShared,
  AuthSessionManager,
])
void main() {
  group('AuthController', () {
    late MockServerpodClientShared mockClient;
    late MockAuthSessionManager mockAuth;
    late AuthController authController;

    setUp(() {
      mockClient = MockServerpodClientShared();
      mockAuth = MockAuthSessionManager();
      when(mockClient.auth).thenReturn(mockAuth);
      authController = AuthController(client: mockClient);
    });

    tearDown(() {
      authController.dispose();
    });

    test('initial state should be unauthenticated', () {
      expect(authController.isAuthenticated, false);
      expect(authController.isLoading, false);
      expect(authController.obscurePassword, true);
      expect(authController.errorMessage, null);
    });

    test('email and password controllers should be initialized', () {
      expect(authController.emailController.text, '');
      expect(authController.passwordController.text, '');
    });

    test('toggleObscurePassword should toggle password visibility', () {
      expect(authController.obscurePassword, true);
      authController.toggleObscurePassword();
      expect(authController.obscurePassword, false);
      authController.toggleObscurePassword();
      expect(authController.obscurePassword, true);
    });

    test('logout should reset authentication state and clear form', () {
      // Set some values
      authController.emailController.text = 'test@example.com';
      authController.passwordController.text = 'password123';

      authController.logout();

      expect(authController.isAuthenticated, false);
      expect(authController.errorMessage, null);
      expect(authController.emailController.text, '');
      expect(authController.passwordController.text, '');
    });

    test('authenticate should set authenticated to true if user has admin scope', () {
      final mockAuthInfo = MockAuthSuccess();
      when(mockAuthInfo.scopeNames).thenReturn({'serverpod.admin'});
      when(mockAuth.authInfo).thenReturn(mockAuthInfo);

      authController.authenticate();

      expect(authController.isAuthenticated, true);
      expect(authController.errorMessage, null);
      expect(authController.isLoading, false);
    });

    test('authenticate should set error if user does not have admin scope', () {
      final mockAuthInfo = MockAuthSuccess();
      when(mockAuthInfo.scopeNames).thenReturn(<String>{});
      when(mockAuth.authInfo).thenReturn(mockAuthInfo);

      authController.authenticate();

      expect(authController.isAuthenticated, false);
      expect(authController.errorMessage, 'User does not have admin privileges');
      expect(authController.isLoading, false);
    });

    test('authenticate should set error if authInfo is null', () {
      when(mockAuth.authInfo).thenReturn(null);

      authController.authenticate();

      expect(authController.isAuthenticated, false);
      expect(authController.errorMessage, 'User does not have admin privileges');
      expect(authController.isLoading, false);
    });

    test('login should return false if email is empty', () async {
      authController.emailController.text = '';
      authController.passwordController.text = 'password';

      final result = await authController.login();

      expect(result, false);
      expect(authController.errorMessage, 'Email and password are required');
      expect(authController.isLoading, false);
    });

    test('login should return false if password is empty', () async {
      authController.emailController.text = 'test@example.com';
      authController.passwordController.text = '';

      final result = await authController.login();

      expect(result, false);
      expect(authController.errorMessage, 'Email and password are required');
      expect(authController.isLoading, false);
    });
  });
}

// Mock classes
class MockAuthSuccess extends Mock implements AuthSuccess {}

