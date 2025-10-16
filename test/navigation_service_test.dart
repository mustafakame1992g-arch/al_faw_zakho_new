import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:al_faw_zakho/core/navigation/navigation_service.dart';

void main() {
  testWidgets('goHome resets stack', (tester) async {
    final nav = NavigationService();
    final navKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navKey,
        routes: {
          NavigationService.homeRoute: (_) => const Scaffold(body: Text('Home')),
          '/second': (_) => const Scaffold(body: Text('Second')),
        },
        initialRoute: '/second',
      ),
    );

    nav.goHome(navKey.currentContext!);
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });
}
