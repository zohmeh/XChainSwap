import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_app_template/provider/loginprovider.dart';
import 'package:web_app_template/widgets/swapwidget/swapwidgetdesktopview2.dart';
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
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LoginModel>(context).user;
    return user != null
        ? SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MyBalancesDesktopView(),
                    SwapWidgetDesktopview2(),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Follow your XChainSwaps on Ethereum",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        MyJobsDesktopView(chain: 0),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "Follow your XChainSwaps on Polygon",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        MyJobsDesktopView(chain: 2),
                      ],
                    ),
                  ],
                )
              ],
            ),
          )
        : Center(
            child: Text("LogIn with Metamask"),
          );
  }
}
