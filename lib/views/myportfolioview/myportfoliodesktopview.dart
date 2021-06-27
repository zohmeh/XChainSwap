import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/portfolio/portfolio.dart';
import '../../widgets/myportfolio/mybalancesdesktopview.dart';
import '../../functions/functions.dart';
import '../../widgets/sidebar/sidebardesktop.dart';

class MyPortfolioDesktopView extends StatefulWidget {
  @override
  _MyPortfolioDesktopViewState createState() => _MyPortfolioDesktopViewState();
}

class _MyPortfolioDesktopViewState extends State<MyPortfolioDesktopView> {
  Future myAssets;
  @override
  void initState() {
    myAssets = getMyAssets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        children: [
          SidebarDesktop(1),
          Container(
            width: MediaQuery.of(context).size.width - 150,
            child: FutureBuilder(
                future: myAssets,
                builder: (ctx, balancesnapshot) {
                  if (balancesnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return Container(
                      padding: EdgeInsets.all(10),
                      width:
                          (MediaQuery.of(context).size.width - 150) * (3 / 4),
                      height: MediaQuery.of(context).size.height,
                      child: MyBalancesDesktopView(balancesnapshot
                          .data[0]), //, balancesnapshot.data[1]),
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }
}
