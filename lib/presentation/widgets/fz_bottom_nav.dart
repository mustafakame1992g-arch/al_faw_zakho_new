import 'package:al_faw_zakho/core/navigation/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum FZTab { home, donate, about }

class FZBottomNav extends StatelessWidget {
  const FZBottomNav({super.key, required this.active});
  final FZTab active;

  int get _selectedIndex => switch (active) {
        FZTab.home => 0,
        FZTab.donate => 1,
        FZTab.about => 2,
      };

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) {
        if (i == _selectedIndex) return;

        final nav = Provider.of<INavigationService>(context, listen: false);
        switch (i) {
          case 0:
            nav.goHome(context);
            break;
          case 1:
            nav.goDonate(context);
            break;
          case 2:
            nav.goAbout(context);
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.volunteer_activism_outlined),
          selectedIcon: Icon(Icons.volunteer_activism),
          label: 'Donate',
        ),
        NavigationDestination(
          icon: Icon(Icons.info_outline),
          selectedIcon: Icon(Icons.info),
          label: 'About',
        ),
      ],
    );
  }
}
