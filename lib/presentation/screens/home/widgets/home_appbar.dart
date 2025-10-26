import 'package:flutter/material.dart';
import 'package:al_faw_zakho/presentation/themes/app_theme.dart';
import 'package:al_faw_zakho/core/localization/app_localizations.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSettingsTap;
  const HomeAppBar({super.key, required this.onSettingsTap});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AppBar(
      title: Text(AppLocalizations.of(context).translate('app_title')),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.headerGradient(brightness),
        ),
      ),
      actions: [
        IconButton(
          tooltip: AppLocalizations.of(context).translate('settings'),
          onPressed: onSettingsTap,
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }
}
