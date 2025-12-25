import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_admin_server/src/generated/protocol.dart';

/// Login endpoint for admin dashboard authentication.
/// This endpoint does not require authentication (it's the login itself).
class AdminLoginEndpoint extends Endpoint {
  /// Login endpoint that authenticates users via email/password.
  /// Makes a POST request to the emailIdp/login endpoint.
  Future<AdminResponse?> login(
    Session session,
    String email,
    String password,
  ) async {
    try {
      final httpClient = HttpClient();
      final uri = Uri.parse('${session.request!.url.origin}/emailIdp/login');
      print("Here is the session request url: $uri");

      final request = await httpClient.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');

      final requestBody = jsonEncode({
        'email': email,
        'password': password,
      });

      request.write(requestBody);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      httpClient.close();

      if (response.statusCode != 200) {
        throw ArgumentError(
          'Login failed: ${response.statusCode} - $responseBody',
        );
      }

      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

      session.log('AdminLoginEndpoint.login successful for email: $email');

      // Check admin scope for the user
      final user = await AdminScope.db.findFirstRow(
        session,
        where: (t) => t.userId.equals(responseData['authUserId'].toString()),
      );

      // Get scopeNames directly from response - if empty or null, use empty list
      final scopeNamesRaw = responseData['scopeNames'];
      final scopeNames = (scopeNamesRaw is List && scopeNamesRaw.isNotEmpty)
          ? scopeNamesRaw.cast<String>()
          : <String>[];

      return AdminResponse(
        authStrategy: responseData['authStrategy']?.toString() ?? 'session',
        token: responseData['token']?.toString() ?? '',
        tokenExpiresAt: responseData['tokenExpiresAt'] != null
            ? DateTime.tryParse(responseData['tokenExpiresAt'].toString())
            : null,
        refreshToken: responseData['refreshToken']?.toString(),
        authUserId: responseData['authUserId']?.toString() ?? '',
        scopeNames: scopeNames,
        isSuperuser: user?.isSuperuser ?? false,
        isStaff: user?.isStaff ?? false,
      );
    } catch (e) {
      session.log('AdminLoginEndpoint.login error: $e');
      return null;
    }
  }
}
