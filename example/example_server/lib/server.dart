import 'dart:io';

import 'package:example_server/src/admin/admin.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_admin_server/serverpod_admin_server.dart'
    show AdminScope;
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/web/routes/root.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(args, Protocol(), Endpoints());

  // Initialize authentication services for the server.
  // Token managers will be used to validate and issue authentication keys,
  // and the identity providers will be the authentication options available for users.
  registerAdminModule();

  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Use JWT for authentication keys towards the server.
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // Configure the email identity provider for email/password authentication.
      EmailIdpConfigFromPasswords(
        sendRegistrationVerificationCode: _sendRegistrationCode,
        sendPasswordResetVerificationCode: _sendPasswordResetCode,
      ),
    ],
  );

  // Setup a default page at the web root.
  pod.webServer.addRoute(RootRoute(), '/');
  pod.webServer.addRoute(RootRoute(), '/index.html');

  // Serve all files in the web/static relative directory under /.
  final root = Directory(Uri(path: 'web/static').toFilePath());
  pod.webServer.addRoute(StaticRoute.directory(root), '/**');

  // Start the server.
  await pod.start();
  // await createAdminUser();
}

void _sendRegistrationCode(
  Session session, {
  required String email,
  required UuidValue accountRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  // NOTE: Here you call your mail service to send the verification code to
  // the user. For testing, we will just log the verification code.
  session.log('[EmailIdp] Registration code ($email): $verificationCode');
}

void _sendPasswordResetCode(
  Session session, {
  required String email,
  required UuidValue passwordResetRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  // NOTE: Here you call your mail service to send the verification code to
  // the user. For testing, we will just log the verification code.
  session.log('[EmailIdp] Password reset code ($email): $verificationCode');
}

Future<void> createAdminUser() async {
  final session = await Serverpod.instance.createSession();

  final emailIdp = AuthServices.instance.emailIdp;
  final admin = emailIdp.admin;

  // 1) Create an AuthUser first (if you don't already have one)
  final authUser = await AuthServices.instance.authUsers.create(session);

  // 2) Create an email authentication account for that user
  await admin.createEmailAuthentication(
    session,
    authUserId: authUser.id,
    email: 'adammusaaly@gmail.com',
    password: 'Adaforlan',
  );

  await AdminScope.db.insertRow(
    session,
    AdminScope(
      userId: authUser.id.toString(),
      isStaff: true,
      isSuperuser: true,
    ),
  );
  print("Admin user created successfully.");
  // Optionally: set or change password later
  // await admin.setPassword(session, email: 'user@example.com', password: 'newPassword');
}
// {"className":"serverpod_auth_idp.EmailAccountLoginException","data":{"__className__":"serverpod_auth_idp.EmailAccountLoginException","reason":"invalidCredentials"}}%

// {"className":"serverpod_auth_idp.EmailAccountLoginException","data":{"__className__":"serverpod_auth_idp.EmailAccountLoginException","reason":"invalidCredentials"}}%
