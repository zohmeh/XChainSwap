import 'package:flutter/material.dart';
import '../swapview/swapdesktopview.dart';
import '../swapview/swapmobileview.dart';
import '../../responsive.dart';

class SwapView extends StatefulWidget {
  @override
  _SwapViewState createState() => _SwapViewState();
}

class _SwapViewState extends State<SwapView> {
  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: SwapMobileView(),
      tablet: SwapMobileView(),
      desktop: SwapDesktopView(),
    );
  }
}
