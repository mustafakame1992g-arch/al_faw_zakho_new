// 🏢 offices_main_screen.dart — نسخة موحدة الألوان مع شاشات المرشحين
import 'package:flutter/material.dart';
import 'package:al_faw_zakho/data/local/local_database.dart';
import 'package:al_faw_zakho/data/models/office_model.dart';

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

  // 🎨 ألوان الفاو زاخو الرسمية
  static const Color fawRed = Color(0xFFD32F2F);
  static const Color fawGold = Color(0xFFFFD54F);
  static const Color fawBlack = Color(0xFF1C1C1C);

  @override
  void initState() {
    super.initState();
    _loadOffices();
  }

  Future<void> _loadOffices() async {
    setState(() => _loading = true);
    final offices = await LocalDatabase.getAllOffices();
    setState(() {
      _allOffices = offices;
      _filteredOffices = offices;
      _loading = false;
    });
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filteredOffices = _allOffices.where((o) {
        return o.province.toLowerCase().contains(q) ||
            o.nameAr.toLowerCase().contains(q) ||
            o.managerNameAr.toLowerCase().contains(q);
      }).toList();
    });
  }

  void _showOfficeDetails(OfficeModel office) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? fawBlack : Colors.white;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final titleColor = isDark ? fawGold : fawRed;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
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
              _detailRow(Icons.location_on, 'العنوان', office.addressAr, textColor),
              _detailRow(Icons.person, 'المدير', office.managerNameAr, textColor),
              _detailRow(Icons.phone, 'الهاتف', office.phoneNumber, textColor),
              _detailRow(Icons.access_time, 'ساعات العمل', office.workingHours, textColor),
              if (office.email.isNotEmpty)
                _detailRow(Icons.email_outlined, 'البريد الإلكتروني', office.email, textColor),
              _detailRow(Icons.map, 'المحافظة', office.province, textColor),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'تجمع الفاو زاخو',
                  style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fawGold, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? fawBlack : Colors.grey[100]!;
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? fawBlack : fawRed,
        title: const Text('🏢 مكاتب تجمع الفاو زاخو'),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSearchBar(isDark, textColor),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: fawRed))
          : _filteredOffices.isEmpty
              ? Center(
                  child: Text('لا توجد نتائج مطابقة 🔍',
                      style: TextStyle(color: textColor, fontSize: 18)))
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
        fillColor: isDark ? Colors.grey[850] : Colors.white.withValues(alpha: .95),
        hintText: 'ابحث عن مكتب أو مدير أو محافظة...',
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: const Icon(Icons.search, color: fawRed),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () => setState(() {
                  _searchController.clear();
                  _filteredOffices = _allOffices;
                }),
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
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    return Card(
      color: cardColor,
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.business, color: Color.fromARGB(255, 52, 25, 72), size: 30),
        title: Text(
          '${office.nameAr} (${office.province})',
          style: const TextStyle(
              color: Color.fromARGB(255, 36, 34, 118), fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Text(
          office.addressAr,
          style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87, fontSize: 14),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: fawGold),
        onTap: () => _showOfficeDetails(office),
      ),
    );
  }
}
