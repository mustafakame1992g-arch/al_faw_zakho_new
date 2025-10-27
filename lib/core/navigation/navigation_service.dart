import 'package:flutter/material.dart';

abstract class INavigationService {
  void goHome(BuildContext context);
  void goOffices(BuildContext context);
  void goDonate(BuildContext context);
  void goAbout(BuildContext context);
}

class NavigationService implements INavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const homeRoute = '/';
  static const officesRoute = '/offices';
  static const donateRoute = '/donate';
  static const aboutRoute = '/about';

  bool _isCurrent(BuildContext? ctx, String route) {
    final routeName = ModalRoute.of(ctx!)?.settings.name;
    return routeName == route;
  }

  /// يدفع الوجهة بشرط ألا تكون هي الحالية، ويُبقي الهوم قاعدة الستاك
  void _goUnique(BuildContext context, String route) {
    final ctx = navigatorKey.currentContext ?? context;
    if (_isCurrent(ctx, route)) return;

    final nav = navigatorKey.currentState ?? Navigator.of(context);
    // نضمن وجود الهوم في القاع، ونزيل أي تكرارات فوقه
    nav.pushNamedAndRemoveUntil(route, (r) {
      final n = r.settings.name;
      return n == homeRoute || r.isFirst;
    });
  }

  @override
  void goHome(BuildContext context) {
    final nav = navigatorKey.currentState ?? Navigator.of(context);
    final ctx = navigatorKey.currentContext ?? context;
    if (_isCurrent(ctx, homeRoute)) return;
    // رجوع إلى جذر الستاك (الهوم الواحد)
    nav.popUntil((r) => r.isFirst);
  }

  @override
  void goOffices(BuildContext context) => _goUnique(context, officesRoute);

  @override
  void goDonate(BuildContext context) => _goUnique(context, donateRoute);

  @override
  void goAbout(BuildContext context) => _goUnique(context, aboutRoute);
}
