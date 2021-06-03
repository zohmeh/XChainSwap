import 'package:flutter/material.dart';
import 'package:web_app_template/widgets/oneinchanaytics/oneinchanalytics.dart';
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
            width: (MediaQuery.of(context).size.width - 150) / 2,
            child: SwapWidgetDesktopview()),
        Container(
          width: (MediaQuery.of(context).size.width - 150) / 2,
          child: Column(
            children: [
              Container(
                  child: Text(
                "Latest swaps on 1Inch Exchange",
                style: TextStyle(color: Theme.of(context).accentColor),
              )),
              OneInchAnalytics(),
            ],
          ),
        )
      ],
    );
  }
}
