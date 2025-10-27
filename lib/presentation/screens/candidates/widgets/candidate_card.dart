import 'package:flutter/material.dart';
import 'package:al_faw_zakho/data/models/candidate_model.dart';

class CandidateCard extends StatelessWidget {
  final CandidateModel candidate;
  final VoidCallback? onTap;
  const CandidateCard({super.key, required this.candidate, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title =
        candidate.nameAr.isNotEmpty ? candidate.nameAr : candidate.nameEn;
    final nick = candidate.nicknameAr.isNotEmpty
        ? ' «${candidate.nicknameAr}»'
        : (candidate.nicknameEn.isNotEmpty ? ' «${candidate.nicknameEn}»' : '');
    final sub = [
      if (candidate.positionAr.isNotEmpty) candidate.positionAr,
      if (candidate.province.isNotEmpty) candidate.province,
    ].join(' • ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: _avatar(theme),
          title: Text(title + nick, style: theme.textTheme.titleMedium),
          subtitle:
              sub.isEmpty ? null : Text(sub, style: theme.textTheme.bodySmall),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  Widget _avatar(ThemeData theme) {
    final path = candidate.imagePath.isNotEmpty
        ? candidate.imagePath
        : 'assets/images/logo.png';
    return CircleAvatar(
      radius: 24,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: .08),
      child: ClipOval(
        child: Image.asset(
          path,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.person, color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}
