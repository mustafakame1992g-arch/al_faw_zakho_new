import 'package:flutter/material.dart';
import 'package:al_faw_zakho/core/localization/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context).translate('home'))),
      body: Center(
          child:
              Text(AppLocalizations.of(context).translate('app_running_msg'))),
    );
  }
}
