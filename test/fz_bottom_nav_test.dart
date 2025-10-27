// test/fz_bottom_nav_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
// إضافة هذين الاستيرادين:
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:al_faw_zakho/core/localization/app_localizations.dart';

import 'package:al_faw_zakho/presentation/widgets/fz_bottom_nav.dart';
import 'package:al_faw_zakho/core/navigation/navigation_service.dart';

class FakeNav implements INavigationService {
  bool home = false, donate = false, about = false;
  @override void goAbout(BuildContext c) => about = true;
  @override void goDonate(BuildContext c) => donate = true;
  @override void goHome(BuildContext c)   => home = true;
  @override void goOffices(BuildContext c) {}
}

void main() {
  testWidgets('BottomNav taps call service (keys-based)', (tester) async {
    final fake = FakeNav();

    Widget host(FZTab tab) => Provider<INavigationService>.value(
  value: fake,
  child: MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      bottomNavigationBar: FZBottomNav(active: tab),
    ),
  ),
);

    await tester.pumpWidget(host(FZTab.home));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('tab_donate')));
    await tester.pumpAndSettle();
    expect(fake.donate, isTrue);

    await tester.pumpWidget(host(FZTab.donate));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('tab_about')));
    await tester.pumpAndSettle();
    expect(fake.about, isTrue);

    await tester.pumpWidget(host(FZTab.about));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('tab_home')));
    await tester.pumpAndSettle();
    expect(fake.home, isTrue);
  });
}
