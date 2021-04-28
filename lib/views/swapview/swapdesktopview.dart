import 'package:flutter/material.dart';
import '../../widgets/swapwidget/swapwidgetdesktopview.dart';
import '../../widgets/sidebar/sidebardesktop.dart';

class SwapDesktopView extends StatefulWidget {
  @override
  _SwapDesktopViewState createState() => _SwapDesktopViewState();
}

class _SwapDesktopViewState extends State<SwapDesktopView> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SidebarDesktop(2),
        Container(
          padding: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width - 150,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: SwapWidgetDesktopview(),
          ),
        ),
      ],
    );
  }
}
