import 'dart:developer' as developer; // 🔥 اللمسة 1: استيراد developer

import 'package:al_faw_zakho/core/localization/app_localizations.dart';
import 'package:al_faw_zakho/core/services/analytics_service.dart';
import 'package:al_faw_zakho/data/local/local_database.dart';
import 'package:al_faw_zakho/data/models/office_model.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_bottom_nav.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_scaffold.dart';
import 'package:flutter/material.dart';

class OfficesScreen extends StatefulWidget {
  const OfficesScreen({super.key});

  @override
  State<OfficesScreen> createState() => _OfficesScreenState();
}

class _OfficesScreenState extends State<OfficesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<OfficeModel> _allOffices = [];
  List<OfficeModel> _filteredOffices = [];
  bool _loading = true;
  bool _forceRefreshMode = false;

  // 🎨 ألوان موحدة
  static const Color fawRed = Color(0xFFD32F2F);
  static const Color fawGold = Color(0xFFFFD54F);
  static const Color fawBlack = Color(0xFF1C1C1C);

  @override
  void initState() {
    super.initState();
    _loadOffices();
    AnalyticsService.trackEvent('offices_screen_opened');
  }

  // 🔥 اللمسة 3: التخلص من تسريب الـ TextEditingController
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOffices() async {
    setState(() => _loading = true);

    try {
      // 1️⃣ تأكد من التهيئة (تتضمن seeding من الأصول إذا الصناديق فارغة)
      await LocalDatabase.init();

      // 2️⃣ جلب المكاتب (دالة sync)
      var offices = LocalDatabase.getOffices();

      // 3️⃣ إذا لا توجد بيانات، أعد التهيئة بعد التفريغ
      if (offices.isEmpty) {
        await LocalDatabase.clearOffices();
        await LocalDatabase.init();
        offices = LocalDatabase.getOffices();
      }

      // 🔥 اللمسة 2: منع setState بعد dispose
      if (!mounted) return;
      setState(() {
        _allOffices = offices;
        _filteredOffices = offices;
        _loading = false;
        _forceRefreshMode = false;
      });

      AnalyticsService.trackEvent(
        'offices_loaded',
        parameters: {
          'count': offices.length,
          'force_refresh': _forceRefreshMode,
        },
      );
    } catch (e, stack) {
      developer.log(
        '❌ Failed to load offices: $e',
        name: 'OFFICES',
        error: e,
        stackTrace: stack,
      );

      // 🔥 اللمسة 2: منع setState بعد dispose
      if (!mounted) return;
      setState(() => _loading = false);

      // 🚨 عرض رسالة خطأ للمستخدم
      _showErrorSnackbar();
    }
  }

  Future<void> _forceReloadOffices() async {
    // 🔥 اللمسة 2: منع setState بعد dispose
    if (!mounted) return;
    setState(() {
      _loading = true;
      _forceRefreshMode = true;
    });

    try {
      await LocalDatabase.clearOffices();
      await LocalDatabase.init();
      final offices = LocalDatabase.getOffices();

      // 🔥 اللمسة 2: منع setState بعد dispose
      if (!mounted) return;
      setState(() {
        _allOffices = offices;
        _filteredOffices = offices;
        _loading = false;
        _forceRefreshMode = false;
      });

      AnalyticsService.trackEvent(
        'offices_force_reloaded',
        parameters: {
          'count': offices.length,
        },
      );

      // ✅ إشعار المستخدم بنجاح التحديث
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar() // ← إزالة السابق
          ..showSnackBar(
            SnackBar(
              content: Text('تم تحديث بيانات المكاتب (${offices.length} مكتب)'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
      }
    } catch (e, stack) {
      developer.log(
        '❌ Force reload failed: $e',
        name: 'OFFICES',
        error: e,
        stackTrace: stack,
      );

      // 🔥 اللمسة 2: منع setState بعد dispose
      if (!mounted) return;
      setState(() => _loading = false);
      _showErrorSnackbar();
    }
  }

  void _showErrorSnackbar() {
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في تحميل البيانات'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
    }
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();

    // 🔥 اللمسة 4: تلين البحث ضد أي قيم خالية
    setState(() {
      _filteredOffices = _allOffices.where((office) {
        final province = office.province.toLowerCase();
        final nameAr = office.nameAr.toLowerCase();
        final managerNameAr = office.managerNameAr.toLowerCase();

        return province.contains(q) ||
            nameAr.contains(q) ||
            managerNameAr.contains(q);
      }).toList();
    });
  }

  void _clearSearch() {
    // 🔥 اللمسة 2: منع setState بعد dispose
    if (!mounted) return;
    setState(() {
      _searchController.clear();
      _filteredOffices = _allOffices;
    });
  }

  void _showOfficeDetails(OfficeModel office) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? fawBlack : Colors.white;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final titleColor = isDark ? fawGold : fawRed;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.apartment, color: fawRed, size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        office.nameAr,
                        style: TextStyle(
                          fontSize: 20,
                          color: titleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 10),
                _detailRow(
                  Icons.location_on,
                  'العنوان',
                  office.addressAr,
                  textColor,
                ),
                _detailRow(
                  Icons.person,
                  'المدير',
                  office.managerNameAr,
                  textColor,
                ),
                _detailRow(
                  Icons.phone,
                  'الهاتف',
                  office.phoneNumber,
                  textColor,
                  isPhone: true, // ← إضافة هذا الباراميتر
                ),
                _detailRow(
                  Icons.access_time,
                  'ساعات العمل',
                  office.workingHours,
                  textColor,
                ),
                if (office.email.isNotEmpty)
                  _detailRow(
                    Icons.email_outlined,
                    'البريد الإلكتروني',
                    office.email,
                    textColor,
                    isEmail: true, // ← إضافة هذا الباراميتر
                  ),
                _detailRow(Icons.map, 'المحافظة', office.province, textColor),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(AppLocalizations.of(context).translate('done')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: fawRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
    Color textColor, {
    bool isPhone = false,
    bool isEmail = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fawGold, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                // النص العادي أو القابل للنسخ/الاتصال
                if (isPhone || isEmail)
                  InkWell(
                    onTap: () {
                      if (isPhone) {
                        // فتح تطبيق الاتصال
                        // يمكن إضافة package like: url_launcher
                      } else if (isEmail) {
                        // فتح تطبيق البريد
                      }
                    },
                    child: Text(
                      value,
                      style: TextStyle(
                        color: isPhone || isEmail ? Colors.blue : textColor,
                        fontSize: 15,
                        height: 1.4,
                        decoration: isPhone || isEmail
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  )
                else
                  SelectableText(
                    // ← نص قابل للتحديد والنسخ
                    value,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return FZScaffold(
      appBar: AppBar(
        backgroundColor: isDark ? fawBlack : fawRed,
        title:
            Text(AppLocalizations.of(context).translate('provincial_offices')),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: _forceRefreshMode
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _forceRefreshMode ? null : _forceReloadOffices,
            tooltip: 'تحديث قوي من الأصول',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSearchBar(isDark, textColor),
          ),
        ),
      ),
      persistentBottom: FZTab.home,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: fawRed))
          : _filteredOffices.isEmpty
              ? _buildEmptyState(textColor)
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _filteredOffices.length,
                  itemBuilder: (context, index) {
                    final office = _filteredOffices[index];
                    return _buildOfficeCard(office, isDark);
                  },
                ),
    );
  }

  Widget _buildSearchBar(bool isDark, Color textColor) {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      cursorColor: fawRed,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        filled: true,
        fillColor:
            isDark ? Colors.grey[850] : Colors.white.withValues(alpha: .95),
        hintText: 'ابحث عن مكتب أو مدير أو محافظة...',
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: const Icon(Icons.search, color: fawRed),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: _clearSearch,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildOfficeCard(OfficeModel office, bool isDark) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(
          Icons.business,
          color: Color.fromARGB(255, 52, 25, 72),
          size: 30,
        ),
        title: Text(
          '${office.nameAr} (${office.province})',
          style: const TextStyle(
            color: Color.fromARGB(255, 36, 34, 118),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        subtitle: Text(
          office.addressAr,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: fawGold),
        onTap: () => _showOfficeDetails(office),
      ),
    );
  }

  // استبدل دالة _buildEmptyState() بهذه النسخة المحسنة
  Widget _buildEmptyState(Color textColor) {
    final bool hasSearchQuery = _searchController.text.trim().isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearchQuery ? Icons.search_off : Icons.business_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            hasSearchQuery
                ? 'لا توجد مكاتب مطابقة لبحثك'
                : 'لا توجد مكاتب متاحة',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!hasSearchQuery) ...[
            const SizedBox(height: 8),
            Text(
              'جرب تحديث البيانات أو تأكد من اتصال الإنترنت',
              style: TextStyle(
                color: textColor.withValues(alpha: .7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _forceReloadOffices,
            icon: const Icon(Icons.refresh),
            label: Text(hasSearchQuery ? 'إعادة البحث' : 'تحديث البيانات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: fawRed,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
