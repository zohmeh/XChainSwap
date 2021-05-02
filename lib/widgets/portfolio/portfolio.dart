import 'dart:math';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

class Portfolio extends StatefulWidget {
  final String username;
  final List portfolio;

  Portfolio({this.username, this.portfolio});

  @override
  _PortfolioState createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  @override
  Widget build(BuildContext context) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      front: Card(
        shadowColor: Colors.grey,
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Username: " + widget.username),
              DataTable(
                columns: [
                  DataColumn(label: Text("Name")),
                  DataColumn(label: Text("Symbol")),
                  DataColumn(label: Text("Balance")),
                ],
                rows: widget.portfolio
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
            ],
          ),
        ),
      ),
      back: Container(child: Text("Placeholder for Performancedata")),
    );
  }
}
