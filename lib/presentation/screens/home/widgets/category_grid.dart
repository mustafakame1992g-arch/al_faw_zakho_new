import 'package:al_faw_zakho/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.onCategorySelected,
  });

  /// أوضح من void Function(String)
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final langCode = context.watch<LanguageProvider>().locale.languageCode;
    final categories = _buildCategories(langCode);
    return _buildGridView(context, categories);
  }

  // فصل بناء القائمة لقراءة أوضح
  List<CategoryItem> _buildCategories(String langCode) {
    return [
      CategoryItem(
        id: 'candidates',
        icon: Icons.people,
        color: Colors.blue,
        title: _getCategoryTitle('candidates', langCode),
      ),
      CategoryItem(
        id: 'offices',
        icon: Icons.business,
        color: Colors.green,
        title: _getCategoryTitle('offices', langCode),
      ),
      CategoryItem(
        id: 'program',
        icon: Icons.article,
        color: Colors.orange,
        title: _getCategoryTitle('program', langCode),
      ),
      CategoryItem(
        id: 'faq',
        icon: Icons.question_answer,
        color: Colors.purple,
        title: _getCategoryTitle('faq', langCode),
      ),
      CategoryItem(
        id: 'news',
        icon: Icons.newspaper,
        color: Colors.red,
        title: _getCategoryTitle('news', langCode),
      ),
      CategoryItem(
        id: 'settings',
        icon: Icons.settings,
        color: Colors.grey,
        title: _getCategoryTitle('settings', langCode),
      ),
    ];
  }

  Widget _buildGridView(BuildContext context, List<CategoryItem> categories) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 600 ? 3 : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryCard(
          category: category,
          onTap: () => onCategorySelected(category.id),
        );
      },
    );
  }

  String _getCategoryTitle(String key, String lang) {
    const Map<String, Map<String, String>> titles = {
      'candidates': {'ar': 'المرشحين', 'en': 'Candidates'},
      'offices': {'ar': 'المكاتب', 'en': 'Offices'},
      'program': {'ar': 'البرنامج', 'en': 'Program'},
      'faq': {'ar': 'الأسئلة', 'en': 'FAQ'},
      'news': {'ar': 'الأخبار', 'en': 'News'},
      'settings': {'ar': 'الإعدادات', 'en': 'Settings'},
    };
    return titles[key]?[lang] ?? titles[key]?['ar'] ?? key;
  }
}

class CategoryItem {
  const CategoryItem({
    required this.id,
    required this.icon,
    required this.color,
    required this.title,
  });
  final String id;
  final IconData icon;
  final Color color;
  final String title;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  final CategoryItem category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    return Semantics(
      button: true,
      label: category.title,
      child: Material(
        shape: shape,
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, size: 40, color: category.color),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  category.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
