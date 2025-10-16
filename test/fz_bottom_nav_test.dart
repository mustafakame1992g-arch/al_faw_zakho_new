import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_bottom_nav.dart';
import 'package:al_faw_zakho/core/navigation/navigation_service.dart';

class FakeNav implements INavigationService {
  bool home=false, offices=false, donate=false, about=false;
  @override void goAbout(BuildContext c){ about=true; }
  @override void goDonate(BuildContext c){ donate=true; }
  @override void goHome(BuildContext c){ home=true; }
  @override void goOffices(BuildContext c){ offices=true; }
}

void main() {
  testWidgets('BottomNav taps call service', (tester) async {
    final fake = FakeNav();
    await tester.pumpWidget(
      Provider<INavigationService>.value(
        value: fake,
        child: const MaterialApp(home: Scaffold(bottomNavigationBar: FZBottomNav(active: FZTab.home))),
      ),
    );

    await tester.tap(find.text('مكاتبنا'));
    expect(fake.offices, true);

    await tester.tap(find.text('تبرع'));
    expect(fake.donate, true);
  });
}
