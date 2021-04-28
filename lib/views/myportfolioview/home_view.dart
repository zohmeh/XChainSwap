import 'package:flutter/material.dart';
import '../../views/myportfolioview/myportfoliomobileview.dart';
import '../../views/myportfolioview/myportfoliodesktopview.dart';
import '../../responsive.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: MyPortfolioMobileView(),
      tablet: MyPortfolioMobileView(),
      desktop: MyPortfolioDesktopView(),
    );
  }
}
