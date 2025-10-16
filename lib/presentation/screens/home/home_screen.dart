import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_bottom_nav.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_scaffold.dart';
// 🧩 مزوّدو الحالة (Providers)
import 'package:al_faw_zakho/core/providers/app_provider.dart';
import 'package:al_faw_zakho/core/providers/connectivity_provider.dart';
import 'package:al_faw_zakho/core/services/analytics_service.dart';
import 'package:al_faw_zakho/data/local/local_database.dart';

// 🎨 الثيم العام

// 🏛️ الشاشات الأخرى
import 'package:al_faw_zakho/presentation/screens/provinces/provinces_screen.dart';
import 'package:al_faw_zakho/presentation/screens/offices/offices_main_screen.dart';
import 'package:al_faw_zakho/presentation/screens/faq/faq_screen.dart';
//import 'package:al_faw_zakho/presentation/screens/news/news_list_screen.dart';
import 'package:al_faw_zakho/presentation/screens/settings/settings_screen.dart';
import '/presentation/screens/vision/vision_screen.dart';

// 🧱 مكونات واجهة الهوم
import 'package:al_faw_zakho/presentation/screens/home/widgets/home_appbar.dart';
import 'package:al_faw_zakho/presentation/screens/home/widgets/loading_widget.dart';
import 'package:al_faw_zakho/presentation/screens/home/widgets/connection_indicator.dart';
import 'package:al_faw_zakho/presentation/screens/home/widgets/news_ticker.dart';
import 'package:al_faw_zakho/presentation/screens/home/widgets/welcome_banner.dart';
import 'package:al_faw_zakho/presentation/screens/home/widgets/home_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isPreloadingData = false;
  double _preloadProgress = 0.0;
  late AppProvider _appProvider;

  @override
  void initState() {
    super.initState();
    _appProvider = Provider.of<AppProvider>(context, listen: false);
    _preloadData();
  }

  // ============================================================
  // 🧩 تحميل البيانات مسبقًا (Offline First)
  // ============================================================
  Future<void> _preloadData() async {
    if (_isPreloadingData) return;
    setState(() => _isPreloadingData = true);

    try {
      await _executeParallelPreloading();
    } catch (e) {
      developer.log('Preloading error: $e', name: 'ERROR');
    } finally {
      if (mounted) {
        setState(() {
          _isPreloadingData = false;
          _preloadProgress = 1.0;
        });
      }
    }
  }


  Future<void> _executeParallelPreloading() async {
    const totalSteps = 4;
    int completed = 0;

    final tasks = [
      _preloadCandidates().then((_) => _updateProgress(++completed, totalSteps)),
      _preloadOffices().then((_) => _updateProgress(++completed, totalSteps)),
      _preloadFAQs().then((_) => _updateProgress(++completed, totalSteps)),
      _preloadNews().then((_) => _updateProgress(++completed, totalSteps)),
    ];

    await Future.wait(tasks.map((t) => t.catchError((e) {
          developer.log('Preload task error: $e', name: 'WARNING');
          return null;
        })));
  }

  void _updateProgress(int current, int total) {
    if (!mounted) return;
    setState(() => _preloadProgress = current / total);
  }

  Future<void> _preloadCandidates() async {
    try {
      final candidates = LocalDatabase.getCandidates();
      if (candidates.isEmpty) await _appProvider.generateMockData();
    } catch (e) {
      developer.log('Candidate preload failed: $e', name: 'ERROR');
    }
  }

  Future<void> _preloadOffices() async {
    try {
      final offices = LocalDatabase.getOffices();
      if (offices.isEmpty) {
        developer.log('Generating mock offices...', name: 'DATA');
      }
    } catch (e) {
      developer.log('Offices preload failed: $e', name: 'ERROR');
    }
  }

  Future<void> _preloadFAQs() async {
    try {
      final faqs = LocalDatabase.getFAQs();
      if (faqs.isEmpty) {
        developer.log('Generating mock FAQs...', name: 'DATA');
      }
    } catch (e) {
      developer.log('FAQs preload failed: $e', name: 'ERROR');
    }
  }

  Future<void> _preloadNews() async {
    try {
      final news = await LocalDatabase.getNews();
      if (news.isEmpty) {
        developer.log('Generating mock news...', name: 'DATA');
      }
    } catch (e) {
      developer.log('News preload failed: $e', name: 'ERROR');
    }
  }

  // ============================================================
  // 🎨 واجهة المستخدم
  // ============================================================
@override
Widget build(BuildContext context) {
  if (_isPreloadingData) {
    return LoadingWidget(progress: _preloadProgress);
  }

return FZScaffold(
  persistentBottom: FZTab.home,
    appBar: HomeAppBar(
      onSettingsTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      ),
    ),
    body: Consumer<ConnectivityProvider>(
      builder: (context, connectivity, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ الشريط العلوي ثابت ولا يتحرك مع التمرير
            const NewsTicker(),
            const SizedBox(height: 10),

            // بقية الصفحة قابلة للتمرير كالمعتاد
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!connectivity.isOnline) const ConnectionIndicator(),
                    const WelcomeBanner(),
                    const SizedBox(height: 10),
                    HomeGrid(onTap: (id) => _handleCategoryTap(id, context)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
    /*bottomNavigationBar: NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (i) {
        switch (i) {
          case 1:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProvincesScreen()));
            break;
          case 2:
            Navigator.push(context, MaterialPageRoute(builder: (_) => AboutScreen()));
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        NavigationDestination(
          icon: Icon(Icons.how_to_vote_outlined),
          selectedIcon: Icon(Icons.how_to_vote),
          label: 'المحافظات',
        ),
        NavigationDestination(
          icon: Icon(Icons.info_outline),
          selectedIcon: Icon(Icons.info_outline),
          label: 'حولة',
        ),
      ],
    ),*/
  );
}


  // ============================================================
  // 🔁 التعامل مع الضغط على الأقسام
  // ============================================================
  void _handleCategoryTap(String category, BuildContext context) {
    AnalyticsService.trackEvent('home_category_tapped', parameters: {'category': category});

    switch (category) {
      case 'candidates':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProvincesScreen()));
        break;
      case 'offices':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const OfficesScreen()));
        break;
      case 'program':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const VisionScreen()));
        break;
      case 'faq':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FAQScreen()));
        break;
      /*case 'news':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsListScreen()));
        break;*/
      /*case 'settings':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        break;*/
      /*case 'about':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
        break;*/
    }
  }
}
