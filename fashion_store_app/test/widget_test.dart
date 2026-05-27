import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Smoke test without Firebase — [MyApp] requires [Firebase.initializeApp].
/// Run integration tests or use Firebase mocks to test the full app widget tree.
void main() {
  testWidgets('Flutter test binding works', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('ok')),
        ),
      ),
    );
    expect(find.text('ok'), findsOneWidget);
  });
}
