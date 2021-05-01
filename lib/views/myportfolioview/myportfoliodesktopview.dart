import 'package:flutter/material.dart';
import '../../widgets/myportfolio/mybalancesdesktopview.dart';
import '../../functions/functions.dart';
import '../../widgets/sidebar/sidebardesktop.dart';

class MyPortfolioDesktopView extends StatefulWidget {
  @override
  _MyPortfolioDesktopViewState createState() => _MyPortfolioDesktopViewState();
}

class _MyPortfolioDesktopViewState extends State<MyPortfolioDesktopView> {
  List myBalances = [];
  List myTransactions = [];
  var myEthBalance;
  @override
  void initState() {
    getBalances().then((balances) {
      getMyEthBalance().then((ethblance) {
        getAllMyTransactions().then((transactions) {
          setState(() {
            myBalances = balances;
            myEthBalance = ethblance;
            myTransactions = transactions;
          });
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        children: [
          SidebarDesktop(1),
          Container(
            padding: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width - 150,
            height: MediaQuery.of(context).size.height,
            child:
                MyBalancesDesktopView(myBalances, myEthBalance, myTransactions),
          ),
        ],
      ),
    );
  }
}
