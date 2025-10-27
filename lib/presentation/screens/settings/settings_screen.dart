import 'package:al_faw_zakho/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_faw_zakho/core/providers/theme_provider.dart';
import 'package:al_faw_zakho/core/providers/language_provider.dart';
import 'package:al_faw_zakho/core/services/analytics_service.dart';

/// ⚙️ شاشة الإعدادات المتكاملة (لغة + مظهر + حول التطبيق)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: const _SettingsBody(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        context.tr('settings'),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      elevation: 2,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: const [
        _AppearanceSection(),
        SizedBox(height: 24),
        _LanguageSection(),
        SizedBox(height: 24),
        _AboutSection(),
        SizedBox(height: 32),
        _AppVersionFooter(),
      ],
    );
  }
}

/// 🎨 قسم المظهر (الوضع الليلي والنهاري)
class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: context.tr('appearance'),
      icon: Icons.palette,
      children: [
        _SettingCard(child: _ThemeSwitchTile()),
      ],
    );
  }
}

/// 🌍 قسم اللغة
class _LanguageSection extends StatelessWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: context.tr('language'),
      icon: Icons.language,
      children: [
        _SettingCard(child: _LanguageSelectionTile()),
      ],
    );
  }
}

/// ℹ️ قسم حول التطبيق
class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: context.tr('about_app'),
      icon: Icons.info,
      children: [
        _SettingCard(child: _AppInfoDetails()),
      ],
    );
  }
}

/// 🧩 عنصر القسم العام
class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}

/// 🪟 بطاقة إعداد فرعية
class _SettingCard extends StatelessWidget {
  final Widget child;

  const _SettingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}

/// 🌗 تبديل السمة (نهاري / ليلي / نظام)
class _ThemeSwitchTile extends StatelessWidget {
  const _ThemeSwitchTile();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentMode = themeProvider.themeMode;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.brightness_6, color: Colors.orange, size: 22),
      ),
      title: Text(context.tr('dark_mode')),
      subtitle: Text(
        _getThemeSubtitle(context, currentMode),
        style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
      ),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<ThemeMode>(
          value: currentMode,
          onChanged: (mode) async {
            if (mode == null) return;
            AnalyticsService.trackEvent('theme_changed', parameters: {
              'from': currentMode.toString(),
              'to': mode.toString(),
            });
            await themeProvider.setTheme(mode);
          },
          items: [
            DropdownMenuItem(
              value: ThemeMode.light,
              child: Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(context.tr('light_mode')),
                ],
              ),
            ),
            DropdownMenuItem(
              value: ThemeMode.dark,
              child: Row(
                children: [
                  const Icon(Icons.nights_stay_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(context.tr('dark_mode')),
                ],
              ),
            ),
            DropdownMenuItem(
              value: ThemeMode.system,
              child: Row(
                children: [
                  const Icon(Icons.auto_mode_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(context.tr('system_default')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeSubtitle(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return context.tr('dark_mode_enabled');
      case ThemeMode.light:
        return context.tr('light_mode_enabled');
      case ThemeMode.system:
        return context.tr('system_mode_enabled');
    }
  }
}

/// 🌍 اختيار اللغة
class _LanguageSelectionTile extends StatefulWidget {
  @override
  State<_LanguageSelectionTile> createState() => _LanguageSelectionTileState();
}

class _LanguageSelectionTileState extends State<_LanguageSelectionTile> {
  bool _isChangingLanguage = false;

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.languageCode;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.translate, color: Colors.blue, size: 22),
      ),
      title: Text(context.tr('language')),
      subtitle: Text(
        _getLanguageDisplayName(currentLanguage, context),
        style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
      ),
      trailing: _buildLanguageDropdown(languageProvider),
    );
  }

  Widget _buildLanguageDropdown(LanguageProvider languageProvider) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isChangingLanguage
          ? SizedBox(
              key: const ValueKey('loading'),
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).primaryColor,
              ),
            )
          : DropdownButtonHideUnderline(
              key: const ValueKey('dropdown'),
              child: DropdownButton<String>(
                value: languageProvider.languageCode,
                icon: const Icon(Icons.arrow_drop_down, size: 20),
                elevation: 2,
                onChanged: _handleLanguageChange,
                items: _buildLanguageItems(context),
              ),
            ),
    );
  }

  List<DropdownMenuItem<String>> _buildLanguageItems(BuildContext context) {
    return [
      DropdownMenuItem(
        value: 'ar',
        child: Row(
          children: [
            const Text('🇮🇶'),
            const SizedBox(width: 8),
            Text(context.tr('arabic')),
          ],
        ),
      ),
      DropdownMenuItem(
        value: 'en',
        child: Row(
          children: [
            const Text('🇺🇸'),
            const SizedBox(width: 8),
            Text(context.tr('english')),
          ],
        ),
      ),
    ];
  }

  Future<void> _handleLanguageChange(String? newCode) async {
    if (newCode == null || _isChangingLanguage) return;

    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    if (newCode == languageProvider.languageCode) return;

    setState(() => _isChangingLanguage = true);

    try {
      await languageProvider.setLanguage(newCode);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('language_changed')),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isChangingLanguage = false);
    }
  }

  String _getLanguageDisplayName(String code, BuildContext context) {
    switch (code) {
      case 'ar':
        return context.tr('arabic');
      case 'en':
        return context.tr('english');
      default:
        return context.tr('arabic');
    }
  }
}

/// 📱 تفاصيل التطبيق
class _AppInfoDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.flag,
                      size: 32, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 12),
                Text(context.tr('app_title'),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  context.tr('political_election'),
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                      height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          _InfoRow(
              icon: Icons.verified,
              label: context.tr('version'),
              value: '1.0.0'),
          _InfoRow(
              icon: Icons.build,
              label: context.tr('build'),
              value: '2025.01.01'),
          _InfoRow(
              icon: Icons.update,
              label: context.tr('last_update'),
              value: 'Jan 2025'),
          _InfoRow(
              icon: Icons.security,
              label: context.tr('status'),
              value: context.tr('stable')),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).hintColor),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface)),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                style: TextStyle(color: Theme.of(context).hintColor),
                textAlign: TextAlign.start),
          ),
        ],
      ),
    );
  }
}

/// 🧾 التذييل
class _AppVersionFooter extends StatelessWidget {
  const _AppVersionFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Text(
          'Al-Faw Zakho Gathering © 2025',
          style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr('all_rights_reserved'),
          style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
        ),
      ],
    );
  }
}
