import 'package:flutter/material.dart';
import 'package:al_faw_zakho/core/navigation/navigation_service.dart';
import 'package:al_faw_zakho/core/localization/app_localizations.dart';

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
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) {
        if (i == _selectedIndex) return;
        final nav = NavigationService();
        switch (i) {
          case 0: nav.goHome(context); break;
          case 1: nav.goDonate(context); break;
          case 2: nav.goAbout(context); break;
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: t.translate('home'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.volunteer_activism_outlined),
          selectedIcon: const Icon(Icons.volunteer_activism),
          label: t.translate('donate'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.info_outline),
          selectedIcon: const Icon(Icons.info),
          label: t.translate('about_app'),
        ),
      ],
    );
  }
}
