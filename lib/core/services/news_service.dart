import 'dart:math' as math;
import 'package:al_faw_zakho/data/local/local_database.dart';
import 'package:al_faw_zakho/data/models/news_model.dart';

class NewsService {
  static List<NewsModel>? _cache;
  static DateTime? _lastAt;
  static const _ttl = Duration(minutes: 5);

  /// إبطال الكاش (نادِها بعد مزامنة خارجية إن وجدت)
  static void invalidateCache() {
    _cache = null;
    _lastAt = null;
  }

  /// أفضل مصدر للشريط: عاجل أولاً ثم الأحدث، بحد أقصى [limit]
  static Future<List<NewsModel>> getTopTickerNews({
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cache != null &&
        _lastAt != null &&
        now.difference(_lastAt!) < _ttl) {
      return _cache!.take(limit).toList();
    }

    final list = await LocalDatabase.getNews();
    if (list.isEmpty) {
      _cache = [];
      _lastAt = now;
      return [];
    }

    list.sort((a, b) {
      final breaking = (b.isBreaking ? 1 : 0).compareTo(a.isBreaking ? 1 : 0);
      return breaking != 0 ? breaking : b.publishDate.compareTo(a.publishDate);
    });

    _cache = list;
    _lastAt = now;
    return list.take(math.min(limit, list.length)).toList();
  }
}
