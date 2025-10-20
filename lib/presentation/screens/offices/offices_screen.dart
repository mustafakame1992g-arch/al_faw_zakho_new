// lib/presentation/screens/offices/offices_main_screen.dart
import 'package:flutter/material.dart';
import 'package:al_faw_zakho/data/local/local_database.dart';
import 'package:al_faw_zakho/data/models/office_model.dart';
import 'package:al_faw_zakho/core/services/analytics_service.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_scaffold.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_bottom_nav.dart';

class OfficesScreen extends StatefulWidget {
  const OfficesScreen({super.key});

  @override
  State<OfficesScreen> createState() => _OfficesScreenState();
}

class _OfficesScreenState extends State<OfficesScreen> {
  List<OfficeModel> _offices = [];
  List<OfficeModel> _filteredOffices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOffices();
    AnalyticsService.trackEvent('offices_screen_opened');
  }

  Future<void> _loadOffices() async {
    setState(() => _isLoading = true);

    try {
      await LocalDatabase.bootstrapOfficesFromAssets();
      final offices = await LocalDatabase.getAllOffices();

      setState(() {
        _offices = offices;
        _filteredOffices = offices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل المكاتب: $e')),
      );
    }
  }

  void _filterOffices(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredOffices = _offices;
      } else {
        _filteredOffices = _offices.where((o) {
          return o.province.toLowerCase().contains(q) ||
                 o.nameAr.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  void _showOfficeDetails(OfficeModel office) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .9),
                blurRadius: 10,
                offset: const Offset(0, -3),
              )
            ],
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Text(
                    office.nameAr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '📍 ${office.province} - ${office.district}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blueGrey,
                        ),
                  ),
                  const Divider(height: 24, thickness: 1.2),
                  _buildDetailRow(Icons.person, 'المدير', office.managerNameAr),
                  _buildDetailRow(Icons.location_on, 'العنوان', office.addressAr),
                  _buildDetailRow(Icons.phone, 'الهاتف', office.phoneNumber),
                  _buildDetailRow(Icons.access_time, 'ساعات العمل', office.workingHours),
                  if (office.email.isNotEmpty)
                    _buildDetailRow(Icons.email, 'البريد الإلكتروني', office.email),
                  if (office.notes != null && office.notes!.isNotEmpty)
                    _buildDetailRow(Icons.note, 'ملاحظات', office.notes!),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('تم'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade600, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
     return FZScaffold(
      appBar: AppBar(
        title: const Text('🏢 مكاتب المحافظات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOffices,
          ),
        ],
      ),
  persistentBottom: FZTab.home, // أو about, المهم تمرّر شيء لتفعيل الشريط

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(isDark),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _filteredOffices.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            itemCount: _filteredOffices.length,
                            itemBuilder: (context, index) {
                              final office = _filteredOffices[index];
                              return _buildOfficeCard(office, index);
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withValues(alpha: .7),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: TextField(
        onChanged: _filterOffices,
        decoration: const InputDecoration(
          hintText: 'ابحث عن محافظة...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildOfficeCard(OfficeModel office, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showOfficeDetails(office),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade700,
                  Colors.blue.shade400,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_city, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'مكتب محافظة ${office.province}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.business_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('لا توجد مكاتب مطابقة لبحثك'),
        ],
      ),
    );
  }
}
