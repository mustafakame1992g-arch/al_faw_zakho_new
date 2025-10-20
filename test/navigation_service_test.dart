import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:al_faw_zakho/core/localization/app_localizations.dart';
import 'package:al_faw_zakho/core/navigation/navigation_service.dart';

void main() {
  testWidgets('goHome resets stack', (tester) async {
    final nav = NavigationService(); // كودك الحالي
    final navKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navKey,
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
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
