import 'package:flutter/material.dart';
import 'package:al_faw_zakho/presentation/themes/app_theme.dart';
import 'package:al_faw_zakho/core/localization/app_localizations.dart';

/// 🧭 AppBar مخصص لشاشة الهوم
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSettingsTap;

  const HomeAppBar({super.key, required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AppBar(
title: Text(AppLocalizations.of(context).translate('app_title')),
        
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'الإعدادات',
          onPressed: onSettingsTap,
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.headerGradient(brightness),
        ),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
