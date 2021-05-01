import 'dart:math';
import 'package:flutter/material.dart';

class MyBalancesDesktopView extends StatefulWidget {
  final List myBalances;
  final List myTransactions;
  final myEthBalance;

  MyBalancesDesktopView(
      this.myBalances, this.myEthBalance, this.myTransactions);

  @override
  _MyBalancesDesktopViewState createState() => _MyBalancesDesktopViewState();
}

class _MyBalancesDesktopViewState extends State<MyBalancesDesktopView> {
  @override
  Widget build(BuildContext context) {
    return widget.myBalances != [] && widget.myEthBalance != null
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "My Eth Balance: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text((int.parse(widget.myEthBalance) / 1000000000000000000)
                        .toString())
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  "My ERC20 Tokenbalance: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DataTable(
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
                ),
                SizedBox(height: 20),
                Text(
                  "My latest Transactions: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DataTable(
                  columns: [
                    DataColumn(label: Text("Tx Hash")),
                    DataColumn(label: Text("To Address")),
                    DataColumn(label: Text("Value")),
                  ],
                  rows: widget.myTransactions
                      .map(
                        ((element) => DataRow(
                              cells: [
                                DataCell(Text(element["hash"])),
                                DataCell(Text(element["to_address"])),
                                DataCell(Text(element["value"])),
                              ],
                            )),
                      )
                      .toList(),
                ),
              ],
            ),
          )
        : Container();
  }
}
