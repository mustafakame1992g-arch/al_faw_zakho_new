import 'package:al_faw_zakho/presentation/widgets/fz_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_scaffold.dart';

class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FZScaffold(
      title: 'تبرّع للتجمع',
      persistentBottom: FZTab.donate,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('ادعم تجمع الفاو زاخو', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('مساهمتك تحدث فرقًا حقيقيًا — شكرًا لدعمك!'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('التبرع عبر زين كاش'),
              subtitle: const Text('افتح تطبيق ZainCash ثم المسح/الإرسال إلى الرقم التالي'),
              trailing: const Icon(Icons.qr_code),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('تفاصيل زين كاش', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('الرقم: 0780-XXX-XXXX'),
                        Text('الاسم: تجمع الفاو زاخو'),
                        SizedBox(height: 8),
                        Text('الوصف: تبرع دعم الحملة'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('بطاقة مصرفية'),
              subtitle: const Text('قريبًا — قنوات دفع إضافية.'),
            ),
          ),
        ],
      ),
    );
  }
}
