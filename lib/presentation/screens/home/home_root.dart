import 'package:flutter/material.dart';

// شاشة الصفحة الرئيسية الفعلية + بقية الشاشات الداخلية
import 'home_screen.dart';
import '../provinces/provinces_screen.dart';
import '../news/news_list_screen.dart';
import '../offices/offices_main_screen.dart';
import '../vision/vision_screen.dart';
import '../faq/faq_screen.dart';

class HomeRoot extends StatelessWidget {
  const HomeRoot({super.key});

  static const String routeHome      = '/';
  static const String routeProvinces = '/provinces';
  static const String routeNews      = '/news';
  static const String routeOffices   = '/offices';
  static const String routeProgram   = '/program';
  static const String routeFAQ       = '/faq';

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case routeHome:      page = const HomeScreen(); break;
          case routeProvinces: page = const ProvincesScreen(); break;
          case routeNews:      page = const NewsListScreen(); break;
          case routeOffices:   page = const OfficesScreen(); break;
          case routeProgram:   page = const VisionScreen(); break;
          case routeFAQ:       page = const FAQScreen(); break;
          default:             page = const HomeScreen();
        }

        return MaterialPageRoute(builder: (_) => page, settings: settings);
      },
    );
  }
}
