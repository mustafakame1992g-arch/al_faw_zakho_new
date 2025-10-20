import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_bottom_nav.dart';
import 'package:al_faw_zakho/core/navigation/navigation_service.dart';
import 'helpers/test_app.dart'; // <— الملف الجديد

class FakeNav implements INavigationService {
  bool home = false, offices=false, donate=false, about=false;

  @override void goAbout(BuildContext c){ about=true; }
  @override void goDonate(BuildContext c){ donate=true; }
  @override void goHome(BuildContext c){ home=true; }
  @override void goOffices(BuildContext c){ offices=true; }

  // إذا كان لديك goOffices في الواجهة الأصلية؛ هنا ليس لدينا Offices
}

void main() {
  testWidgets('BottomNav taps call service (icons-based, locale-agnostic)', (tester) async {
    final fake = FakeNav();

    await tester.pumpWidget(
      Provider<INavigationService>.value(
        value: fake,
        child: wrapWithTestApp(
          const Scaffold(bottomNavigationBar: FZBottomNav(active: FZTab.home)),
          locale: const Locale('ar'), // أو 'en' لو تحب
        ),
      ),
    );

    // تبرع
    await tester.tap(find.byIcon(Icons.volunteer_activism_outlined));
    await tester.pumpAndSettle();
    expect(fake.donate, isTrue);

    // حول التطبيق
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();
    expect(fake.about, isTrue);

    // الرئيسية
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(fake.home, isTrue);
  });
}
