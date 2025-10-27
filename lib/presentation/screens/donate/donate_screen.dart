import 'package:al_faw_zakho/core/localization/app_localizations.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_bottom_nav.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_scaffold.dart';
import 'package:flutter/material.dart';

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
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ادعم تجمع الفاو زاخو',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
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
              title: Text(
                AppLocalizations.of(context).translate('donate_via_zaincash'),
              ),
              subtitle: Text(
                AppLocalizations.of(context)
                    .translate('open_zaincash_and_send_to'),
              ),
              trailing: const Icon(Icons.qr_code),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          '${AppLocalizations.of(context).translate('number_label')}: 0780-XXX-XXXX',
                        ),
                        Text(
                          '${AppLocalizations.of(context).translate('name_label')}: ${AppLocalizations.of(context).translate('about_name')}',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${AppLocalizations.of(context).translate('description_label')}: ${AppLocalizations.of(context).translate('donation_description')}',
                        ),
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
              title: Text(AppLocalizations.of(context).translate('bank_card')),
              subtitle:
                  Text(AppLocalizations.of(context).translate('coming_soon')),
            ),
          ),
        ],
      ),
    );
  }
}
