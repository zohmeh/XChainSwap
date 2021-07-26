import 'package:flutter/material.dart';
import '../../widgets/charts/piechart.dart';
import '../../widgets/myJobs/myJobs.dart';
import '../../widgets/swapwidget/swapwidgetdesktopview.dart';
import '../../widgets/myportfolio/mybalancesdesktopview.dart';
import '../../functions/functions.dart';

class MyPortfolioDesktopView extends StatefulWidget {
  @override
  _MyPortfolioDesktopViewState createState() => _MyPortfolioDesktopViewState();
}

class _MyPortfolioDesktopViewState extends State<MyPortfolioDesktopView> {
  var startData;
  @override
  void initState() {
    getAllMyJobs();
    startData = loadAtStart();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder(
          future: startData,
          builder: (ctx, startsnapshot) {
            if (startsnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MyBalancesDesktopView(startsnapshot.data[0]),
                      Container(
                        height: 500,
                        width: MediaQuery.of(context).size.width / 4.5,
                        child: Card(
                          color: Theme.of(context).primaryColor,
                          child: PieChartWidget(startsnapshot.data[0]),
                        ),
                      ),
                      SwapWidgetDesktopview(startsnapshot.data[1]),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            "Follow Transactions on Ethereum",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          MyJobsDesktopView(chain: 0),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "Follow Transactions on Polygon",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          MyJobsDesktopView(chain: 2),
                        ],
                      ),
                    ],
                  )
                ],
              );
            }
          }),
    );
  }
}

//  child: Container(
//    width: MediaQuery.of(context).size.width - 150,
//    child: FutureBuilder(
//        future: myAssets,
//        builder: (ctx, balancesnapshot) {
//          if (balancesnapshot.connectionState == ConnectionState.waiting) {
//            return Center(child: CircularProgressIndicator());
//          } else {
//            return Container(
//              padding: EdgeInsets.all(10),
//              width: MediaQuery.of(context).size.width,
//              height: MediaQuery.of(context).size.height,
//              child: MyBalancesDesktopView(
//                  balancesnapshot.data[0]), //, balancesnapshot.data[1]),
//            );
//          }
//        }),
//  ),
//);
//}
//}
