import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_dashboard/src/widgets/user_profile/user_avatar.dart';

void main() {
  group('UserAvatar', () {
    testWidgets('should display default avatar with person icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserAvatar(),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should use custom radius when provided', (tester) async {
      const customRadius = 30.0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserAvatar(radius: customRadius),
          ),
        ),
      );

      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circleAvatar.radius, customRadius);
    });

    testWidgets('should use theme colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: Scaffold(
            body: UserAvatar(),
          ),
        ),
      );

      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circleAvatar.backgroundColor, isNotNull);
    });
  });
}

