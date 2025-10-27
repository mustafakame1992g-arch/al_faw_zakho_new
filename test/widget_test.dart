// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots (smoke)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('OK', key: ValueKey('ok')),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('ok')), findsOneWidget);
  });
}
