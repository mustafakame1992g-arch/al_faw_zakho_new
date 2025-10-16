import 'package:flutter/material.dart';

abstract class INavigationService {
  void goHome(BuildContext context);
  void goOffices(BuildContext context);
  void goDonate(BuildContext context);
  void goAbout(BuildContext context);
}

class NavigationService implements INavigationService {
  static const homeRoute = '/';
  static const officesRoute = '/offices';
  static const donateRoute = '/donate';
  static const aboutRoute = '/about';

  @override
  void goHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(homeRoute, (r) => false);
  }

  @override
  void goOffices(BuildContext context) {
    Navigator.of(context).pushNamed(officesRoute);
  }

  @override
  void goDonate(BuildContext context) {
    Navigator.of(context).pushNamed(donateRoute);
  }

  @override
  void goAbout(BuildContext context) {
    Navigator.of(context).pushNamed(aboutRoute);
  }
}
