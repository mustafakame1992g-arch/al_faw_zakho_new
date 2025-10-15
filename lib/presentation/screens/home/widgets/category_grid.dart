import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_faw_zakho/core/providers/language_provider.dart';

class CategoryGrid extends StatelessWidget {
  final Function(String) onCategorySelected;
  
  const CategoryGrid({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    final categories = [
      {
        'id': 'candidates',
        'icon': Icons.people,
        'color': Colors.blue,
        'title': _getCategoryTitle('candidates', languageProvider.locale.languageCode),
      },
      {
        'id': 'offices',
        'icon': Icons.business,
        'color': Colors.green,
        'title': _getCategoryTitle('offices', languageProvider.locale.languageCode),
      },
      {
        'id': 'program',
        'icon': Icons.article,
        'color': Colors.orange,
        'title': _getCategoryTitle('program', languageProvider.locale.languageCode),
      },
      {
        'id': 'faq',
        'icon': Icons.question_answer,
        'color': Colors.purple,
        'title': _getCategoryTitle('faq', languageProvider.locale.languageCode),
      },
      {
        'id': 'news',
        'icon': Icons.newspaper,
        'color': Colors.red,
        'title': _getCategoryTitle('news', languageProvider.locale.languageCode),
      },
      {
        'id': 'settings',
        'icon': Icons.settings,
        'color': Colors.grey,
        'title': _getCategoryTitle('settings', languageProvider.locale.languageCode),
      },
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(context, category);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => onCategorySelected(category['id']),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category['icon'], size: 40, color: category['color']),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                category['title'],
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryTitle(String category, String languageCode) {
    final titles = {
      'candidates': {'ar': 'المرشحين','en': 'Candidates',
},
      'offices': {'ar': 'المكاتب','en': 'Offices',},
      'program': {'ar': 'البرنامج','en': 'Program',},
      'faq': {'ar': 'الأسئلة','en': 'FAQ',},
      'news': {'ar': 'الأخبار', 'en': 'News',},
      'settings': {'ar': 'الإعدادات', 'en': 'Settings'},
    };
    
    return titles[category]?[languageCode] ?? titles[category]?['ar'] ?? category;
  }
}
