import 'package:flutter/material.dart';
import '../../views/allportfolios/allportfoliomobileview.dart';
import '../../views/allportfolios/allportfoliosdesktopview.dart';
import '../../responsive.dart';

class AllPortfoliosView extends StatefulWidget {
  @override
  _AllPortfoliosViewState createState() => _AllPortfoliosViewState();
}

class _AllPortfoliosViewState extends State<AllPortfoliosView> {
  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: AllPortfoliosMobileView(),
      tablet: AllPortfoliosMobileView(),
      desktop: AllPortfoliosDesktopView(),
    );
  }
}
