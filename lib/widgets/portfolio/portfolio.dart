import 'dart:math';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:web_app_template/functions/functions.dart';
import 'package:web_app_template/widgets/buttons/button.dart';

class Portfolio extends StatefulWidget {
  final String username;
  final List portfolio;
  final String portfolioId;
  final bool followed;

  Portfolio({this.username, this.portfolio, this.portfolioId, this.followed});

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Username: " + widget.username),
                  widget.followed == false
                      ? button(
                          Theme.of(context).buttonColor,
                          Theme.of(context).highlightColor,
                          "Follow this portfolio",
                          follow,
                          [widget.portfolioId])
                      : button(
                          Theme.of(context).buttonColor,
                          Theme.of(context).highlightColor,
                          "Stop following",
                        )
                ],
              ),
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
