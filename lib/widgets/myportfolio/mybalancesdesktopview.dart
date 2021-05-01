import 'dart:math';
import 'package:flutter/material.dart';

class MyBalancesDesktopView extends StatefulWidget {
  final List myBalances;

  MyBalancesDesktopView(this.myBalances);

  @override
  _MyBalancesDesktopViewState createState() => _MyBalancesDesktopViewState();
}

class _MyBalancesDesktopViewState extends State<MyBalancesDesktopView> {
  @override
  Widget build(BuildContext context) {
    return widget.myBalances != []
        ? DataTable(
            columns: [
              DataColumn(label: Text("Name")),
              DataColumn(label: Text("Symbol")),
              DataColumn(label: Text("Balance")),
            ],
            rows: widget.myBalances
                .map(
                  ((element) => DataRow(
                        cells: [
                          DataCell(Text(element["name"])),
                          DataCell(Text(element["symbol"])),
                          DataCell(Text((int.parse(element["balance"]) /
                                  pow(10, int.parse(element["decimals"])))
                              .toString())),
                        ],
                      )),
                )
                .toList(),
          )
        : Container();
  }
}
