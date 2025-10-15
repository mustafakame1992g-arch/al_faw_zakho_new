import 'package:flutter/material.dart';
import 'package:al_faw_zakho/presentation/themes/app_theme.dart';

/// 🧭 AppBar مخصص لشاشة الهوم
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSettingsTap;

  const HomeAppBar({super.key, required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AppBar(
      title: Text(
        'تجمع الفاو زاخو',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
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
