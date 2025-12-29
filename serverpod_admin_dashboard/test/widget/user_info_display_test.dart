import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_dashboard/src/widgets/user_profile/user_info_display.dart';

void main() {
  group('UserInfoDisplay', () {
    testWidgets('should display user name and default role', (tester) async {
      const displayName = 'test@example.com';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserInfoDisplay(displayName: displayName),
          ),
        ),
      );

      expect(find.text(displayName), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
    });

    testWidgets('should display custom role when provided', (tester) async {
      const displayName = 'test@example.com';
      const customRole = 'Super Admin';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserInfoDisplay(
              displayName: displayName,
              role: customRole,
            ),
          ),
        ),
      );

      expect(find.text(displayName), findsOneWidget);
      expect(find.text(customRole), findsOneWidget);
    });

    testWidgets('should truncate long display names', (tester) async {
      const longName = 'verylongemailaddressthatshouldbetruncated@example.com';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              child: UserInfoDisplay(displayName: longName),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text(longName));
      expect(textWidget.maxLines, 1);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });
  });
}

