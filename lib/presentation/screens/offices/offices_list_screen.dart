// 🏢 offices_list_screen.dart — شاشة عرض المكاتب مع بحث ذكي
import 'package:flutter/material.dart';
import 'package:al_faw_zakho/data/local/local_database.dart';
import 'package:al_faw_zakho/data/models/office_model.dart';

class OfficesListScreen extends StatefulWidget {
  const OfficesListScreen({super.key});

  @override
  State<OfficesListScreen> createState() => _OfficesListScreenState();
}

class _OfficesListScreenState extends State<OfficesListScreen> {
  late Future<List<OfficeModel>> _officesFuture;
  List<OfficeModel> _allOffices = [];
  List<OfficeModel> _filteredOffices = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _officesFuture = _loadOffices();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<OfficeModel>> _loadOffices() async {
    try {
final raw = LocalDatabase.getOffices();
final offices = raw
    .map((e) => OfficeModel.fromJson(Map<String, dynamic>.from(e as Map<String, dynamic>)))
    .toList();
      offices.sort((a, b) => a.province.compareTo(b.province));
      _allOffices = offices;
      _filteredOffices = offices;
      return offices;
    } catch (e) {
      debugPrint('❌ خطأ أثناء تحميل المكاتب: $e');
      final mock = MockDataService.getMockOffices();
      _allOffices = mock;
      _filteredOffices = mock;
      return mock;
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredOffices = _allOffices);
      return;
    }

    setState(() {
      _filteredOffices = _allOffices.where((office) {
        final nameAr = office.nameAr.toLowerCase();
        final nameEn = office.nameEn.toLowerCase();
        final managerAr = office.managerNameAr.toLowerCase();
        final managerEn = office.managerNameEn.toLowerCase();
        final province = office.province.toLowerCase();
        final district = office.district.toLowerCase();
        final services = office.services.join(' ').toLowerCase();

        return nameAr.contains(query) ||
            nameEn.contains(query) ||
            managerAr.contains(query) ||
            managerEn.contains(query) ||
            province.contains(query) ||
            district.contains(query) ||
            services.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color fawRed = Color(0xFFD32F2F);
    const Color fawGold = Color(0xFFFFD54F);
    const Color fawBlack = Color(0xFF1C1C1C);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? fawBlack : Colors.grey[100]!;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final titleColor = isDark ? fawGold : fawRed;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('🏢 مكاتب تجمع الفاو زاخو'),
        backgroundColor: isDark ? fawBlack : fawRed,
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSearchBar(fawRed, textColor),
          ),
        ),
      ),
      body: FutureBuilder<List<OfficeModel>>(
        future: _officesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: fawRed));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('حدث خطأ أثناء تحميل البيانات 😔', style: TextStyle(color: textColor)),
            );
          }

          if (_filteredOffices.isEmpty) {
            return Center(
              child: Text('لا توجد نتائج مطابقة 🔍', style: TextStyle(color: textColor, fontSize: 18)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: _filteredOffices.length,
            itemBuilder: (context, index) {
              final office = _filteredOffices[index];
              return _buildOfficeCard(context, office, titleColor, textColor, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(Color fawRed, Color textColor) {
    return TextField(
      controller: _searchController,
      cursorColor: fawRed,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        //withOpacity(0.9),
        hintText: 'ابحث باسم المكتب أو المدير أو المحافظة...',
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(Icons.search, color: fawRed),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () => _searchController.clear(),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildOfficeCard(BuildContext context, OfficeModel office, Color titleColor, Color textColor, bool isDark) {
    return Card(
      color: isDark ? Colors.grey[900] : Colors.white,
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.location_city, color: Color(0xFFD32F2F), size: 30),
        title: Text(
          '${office.nameAr} (${office.province})',
          style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Text(
          office.addressAr,
          style: TextStyle(color: textColor, fontSize: 14),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () => _openDetails(context, office),
      ),
    );
  }

  void _openDetails(BuildContext context, OfficeModel office) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OfficeDetailsScreen(office: office),
      ),
    );
  }
}

// 🗂️ شاشة تفاصيل المكتب
class OfficeDetailsScreen extends StatelessWidget {
  final OfficeModel office;
  const OfficeDetailsScreen({super.key, required this.office});

  @override
  Widget build(BuildContext context) {
    const Color fawRed = Color(0xFFD32F2F);
    const Color fawGold = Color(0xFFFFD54F);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final titleColor = isDark ? fawGold : fawRed;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : fawRed,
        title: Text(office.nameAr, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.apartment, size: 90, color: fawRed),
          const SizedBox(height: 12),
          _infoTile('📍 العنوان', office.addressAr, textColor, titleColor),
          _infoTile('🧭 المحافظة', office.province, textColor, titleColor),
          _infoTile('📞 الهاتف', office.phoneNumber, textColor, titleColor),
          if (office.secondaryPhone != null && office.secondaryPhone!.isNotEmpty)
            _infoTile('📱 رقم إضافي', office.secondaryPhone!, textColor, titleColor),
          _infoTile('✉️ البريد الإلكتروني', office.email, textColor, titleColor),
          _infoTile('👤 مدير المكتب', office.managerNameAr, textColor, titleColor),
          _infoTile('🕒 أوقات العمل', office.workingHours, textColor, titleColor),
          if (office.workingDays != null)
            _infoTile('📅 أيام العمل', office.workingDays!, textColor, titleColor),
          if (office.services.isNotEmpty)
            _infoTile('🔧 الخدمات المتوفرة', office.services.join('، '), textColor, titleColor),
          _infoTile('💪 الطاقة الاستيعابية', '${office.capacity} شخص', textColor, titleColor),
          if (office.notes != null && office.notes!.isNotEmpty)
            _infoTile('🗒️ ملاحظات', office.notes!, textColor, titleColor),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value, Color textColor, Color titleColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: textColor, fontSize: 15, height: 1.4)),
        ],
      ),
    );
  }
}
