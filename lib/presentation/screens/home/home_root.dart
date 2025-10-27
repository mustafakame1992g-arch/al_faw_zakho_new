import 'package:al_faw_zakho/presentation/screens/faq/faq_screen.dart';
// شاشة الصفحة الرئيسية الفعلية + بقية الشاشات الداخلية
import 'package:al_faw_zakho/presentation/screens/home/home_screen.dart';
import 'package:al_faw_zakho/presentation/screens/news/news_list_screen.dart';
import 'package:al_faw_zakho/presentation/screens/offices/offices_main_screen.dart';
import 'package:al_faw_zakho/presentation/screens/provinces/provinces_screen.dart';
import 'package:al_faw_zakho/presentation/screens/vision/vision_screen.dart';
import 'package:flutter/material.dart';

class HomeRoot extends StatelessWidget {
  const HomeRoot({super.key});

  static const String routeHome = '/';
  static const String routeProvinces = '/provinces';
  static const String routeNews = '/news';
  static const String routeOffices = '/offices';
  static const String routeProgram = '/program';
  static const String routeFAQ = '/faq';

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case routeHome:
            page = const HomeScreen();
            break;
          case routeProvinces:
            page = const ProvincesScreen();
            break;
          case routeNews:
            page = const NewsListScreen();
            break;
          case routeOffices:
            page = const OfficesScreen();
            break;
          case routeProgram:
            page = const VisionScreen();
            break;
          case routeFAQ:
            page = const FAQScreen();
            break;
          default:
            page = const HomeScreen();
        }

        return MaterialPageRoute(builder: (_) => page, settings: settings);
      },
    );
  }
}
