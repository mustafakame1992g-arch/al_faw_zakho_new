import 'package:al_faw_zakho/data/repositories/faq_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_faw_zakho/data/models/faq_model.dart';
import 'package:al_faw_zakho/core/providers/language_provider.dart';
import 'package:al_faw_zakho/core/services/analytics_service.dart';
import 'dart:developer' as developer;
import 'package:al_faw_zakho/presentation/widgets/fz_scaffold.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_bottom_nav.dart';
import 'package:al_faw_zakho/core/localization/app_localizations.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<FaqModel>> _faqsFuture;
  final _expansionNotifier = ValueNotifier<int?>(null);
  final _scrollController = ScrollController();
  late AnimationController _refreshAnimationController;

  @override
  void initState() {
    super.initState();
    _refreshAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _loadFAQs();
    AnalyticsService.trackEvent('faq_screen_opened');
  }

  Future<List<FaqModel>> _loadFAQs() async {
    setState(() {
      _faqsFuture = _fetchFAQs();
    });
    return _faqsFuture;
  }

  Future<List<FaqModel>> _fetchFAQs() async {
    try {
      await Future.delayed(const Duration(milliseconds: 250));
      final repo = FAQRepositoryImpl();
      await repo.initialize(); // ✅ يفتح الصندوق مرة واحدة
      final faqs = await repo.getFAQs();
      final valid = faqs
          .where((f) =>
                  f.questionAr.trim().isNotEmpty &&
                  //f.questionEn.trim().isNotEmpty &&
                  f.answerAr.trim().isNotEmpty
              //  f.answerEn.trim().isNotEmpty
              )
          .toList();

      /* if (valid.isEmpty) {
         throw Exception('لم يتم العثور على أسئلة صالحة للعرض. تحقق من مفاتيح JSON.');
      }

      return valid;
      
    } catch (e) {
      throw Exception('فشل في تحميل الأسئلة الشائعة: ${e.toString()}');
    }
  }*/

      if (valid.isEmpty) {
        developer.log(
            '⚠️ ملف faqs.json تم تحميله لكن فارغ أو المفاتيح غير متطابقة',
            name: 'FAQ_SCREEN');
        throw Exception(
            'لم يتم العثور على أسئلة صالحة للعرض. تحقق من JSON أو المفاتيح.');
      }

      developer.log('✅ Loaded ${valid.length} FAQs into screen',
          name: 'FAQ_SCREEN');
      return valid;
    } catch (e, st) {
      developer.log('❌ Error loading FAQs: $e',
          name: 'FAQ_SCREEN', error: e, stackTrace: st);
      throw Exception('فشل في تحميل الأسئلة الشائعة: ${e.toString()}');
    }
  }

  Future<void> _refreshData() async {
    AnalyticsService.trackEvent('faq_screen_refreshed');
    _refreshAnimationController.repeat();
    await _loadFAQs();
    _refreshAnimationController.stop();
  }

  void _onExpansionChanged(int? index, BuildContext context) {
    _expansionNotifier.value = _expansionNotifier.value == index ? null : index;

    if (index != null) {
      final langProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      AnalyticsService.trackEvent('faq_expanded', parameters: {
        'index': index,
        'language': langProvider.languageCode,
      });
    }
  }

  @override
  void dispose() {
    _expansionNotifier.dispose();
    _scrollController.dispose();
    _refreshAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Provider.of<LanguageProvider>(context),
      child: FZScaffold(
        appBar: _buildAppBar(context),
        persistentBottom: FZTab.home,
        body: _buildBody(context),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    Provider.of<LanguageProvider>(context);

    return AppBar(
      title: Text(AppLocalizations.of(context).translate('faq')),
      centerTitle: true,
      actions: [
        _buildRefreshButton(),
      ],
    );
  }

  Widget _buildRefreshButton() {
    return RotationTransition(
      turns: _refreshAnimationController,
      child: IconButton(
        icon: const Icon(Icons.refresh_rounded),
        onPressed: _refreshData,
        tooltip: 'تحديث البيانات',
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: _refreshData,
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      displacement: 40,
      strokeWidth: 2.5,
      child: FutureBuilder<List<FaqModel>>(
        future: _faqsFuture,
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildContent(context, snapshot),
          );
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, AsyncSnapshot<List<FaqModel>> snapshot) {
    final connectionState = snapshot.connectionState;

    if (connectionState == ConnectionState.waiting && !snapshot.hasData) {
      return const _ShimmerLoadingView();
    }

    if (snapshot.hasError) {
      return _ErrorView(
        message: snapshot.error.toString(),
        onRetry: _loadFAQs,
      );
    }

    final faqs = snapshot.data ?? const <FaqModel>[];

    if (faqs.isEmpty) {
      return _EmptyView(
        onRefresh: _loadFAQs,
      );
    }

    return ValueListenableBuilder<int?>(
      valueListenable: _expansionNotifier,
      builder: (context, expandedIndex, _) {
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            return _FAQItem(
              faq: faqs[index],
              index: index,
              isExpanded: expandedIndex == index,
              onTap: () => _onExpansionChanged(index, context),
            );
          },
        );
      },
    );
  }
}

