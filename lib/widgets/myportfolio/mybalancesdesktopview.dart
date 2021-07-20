import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_app_template/functions/functions.dart';
import 'package:web_app_template/widgets/charts/piechart.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:web_app_template/widgets/dropdownlist/drowpdownlist.dart';
import 'package:web_app_template/widgets/inputfields/inputField.dart';
import 'package:web_app_template/widgets/myJobs/myJobs.dart';
import 'package:web_app_template/widgets/swapwidget/swapwidgetdesktopview.dart';

class MyBalancesDesktopView extends StatefulWidget {
  final List myBalances;

  MyBalancesDesktopView(this.myBalances); //, this.myNFTS);

  @override
  _MyBalancesDesktopViewState createState() => _MyBalancesDesktopViewState();
}

class _MyBalancesDesktopViewState extends State<MyBalancesDesktopView> {
  @override
  Widget build(BuildContext context) {
    return widget.myBalances != []
        ? SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 500,
                      width: MediaQuery.of(context).size.width / 2,
                      child: Card(
                        color: Theme.of(context).primaryColor,
                        child: DataTable2(
                          columns: [
                            DataColumn(
                                label: Text(
                              "Name",
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                            )),
                            DataColumn(
                                label: Text(
                              "Symbol",
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                            )),
                            DataColumn(
                                label: Text(
                              "Balance",
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                            )),
                            DataColumn(
                                label: Text(
                              "Chain",
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                            )),
                            DataColumn(
                                label: Text(
                              "Address",
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                            )),
                            //DataColumn(
                            //    label: Text(
                            //  "Value in US Dollar",
                            //  style:
                            //      TextStyle(color: Theme.of(context).accentColor),
                            //)),
                          ],
                          rows: widget.myBalances
                              .map(
                                ((element) => DataRow(
                                      cells: [
                                        DataCell(Text(
                                          element["name"],
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .highlightColor),
                                        )),
                                        DataCell(Text(
                                          element["symbol"],
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .highlightColor),
                                        )),
                                        DataCell(Text(
                                          (int.parse(element["balance"]) /
                                                  pow(
                                                      10,
                                                      int.parse(
                                                          element["decimals"])))
                                              .toStringAsFixed(5),
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
                                        DataCell(
                                            element["token_address"] != null
                                                ? Text(
                                                    element["token_address"],
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .highlightColor),
                                                  )
                                                : Text("")),
                                        //DataCell(Text(
                                        //  (element["current_price"] *
                                        //          (int.parse(element["balance"]) /
                                        //              pow(
                                        //                  10,
                                        //                  int.parse(element[
                                        //                      "decimals"]))))
                                        //      .toStringAsFixed(2),
                                        //  style: TextStyle(
                                        //      color:
                                        //          Theme.of(context).highlightColor),
                                        //)),
                                      ],
                                    )),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    //Container(
                    //  height: 500,
                    //  width: MediaQuery.of(context).size.width / 4.5,
                    //  child: Card(
                    //    color: Theme.of(context).primaryColor,
                    //    child: PieChartWidget(balances: widget.myBalances),
                    //  ),
                    //),
                    SwapWidgetDesktopview(),
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
            ),
          )
        : Container();
  }
}
