import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // مهم
import 'package:al_faw_zakho/core/navigation/navigation_service.dart';
import 'package:al_faw_zakho/core/localization/app_localizations.dart';


INavigationService _getNav(BuildContext context) {
  try {
    // ✅ لازم النوع غير nullable ليتطابق مع Provider<INavigationService>
    return Provider.of<INavigationService>(context, listen: false);
  } catch (_) {
    // ✅ Fallback لو ما كان فيه Provider في الشجرة (مثل التشغيل العادي)
    return NavigationService();
  }
}
enum FZTab { home, donate, about }

class FZBottomNav extends StatelessWidget {
  final FZTab active;
  const FZBottomNav({super.key, required this.active});

  int get _selectedIndex => switch (active) {
        FZTab.home => 0,
        FZTab.donate => 1,
        FZTab.about => 2,
      };

  @override
Widget build(BuildContext context) {
  final t = AppLocalizations.of(context);
  final nav = _getNav(context); // ← بدّل السطرين السابقين بهذا

  return NavigationBar(
    selectedIndex: _selectedIndex,
    onDestinationSelected: (i) {
      if (i == _selectedIndex) return;
      switch (i) {
        case 0: nav.goHome(context); break;
        case 1: nav.goDonate(context); break;
        case 2: nav.goAbout(context); break;
      }
  },
  destinations: [
    NavigationDestination(
      icon: const Icon(Icons.home_outlined, key: ValueKey('tab_home')),
      selectedIcon: const Icon(Icons.home, key: ValueKey('tab_home')),
      label: t.translate('home'),
    ),
    NavigationDestination(
      icon: const Icon(Icons.volunteer_activism_outlined, key: ValueKey('tab_donate')),
      selectedIcon: const Icon(Icons.volunteer_activism, key: ValueKey('tab_donate')),
      label: t.translate('donate'),
    ),
    NavigationDestination(
      icon: const Icon(Icons.info_outline, key: ValueKey('tab_about')),
      selectedIcon: const Icon(Icons.info, key: ValueKey('tab_about')),
      label: t.translate('about_app'),
    ),
  ],
);
  }
}
