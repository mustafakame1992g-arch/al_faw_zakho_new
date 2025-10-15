import 'package:flutter/material.dart';
import 'package:al_faw_zakho/data/models/candidate_model.dart';

class CandidateCard extends StatelessWidget {
  final CandidateModel candidate;
  final VoidCallback? onTap;

  const CandidateCard({
    super.key,
    required this.candidate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: ListTile(
        leading: _buildCandidateAvatar(),
        title: Text(
          candidate.nameAr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(candidate.positionAr),
            Text(
              candidate.province,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCandidateAvatar() {
    // إصلاح: استخدام أيقونة بدلاً من صورة مفقودة
    return CircleAvatar(
      radius: 25,
      backgroundColor: Colors.blue[100],
      child: const Icon(Icons.person, color: Colors.blue, size: 24),
    );
    
    // أو استخدام صورة افتراضية من Flutter
    // return CircleAvatar(
    //   radius: 25,
    //   backgroundColor: Colors.grey[200],
    //   backgroundImage: const AssetImage('assets/images/placeholder.png'),
    //   child: candidate.imageUrl.isNotEmpty && candidate.imageUrl != 'assets/placeholder.png'
    //       ? null
    //       : const Icon(Icons.person, color: Colors.grey),
    // );
  }
}
