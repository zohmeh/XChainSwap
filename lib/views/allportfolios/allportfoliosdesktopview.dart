import 'package:flutter/material.dart';
import 'package:web_app_template/functions/functions.dart';
import 'package:web_app_template/widgets/portfolio/portfolio.dart';
import '../../widgets/sidebar/sidebardesktop.dart';

class AllPortfoliosDesktopView extends StatefulWidget {
  @override
  _AllPortfoliosDesktopViewState createState() =>
      _AllPortfoliosDesktopViewState();
}

class _AllPortfoliosDesktopViewState extends State<AllPortfoliosDesktopView> {
  List allPortfolios;
  void initState() {
    getAllDeployedPortfolios().then((portfolios) {
      setState(() {
        allPortfolios = portfolios;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return allPortfolios != null
        ? SingleChildScrollView(
            child: Row(
              children: [
                SidebarDesktop(0),
                Container(
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width - 150,
                  height: MediaQuery.of(context).size.height,
                  child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          crossAxisSpacing: 50,
                          mainAxisSpacing: 50,
                          mainAxisExtent: 530,
                          maxCrossAxisExtent: 500),
                      itemCount: allPortfolios.length,
                      itemBuilder: (ctx, idx) {
                        return Portfolio(
                          portfolioId: allPortfolios[idx]["portfolioId"],
                          username: allPortfolios[idx]["user"],
                          portfolio: allPortfolios[idx]["portfolio"],
                          followed: false,
                        );
                      }),
                ),
              ],
            ),
          )
        : Container();
  }
}