class _FAQItem extends StatelessWidget {
  final FaqModel faq;
  final int index;
  final bool isExpanded;
  final VoidCallback onTap;

  const _FAQItem({
    required this.faq,
    required this.index,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final isArabic = langProvider.languageCode == 'ar';

    final question = faq.getQuestion(langProvider.languageCode);
    final answer = faq.getAnswer(langProvider.languageCode);

    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            elevation: isExpanded ? 4 : 1,
            borderRadius: BorderRadius.circular(20),
            color: isExpanded
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.surface,
            shadowColor: theme.colorScheme.shadow.withValues(alpha: .1),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              splashColor: theme.colorScheme.primary.withValues(alpha: .1),
              highlightColor: theme.colorScheme.primary.withValues(alpha: .05),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.fastEaseInToSlowEaseOut,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: isArabic
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection:
                          isArabic ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isExpanded
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme
                                    .surfaceContainerHighest, // ✅ تم التصحيح
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isExpanded
                                ? Icons.help_rounded
                                : Icons.help_outline_rounded,
                            size: 20,
                            color: isExpanded
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            question,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign:
                                isArabic ? TextAlign.right : TextAlign.left,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutBack,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 24,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),

                    // Expanded Content
                    if (isExpanded) ...[
                      const SizedBox(height: 20),
                      Divider(
                        height: 1,
                        color: theme.dividerColor.withValues(alpha: .3),
                        indent: isArabic ? 0 : 56,
                        endIndent: isArabic ? 56 : 0,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection:
                            isArabic ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.lightbulb_rounded,
                              size: 20,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                answer,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.8,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: .8),
                                ),
                                textAlign:
                                    isArabic ? TextAlign.right : TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerLoadingView extends StatelessWidget {
  const _ShimmerLoadingView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    // ✅ تم إزالة highlightColor غير المستخدم

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 16,
                              decoration: BoxDecoration(
                                color: baseColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 14,
                              decoration: BoxDecoration(
                                color: baseColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 14,
                              decoration: BoxDecoration(
                                color: baseColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final isArabic = langProvider.languageCode == 'ar';

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 120,
                color: theme.colorScheme.primary.withValues(alpha: .3),
              ),
              const SizedBox(height: 32),
              Text(
                isArabic ? 'لا توجد أسئلة حالياً' : 'No questions available',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isArabic
                    ? 'سيتم إضافة الأسئلة الشائعة قريباً'
                    : 'We will add new questions soon',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: .6),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              FilledButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                    AppLocalizations.of(context).translate('refresh_content')),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final isArabic = langProvider.languageCode == 'ar';

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isArabic ? 'عذراً' : 'Sorry',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic
                    ? 'حدث خطأ أثناء تحميل البيانات'
                    : 'An error occurred while loading data',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: .6),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label:
                        Text(AppLocalizations.of(context).translate('retry')),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showHelpDialog(context),
                    icon: const Icon(Icons.help_outline_rounded),
                    label: Text(isArabic ? 'المساعدة' : 'Help'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isArabic = langProvider.languageCode == 'ar';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'المساعدة' : 'Help'),
        content: Text(isArabic
            ? 'إذا استمرت المشكلة، يرجى التأكد من اتصالك بالإنترنت أو التواصل مع الدعم الفني.'
            : 'If the problem persists, please check your internet connection or contact technical support.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).translate('ok')),
          ),
        ],
      ),
    );
  }
}
