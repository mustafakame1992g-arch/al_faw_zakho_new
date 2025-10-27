import 'dart:async';
import 'package:al_faw_zakho/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:al_faw_zakho/core/services/news_service.dart';
import '/data/models/news_model.dart';
// إذا عندك l10n مفعّل:
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewsTicker extends StatefulWidget {
  const NewsTicker({super.key});

  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker> with WidgetsBindingObserver {
  // يمرّن الحركة، ويحترم إعدادات الوصول
  final Duration _interval = const Duration(seconds: 4);
  final Duration _anim = const Duration(milliseconds: 280);

  List<NewsModel> _items = [];
  int _index = 0;
  Timer? _timer;
  bool _paused = false;
  bool _reducedMotion = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAccessibilityFeatures();
    _load();
  }

  @override
  void didChangeAccessibilityFeatures() {
    _checkAccessibilityFeatures();
    super.didChangeAccessibilityFeatures();
  }

  void _checkAccessibilityFeatures() {
    final features =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures;
    setState(() => _reducedMotion = features.disableAnimations);
    _handleTimerControl();
  }

  // ====== Localization helpers (تشتغل حتى لو ما فعّلت AppLocalizations) ======
  String _lang(BuildContext context) =>
      Localizations.localeOf(context).languageCode;

  bool _isRTL(BuildContext context) {
    final code = _lang(context);
    // لو عندك لغات أخرى RTL أضفها هنا
    return code.startsWith('ar') ||
        code.startsWith('fa') ||
        code.startsWith('ur');
  }

  String _tBreaking(BuildContext context) {
    final t = AppLocalizations.of(context);
    return t.translate('breaking');
  }

  String _tLoading(BuildContext context) {
    final t = AppLocalizations.of(context);

    return t.translate('loading_news');
  }

  String _tPrev(BuildContext context) {
    final t = AppLocalizations.of(context);
    return t.translate('previous_news');
  }

  String _tNext(BuildContext context) {
    final t = AppLocalizations.of(context);
    return t.translate('next_news');
  }

  String _tGenericNews(BuildContext context) {
    final t = AppLocalizations.of(context);
    return t.translate('news');
  }

  String _tTickerSemantics(BuildContext context, int count) {
    final t = AppLocalizations.of(context);
    // مثال بسيط للتجميع: "News ticker, {count} items"
    final base = t.translate('news_ticker');
    final unit = t.translate('items'); // أو news_items بالعربي
    return '$base, $count $unit';
  }

  // ===========================================================================

  Future<void> _load() async {
    try {
      setState(() => _isLoading = true);
      final items = await NewsService.getTopTickerNews(limit: 10);
      debugPrint('[TICKER] loaded ${items.length} items');

      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
        if (_items.isNotEmpty && _index >= _items.length) _index = 0;
      });
      _handleTimerControl();
    } catch (e) {
      debugPrint('[TICKER] Error loading news: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleTimerControl() {
    _timer?.cancel();
    if (!_reducedMotion && !_paused && _items.isNotEmpty) {
      _start();
    }
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) {
      if (!mounted || _paused || _items.isEmpty) return;
      setState(() => _index = (_index + 1) % _items.length);
    });
  }

  void _pause() {
    if (!_paused) {
      setState(() => _paused = true);
      _handleTimerControl();
    }
  }

  void _resume() {
    if (_paused) {
      setState(() => _paused = false);
      _handleTimerControl();
    }
  }

  void _goToNext() {
    if (_items.isEmpty) return;
    setState(() => _index = (_index + 1) % _items.length);
    _restartTimer();
  }

  void _goToPrevious() {
    if (_items.isEmpty) return;
    setState(() => _index = (_index - 1 + _items.length) % _items.length);
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (!_reducedMotion && !_paused && _items.isNotEmpty) _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  // ================================= UI =================================

  Widget _buildLoadingIndicator(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: Theme.of(context).brightness == Brightness.dark
              ? [const Color(0xFF1E1E1E), const Color(0xFF242424)]
              : [const Color(0xFFFDECEC), const Color(0xFFFFF6E1)],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.newspaper, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _tLoading(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1C1C1C),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const CircularProgressIndicator(strokeWidth: 2),
        ],
      ),
    );
  }

  Widget _buildNewsItem({
    required BuildContext context,
    required NewsModel current,
    required String displayTitle,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rtl = _isRTL(context);
    final breakingText = _tBreaking(context);

    final textWidget = Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Text(
        displayTitle,
        key: ValueKey('news-$_index'),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: cs.onPrimaryContainer,
          height: 1.2,
        ),
      ),
    );

    final animatedContent = _reducedMotion
        ? textWidget
        : AnimatedSwitcher(
            duration: _anim,
            transitionBuilder: (child, anim) {
              final offset = Tween<Offset>(
                begin: const Offset(0.0, 0.35),
                end: Offset.zero,
              ).animate(anim);
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(position: offset, child: child),
              );
            },
            child: textWidget,
          );

    // أيقونات الأسهم تنقلب حسب الاتجاه
    final prevIcon = rtl ? Icons.chevron_right : Icons.chevron_left;
    final nextIcon = rtl ? Icons.chevron_left : Icons.chevron_right;

    return Container(
      height: 48,
      padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
            offset: const Offset(0, 1),
            blurRadius: 4,
          )
        ],
      ),
      child: Row(
        children: [
          // شارة العاجل
          current.isBreaking
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFFB71C1C)
                        : const Color(0xFFD32F2F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    breakingText,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : const Icon(Icons.newspaper, size: 20, color: Colors.redAccent),

          const SizedBox(width: 8),

          // النص + السحب
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                final v = details.primaryVelocity;
                if (v == null) return;
                // نعكس المنطق حسب الاتجاه
                if (rtl) {
                  if (v > 0) {
                    _goToNext(); // سحب يمين في RTL يذهب للأمام بصريًا
                  } else if (v < 0) {
                    _goToPrevious();
                  }
                } else {
                  if (v > 0) {
                    _goToPrevious();
                  } else if (v < 0) {
                    _goToNext();
                  }
                }
              },
              child: animatedContent,
            ),
          ),

          const SizedBox(width: 8),

          // أدوات التحكّم + العداد
          Row(
            children: [
              if (_items.length > 1)
                IconButton(
                  icon: Icon(prevIcon, size: 20),
                  onPressed: _goToPrevious,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  tooltip: _tPrev(context),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF333333)
                      : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF444444)
                        : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Text(
                  '${_index + 1}/${_items.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF333333),
                  ),
                ),
              ),
              if (_items.length > 1)
                IconButton(
                  icon: Icon(nextIcon, size: 20),
                  onPressed: _goToNext,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  tooltip: _tNext(context),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingIndicator(context);
    if (_items.isEmpty) return const SizedBox.shrink();

    final safeIndex = (_index >= 0 && _index < _items.length) ? _index : 0;
    final current = _items[safeIndex];

    final locale = _lang(context);

    // عنوان العرض الذكي (من الـ model)
    String title = current.bestTitleForLocale(locale).trim();
    // fallback: لو العنوان فاضي، قص جزءًا من المحتوى
    if (title.isEmpty) {
      final content = current.bestContentForLocale(locale).trim();
      title = content.isEmpty
          ? _tGenericNews(context)
          : (content.length <= 60 ? content : content.substring(0, 60));
    }

    return Semantics(
      // شاشة قارئ الشاشة
      label: _tTickerSemantics(context, _items.length),
      liveRegion: true,
      container: true,
      child: MouseRegion(
        onEnter: (_) => _pause(),
        onExit: (_) => _resume(),
        child: GestureDetector(
          onTapDown: (_) => _pause(),
          onTapUp: (_) => _resume(),
          onTapCancel: _resume,
          onDoubleTap: _goToNext,
          child: _buildNewsItem(
            context: context,
            current: current,
            displayTitle: title,
          ),
        ),
      ),
    );
  }
}
