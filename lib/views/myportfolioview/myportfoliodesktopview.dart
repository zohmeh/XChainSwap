import 'package:flutter/material.dart';
import 'package:web_app_template/widgets/portfolio/portfolio.dart';
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
  List myFollowedPortfolios = [];
  var myEthBalance;
  @override
  void initState() {
    getBalances().then((balances) {
      getMyEthBalance().then((ethblance) {
        getAllMyTransactions().then((transactions) {
          getMyFollowedPortfolios().then((followed) {
            setState(() {
              myBalances = balances;
              myEthBalance = ethblance;
              myTransactions = transactions;
              myFollowedPortfolios = followed;
            });
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
            width: (MediaQuery.of(context).size.width - 150) * (3 / 4),
            height: MediaQuery.of(context).size.height,
            child:
                MyBalancesDesktopView(myBalances, myEthBalance, myTransactions),
          ),
          SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(10),
                width: (MediaQuery.of(context).size.width - 150) * (1 / 4),
                height: MediaQuery.of(context).size.height,
                child: myFollowedPortfolios != null
                    ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            crossAxisSpacing: 1,
                            mainAxisExtent: 450),
                        itemCount: (myFollowedPortfolios.length),
                        itemBuilder: (ctx, idx) {
                          return Portfolio(
                            portfolioId: myFollowedPortfolios[idx]
                                ["portfolioId"],
                            username: myFollowedPortfolios[idx]["user"],
                            portfolio: myFollowedPortfolios[idx]["portfolio"],
                            followed: true,
                          );
                        })
                    : Text("You follow no other Portfolios")),
          ),
        ],
      ),
    );
  }
}
