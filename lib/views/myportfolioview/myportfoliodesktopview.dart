import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../functions/functions.dart';
import '../../provider/loginprovider.dart';
import '../../widgets/swapwidget/swapwidgetdesktopview2.dart';
import '../../widgets/myportfolio/mybalancesdesktopview.dart';

var initialUser;

class MyPortfolioDesktopView extends StatefulWidget {
  @override
  _MyPortfolioDesktopViewState createState() => _MyPortfolioDesktopViewState();
}

class _MyPortfolioDesktopViewState extends State<MyPortfolioDesktopView> {
  @override
  void initState() {
    super.initState();
    checkforloggedIn().then((value) {
      setState(() {
        initialUser = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<LoginModel>(context).user;
    return initialUser != null
        ? Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyBalancesDesktopView(),
                SwapWidgetDesktopview2(),
              ],
            ),
          )
        : Center(
            child: Text("LogIn with Metamask"),
          );
  }
}
