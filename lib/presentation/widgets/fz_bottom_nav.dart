import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_faw_zakho/core/navigation/navigation_service.dart';

enum FZTab { home, offices, donate, about }

class FZBottomNav extends StatelessWidget {
  final FZTab active;
  const FZBottomNav({super.key, required this.active});

  int _toIndex(FZTab t) => switch (t) {
    FZTab.home => 0,
    FZTab.offices => 1,
    FZTab.donate => 2,
    FZTab.about => 3
  };

  @override
  Widget build(BuildContext context) {
    final nav = context.read<INavigationService>();
    return NavigationBar(
      selectedIndex: _toIndex(active),
      onDestinationSelected: (i) {
        switch (i) {
          case 0: nav.goHome(context); break;
          case 1: nav.goOffices(context); break;
          case 2: nav.goDonate(context); break;
          case 3: nav.goAbout(context); break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
        NavigationDestination(icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent), label: 'مكاتبنا'),
        NavigationDestination(icon: Icon(Icons.volunteer_activism_outlined), selectedIcon: Icon(Icons.volunteer_activism), label: 'تبرع'),
        NavigationDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: 'حولَة'),
      ],
    );
  }
}
