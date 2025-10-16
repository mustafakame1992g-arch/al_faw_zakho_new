import 'package:flutter/material.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_bottom_nav.dart';

class FZScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? appBar; // NEW: AppBar مخصّص
  final FZTab? persistentBottom;

  const FZScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.appBar,
    this.persistentBottom,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedAppBar = appBar ??
        (title == null ? null : AppBar(title: Text(title!), actions: actions));
    final bottom = persistentBottom == null ? null : FZBottomNav(active: persistentBottom!);
    return Scaffold(appBar: resolvedAppBar, body: body, bottomNavigationBar: bottom);
  }
}
