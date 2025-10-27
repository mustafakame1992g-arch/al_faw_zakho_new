import 'package:al_faw_zakho/core/navigation/navigation_service.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class MockNavigationService implements INavigationService {
  int homeCalls = 0;
  int donateCalls = 0;
  int aboutCalls = 0;
  int officesCalls = 0;

  @override
  void goHome(BuildContext c) => homeCalls++;

  @override
  void goDonate(BuildContext c) => donateCalls++;

  @override
  void goAbout(BuildContext c) => aboutCalls++;

  @override
  void goOffices(BuildContext c) => officesCalls++;

  void reset() {
    homeCalls = 0;
    donateCalls = 0;
    aboutCalls = 0;
    officesCalls = 0;
  }
}

void main() {
  late MockNavigationService mockNav;

  setUp(() {
    mockNav = MockNavigationService();
  });

  Widget createTestWidget({required FZTab activeTab}) {
    return MaterialApp(
      home: Scaffold(
        body: Container(),
        bottomNavigationBar: FZBottomNav(active: activeTab),
      ),
    );
  }

  group('FZBottomNav Basic Tests', () {
    testWidgets('يجب أن يعرض NavigationBar', (tester) async {
      await tester.pumpWidget(
        Provider<INavigationService>.value(
          value: mockNav,
          child: createTestWidget(activeTab: FZTab.home),
        ),
      );
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('يجب التنقل إلى donate عند النقر', (tester) async {
      await tester.pumpWidget(
        Provider<INavigationService>.value(
          value: mockNav,
          child: createTestWidget(activeTab: FZTab.home),
        ),
      );
      await tester.tap(find.text('Donate'));
      await tester.pump();
      expect(mockNav.donateCalls, 1);
    });

    testWidgets('يجب التنقل إلى about عند النقر', (tester) async {
      await tester.pumpWidget(
        Provider<INavigationService>.value(
          value: mockNav,
          child: createTestWidget(activeTab: FZTab.home),
        ),
      );
      await tester.tap(find.text('About'));
      await tester.pump();
      expect(mockNav.aboutCalls, 1);
    });

    testWidgets('يجب التنقل إلى home عند النقر', (tester) async {
      await tester.pumpWidget(
        Provider<INavigationService>.value(
          value: mockNav,
          child: createTestWidget(activeTab: FZTab.donate),
        ),
      );
      await tester.tap(find.text('Home'));
      await tester.pump();
      expect(mockNav.homeCalls, 1);
    });

    testWidgets('لا يجب استدعاء navigation عند النقر على التبويب النشط',
        (tester) async {
      await tester.pumpWidget(
        Provider<INavigationService>.value(
          value: mockNav,
          child: createTestWidget(activeTab: FZTab.home),
        ),
      );
      await tester.tap(find.text('Home'));
      await tester.pump();
      expect(mockNav.homeCalls, 0);
    });
  });

  testWidgets('يجب تحديث الحالة النشطة عند تغيير التبويب', (tester) async {
    await tester.pumpWidget(
      Provider<INavigationService>.value(
        value: mockNav,
        child: createTestWidget(activeTab: FZTab.home),
      ),
    );
    expect(find.text('Home'), findsOneWidget);

    await tester.pumpWidget(
      Provider<INavigationService>.value(
        value: mockNav,
        child: createTestWidget(activeTab: FZTab.donate),
      ),
    );
    expect(find.text('Donate'), findsOneWidget);

    await tester.pumpWidget(
      Provider<INavigationService>.value(
        value: mockNav,
        child: createTestWidget(activeTab: FZTab.about),
      ),
    );
    expect(find.text('About'), findsOneWidget);
  });
}
