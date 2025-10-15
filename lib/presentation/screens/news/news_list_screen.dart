// 📰 news_list_screen.dart — شاشة عرض الأخبار (FAW ZAKHO)
/*import 'package:flutter/material.dart';
import 'package:al_faw_zakho/data/local/local_database.dart';
import 'package:al_faw_zakho/data/models/news_model.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}



class _NewsListScreenState extends State<NewsListScreen> {
  late Future<List<NewsModel>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _loadNews();
  }

  Future<List<NewsModel>> _loadNews() async {
    final news = await LocalDatabase.getNews();
    // ترتيب الأخبار حسب التاريخ الأحدث
    news.sort((a, b) => b.publishDate.compareTo(a.publishDate));
    return news;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 🎨 ألوان هوية تجمع الفاو زاخو
    const Color fawRed = Color(0xFFD32F2F);
    const Color fawGold = Color(0xFFFFD54F);
    const Color fawBlack = Color(0xFF1C1C1C);

    final backgroundColor = isDark ? fawBlack : Colors.grey[100]!;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final titleColor = isDark ? fawGold : fawRed;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('📰 أخبار تجمع الفاو زاخو'),
        backgroundColor: isDark ? fawBlack : fawRed,
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<NewsModel>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: fawRed));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'حدث خطأ أثناء تحميل الأخبار 😔',
                style: TextStyle(color: textColor),
              ),
            );
          }

          final newsList = snapshot.data ?? [];
          if (newsList.isEmpty) {
            return Center(
              child: Text(
                'لا توجد أخبار حالياً',
                style: TextStyle(color: textColor, fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              final title = _getNewsTitle(news, context);
              final date = _formatDate(news.publishDate);
              return GestureDetector(
                onTap: () => _openDetails(context, news),
                child: Card(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (news.imagePath.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.asset(
                            news.imagePath,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 180,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 50),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              date,
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 13),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _getNewsPreview(news, context),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: textColor, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🔤 اختيار العنوان حسب اللغة الحالية
  String _getNewsTitle(NewsModel news, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'en' && news.titleEn.isNotEmpty) {
      return news.titleEn;
    }
    return news.titleAr.isNotEmpty ? news.titleAr : news.titleEn;
  }

  // 📝 ملخص المحتوى
  String _getNewsPreview(NewsModel news, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final content = locale == 'en'
        ? (news.contentEn.isNotEmpty ? news.contentEn : news.contentAr)
        : (news.contentAr.isNotEmpty ? news.contentAr : news.contentEn);
    return content;
  }

  // 🗓️ تنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  // 📄 فتح تفاصيل الخبر
  void _openDetails(BuildContext context, NewsModel news) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewsDetailsScreen(news: news),
      ),
    );
  }
}

// 📑 شاشة تفاصيل الخبر
class NewsDetailsScreen extends StatelessWidget {
  final NewsModel news;
  const NewsDetailsScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color fawRed = Color(0xFFD32F2F);
    //const Color fawGold = Color(0xFFFFD54F);
    //final titleColor = isDark ? fawGold : fawRed;
    final textColor = isDark ? Colors.white70 : Colors.black87;

    final locale = Localizations.localeOf(context).languageCode;
    final title = locale == 'en' && news.titleEn.isNotEmpty
        ? news.titleEn
        : (news.titleAr.isNotEmpty ? news.titleAr : news.titleEn);
    final content = locale == 'en' && news.contentEn.isNotEmpty
        ? news.contentEn
        : (news.contentAr.isNotEmpty ? news.contentAr : news.contentEn);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : fawRed,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          if (news.imagePath.isNotEmpty)
            Image.asset(news.imagePath,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 80)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              content,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}*/


import 'package:flutter/material.dart';

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأخبار')),
      body: const Center(
        child: Text('صفحة الأخبار قيد التطوير'),
      ),
    );
  }
}

