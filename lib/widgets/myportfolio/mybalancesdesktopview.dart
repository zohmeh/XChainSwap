import 'dart:math';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:web_app_template/functions/functions.dart';
import 'package:web_app_template/widgets/charts/piechart.dart';

class MyBalancesDesktopView extends StatefulWidget {
  @override
  _MyBalancesDesktopViewState createState() => _MyBalancesDesktopViewState();
}

class _MyBalancesDesktopViewState extends State<MyBalancesDesktopView> {
  Future balances;

  @override
  void initState() {
    balances = getBalances();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cardWith = MediaQuery.of(context).size.width / 1.5;
    return Container(
      height: 500,
      width: cardWith,
      child: Card(
        color: Theme.of(context).primaryColor,
        child: FutureBuilder(
          future: balances,
          builder: (ctx, balancessnapshot) {
            if (balancessnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              List mybalances = balancessnapshot.data;
              return Row(
                children: [
                  Container(
                    height: 500,
                    width: cardWith * (2 / 3),
                    child: DataTable2(
                        columns: [
                          DataColumn(
                              label: Text(
                            "Name",
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                          )),
                          DataColumn(
                              label: Text(
                            "Symbol",
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                          )),
                          DataColumn(
                              label: Text(
                            "Balance",
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                          )),
                          DataColumn(
                              label: Text(
                            "Chain",
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                          )),
                          DataColumn(
                              label: Text(
                            "Value in US Dollar",
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                          )),
                        ],
                        rows: mybalances
                            .map(
                              ((element) => DataRow(
                                    cells: [
                                      DataCell(Text(
                                        element["name"],
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .highlightColor),
                                      )),
                                      DataCell(
                                        Row(
                                          children: [
                                            Container(
                                              width: 30,
                                              child: Image.network(
                                                /*'https://cors-anywhere.herokuapp.com/${*/ element[
                                                    "image"] /*}'*/,
                                                width: 25,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              element["symbol"],
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .highlightColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(
                                        (int.parse(element["balance"]) /
                                                pow(
                                                    10,
                                                    int.parse(
                                                        element["decimals"])))
                                            .toStringAsFixed(10),
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .highlightColor),
                                      )),
                                      DataCell(Text(
                                        element["chain"],
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .highlightColor),
                                      )),
                                      DataCell(Text(
                                        (element["current_price"] *
                                                (int.parse(element["balance"]) /
                                                    pow(
                                                        10,
                                                        int.parse(element[
                                                            "decimals"]))))
                                            .toStringAsFixed(2),
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .highlightColor),
                                      )),
                                    ],
                                  )),
                            )
                            .toList()),
                  ),
                  Container(
                      height: 500,
                      width: cardWith * (1 / 3) - 8,
                      child: PieChartWidget(mybalances)),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
