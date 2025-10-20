import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_faw_zakho/core/navigation/navigation_service.dart';
import 'package:al_faw_zakho/core/localization/app_localizations.dart';
enum FZTab { home,  donate, about }

class FZBottomNav extends StatelessWidget {
  final FZTab active;
  const FZBottomNav({super.key, required this.active});

  int _toIndex(FZTab t) => switch (t) {
    FZTab.home => 0,
    //FZTab.offices => 3,
    FZTab.donate => 1,
    FZTab.about => 2
  };

  @override
  Widget build(BuildContext context) {
    final nav = context.read<INavigationService>();
    return NavigationBar(
      selectedIndex: _toIndex(active),
      onDestinationSelected: (i) {
        
        switch (i) {
          case 0: nav.goHome(context); break;
         // case 3: nav.goOffices(context); break;
          case 1: nav.goDonate(context); break;
          case 2: nav.goAbout(context); break;
        }
      },
      destinations: [
        NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context).translate('home'),
        ),
        NavigationDestination(
            icon: const Icon(Icons.volunteer_activism_outlined),
            selectedIcon: const Icon(Icons.volunteer_activism),
            label: AppLocalizations.of(context).translate('donate'),
        ),
        NavigationDestination(
            icon: const Icon(Icons.info_outline),
            selectedIcon: const Icon(Icons.info),
            label: AppLocalizations.of(context).translate('about_app'),
        ),
        ],
    );
  }
}
