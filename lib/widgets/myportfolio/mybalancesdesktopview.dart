import 'dart:math';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:web_app_template/functions/functions.dart';

class MyBalancesDesktopView extends StatefulWidget {
  final myBalances;

  MyBalancesDesktopView(this.myBalances);

  @override
  _MyBalancesDesktopViewState createState() => _MyBalancesDesktopViewState();
}

class _MyBalancesDesktopViewState extends State<MyBalancesDesktopView> {
  @override
  Widget build(BuildContext context) {
    List balances = widget.myBalances;
    return Container(
      height: 500,
      width: MediaQuery.of(context).size.width / 3 + 190,
      child: Card(
        color: Theme.of(context).primaryColor,
        child: DataTable2(
          columns: [
            DataColumn(
                label: Text(
              "Name",
              style: TextStyle(color: Theme.of(context).accentColor),
            )),
            DataColumn(
                label: Text(
              "Symbol",
              style: TextStyle(color: Theme.of(context).accentColor),
            )),
            DataColumn(
                label: Text(
              "Balance",
              style: TextStyle(color: Theme.of(context).accentColor),
            )),
            DataColumn(
                label: Text(
              "Chain",
              style: TextStyle(color: Theme.of(context).accentColor),
            )),
            DataColumn(
                label: Text(
              "Value in US Dollar",
              style: TextStyle(color: Theme.of(context).accentColor),
            )),
          ],
          rows: balances
              .map(
                ((element) => DataRow(
                      cells: [
                        DataCell(Text(
                          element["name"],
                          style: TextStyle(
                              color: Theme.of(context).highlightColor),
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
                                    color: Theme.of(context).highlightColor),
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text(
                          (int.parse(element["balance"]) /
                                  pow(10, int.parse(element["decimals"])))
                              .toStringAsFixed(10),
                          style: TextStyle(
                              color: Theme.of(context).highlightColor),
                        )),
                        DataCell(Text(
                          element["chain"],
                          style: TextStyle(
                              color: Theme.of(context).highlightColor),
                        )),
                        DataCell(Text(
                          (element["current_price"] *
                                  (int.parse(element["balance"]) /
                                      pow(10, int.parse(element["decimals"]))))
                              .toStringAsFixed(2),
                          style: TextStyle(
                              color: Theme.of(context).highlightColor),
                        )),
                      ],
                    )),
              )
              .toList(),
        ),
      ),
    );
  }
}
