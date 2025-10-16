import 'dart:convert';
import 'package:al_faw_zakho/presentation/widgets/fz_bottom_nav.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:al_faw_zakho/core/providers/language_provider.dart';
import 'package:al_faw_zakho/presentation/themes/app_theme.dart';

class VisionScreen extends StatefulWidget {
  const VisionScreen({super.key});

  @override
  State<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends State<VisionScreen> {
  Map<String, dynamic>? _visionData;
  bool _isLoading = true;
  String? _error;
  bool _isReadingMode = true;

  // 🔑 قائمة مفاتيح لكل الأقسام
  List<GlobalKey> _sectionKeys = [];

  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadVisionContent();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadVisionContent() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/vision.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _visionData = jsonData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'فشل تحميل محتوى الرؤية: $e';
        _isLoading = false;
      });
    }
  }

  // 🎯 التمرير إلى قسم معين
  void _scrollToSection(int index) {
    if (_isReadingMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (index < _sectionKeys.length &&
            _sectionKeys[index].currentContext != null) {
          Scrollable.ensureVisible(
            _sectionKeys[index].currentContext!,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      });
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleViewMode() {
    setState(() {
      _isReadingMode = !_isReadingMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final langCode = languageProvider.languageCode;

    if (_isLoading) return _buildShimmerLoading(brightness);
    if (_error != null) return _buildErrorScreen(brightness);

    final content = _visionData?[langCode] ?? _visionData?['ar'];
    final sections = content['sections'] as List<dynamic>? ?? [];

    // 🏗️ إنشاء المفاتيح إذا لزم الأمر
    if (_sectionKeys.length != sections.length) {
      _sectionKeys = List.generate(sections.length, (index) => GlobalKey());
    }

    /* return Scaffold(
      appBar: _buildAppBar(content['title'] ?? 'الرؤية', brightness, sections),
      body: _isReadingMode? _buildReadingMode(content, sections, brightness)
          : _buildPresentationMode(content, sections, brightness),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }*/

    return FZScaffold(
      appBar: _buildAppBar(content['title'] ?? 'الرؤية', brightness, sections),
      body: _isReadingMode
          ? _buildReadingMode(content, sections, brightness)
          : _buildPresentationMode(content, sections, brightness),
      persistentBottom: FZTab.home,
    );
  }

  AppBar _buildAppBar(
      String title, Brightness brightness, List<dynamic> sections) {
    return AppBar(
      title: Text(title),
      flexibleSpace: Container(
        decoration:
            BoxDecoration(gradient: AppTheme.headerGradient(brightness)),
      ),
      actions: [
        if (!_isLoading && _error == null) ...[
          IconButton(
            icon: Icon(_isReadingMode ? Icons.slideshow : Icons.article),
            onPressed: _toggleViewMode,
            tooltip: _isReadingMode ? 'وضع العرض' : 'وضع القراءة',
          ),
          if (sections.length > 5)
            PopupMenuButton<int>(
              icon: const Icon(Icons.list),
              onSelected: _scrollToSection,
              itemBuilder: (context) => sections.asMap().entries.map((entry) {
                return PopupMenuItem<int>(
                  value: entry.key,
                  child: Text(
                    entry.value['heading'] ?? 'قسم ${entry.key + 1}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }).toList(),
            ),
        ],
      ],
    );
  }

  Widget _buildReadingMode(Map<String, dynamic> content, List<dynamic> sections,
      Brightness brightness) {
    return Column(
      children: [
        _buildEnhancedHeader(brightness, content['title'] ?? ''),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (int i = 0; i < sections.length; i++)
                  _buildAnimatedSectionCard(sections[i], context, i),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresentationMode(Map<String, dynamic> content,
      List<dynamic> sections, Brightness brightness) {
    return Column(
      children: [
        _buildPresentationHeader(brightness, content['title'] ?? ''),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: sections.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return _buildVisionPageWithAnimation(
                  sections[index], brightness, index);
            },
          ),
        ),
        _buildPageIndicator(sections.length),
      ],
    );
  }

  Widget _buildEnhancedHeader(Brightness brightness, String title) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: brightness == Brightness.dark
              ? [AppTheme.green, AppTheme.grey900]
              : [AppTheme.red, Colors.white, AppTheme.green],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.only(top: 32, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            child: Image.asset(
              'assets/images/logo.png',
              width: 85,
              height: 85,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 600),
            opacity: 1.0,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: brightness == Brightness.dark
                        ? Colors.white
                        : AppTheme.black,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 800),
            opacity: 1.0,
            child: Text(
              'من الفاو إلى زاخو... وحدة وطنية ورؤية تنموية 🇮🇶',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresentationHeader(Brightness brightness, String title) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: brightness == Brightness.dark
              ? [AppTheme.green, AppTheme.grey900]
              : [AppTheme.red, Colors.white, AppTheme.green],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/logo.png', width: 70, height: 70),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🃏 بناء كرت القسم مع المفتاح الصحيح
  Widget _buildAnimatedSectionCard(
      Map<String, dynamic> section, BuildContext context, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 16, top: index == 0 ? 8 : 0),
      child: Card(
        key: _sectionKeys[index], // 🔑 المفتاح الصحيح هنا
        elevation: 4,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: .05),
                  Theme.of(context).colorScheme.primary.withValues(alpha: .02),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (section['heading'] != null)
                    _AnimatedSectionTitle(section['heading'], index),
                  const SizedBox(height: 12),
                  if (section['text'] != null)
                    _AnimatedSectionText(section['text'], index),
                  if (section['bullets'] != null) ...[
                    const SizedBox(height: 16),
                    for (final point in section['bullets'])
                      _AnimatedSectionBullet(
                          point.toString(), section['bullets'].indexOf(point)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisionPageWithAnimation(
      Map<String, dynamic> section, Brightness brightness, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
        }

        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.tileGradient(brightness),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .15),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section['heading'] ?? '',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    const SizedBox(height: 16),
                    if (section['text'] != null)
                      Text(
                        section['text'],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.7,
                              fontSize: 16,
                            ),
                        textAlign: TextAlign.justify,
                      ),
                    if (section['bullets'] != null) ...[
                      const SizedBox(height: 20),
                      for (final point in section['bullets'])
                        _SectionBullet(point.toString()),
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

  Widget _buildPageIndicator(int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.withValues(alpha: .4),
              borderRadius: BorderRadius.circular(6),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildShimmerLoading(Brightness brightness) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رؤية التجمع'),
        flexibleSpace: Container(
          decoration:
              BoxDecoration(gradient: AppTheme.headerGradient(brightness)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildShimmerHeader(),
            const SizedBox(height: 20),
            for (int i = 0; i < 4; i++) _buildShimmerCard(i),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: [Colors.grey[300]!, Colors.grey[100]!]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration:
                BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle),
          ),
          const SizedBox(height: 16),
          Container(width: 200, height: 20, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Container(width: 250, height: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 150, height: 18, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Container(
              width: double.infinity, height: 14, color: Colors.grey[300]),
          const SizedBox(height: 6),
          Container(
              width: double.infinity, height: 14, color: Colors.grey[300]),
          const SizedBox(height: 6),
          Container(width: 200, height: 14, color: Colors.grey[300]),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(Brightness brightness) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رؤية التجمع'),
        flexibleSpace: Container(
          decoration:
              BoxDecoration(gradient: AppTheme.headerGradient(brightness)),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadVisionContent,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _toggleViewMode,
      tooltip:
          _isReadingMode ? 'التبديل إلى وضع العرض' : 'التبديل إلى وضع القراءة',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _isReadingMode
            ? const Icon(Icons.slideshow, key: ValueKey('slideshow'))
            : const Icon(Icons.article, key: ValueKey('article')),
      ),
    );
  }
}

// 🎨 المكونات الفرعية المصححة
class _AnimatedSectionTitle extends StatelessWidget {
  final String text;
  final int index;
  const _AnimatedSectionTitle(this.text, this.index);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 500 + (index * 100)),
      opacity: 1.0,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _AnimatedSectionText extends StatelessWidget {
  final String text;
  final int index;
  const _AnimatedSectionText(this.text, this.index);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 600 + (index * 100)),
      opacity: 1.0,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.7,
              fontSize: 15,
            ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}

class _AnimatedSectionBullet extends StatelessWidget {
  final String text;
  final int bulletIndex;
  const _AnimatedSectionBullet(this.text, this.bulletIndex);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 400 + (bulletIndex * 150)),
      opacity: 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300 + (bulletIndex * 100)),
              curve: Curves.elasticOut,
              child: const Text('• ',
                  style: TextStyle(fontSize: 22, color: AppTheme.red)),
            ),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      fontSize: 14,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionBullet extends StatelessWidget {
  final String text;
  const _SectionBullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 20, color: AppTheme.red)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    fontSize: 15,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
