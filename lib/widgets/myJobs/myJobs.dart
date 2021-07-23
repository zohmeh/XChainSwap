import 'dart:async';

import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:provider/provider.dart';
import 'package:web_app_template/functions/functions.dart';
import 'package:web_app_template/widgets/buttons/button.dart';

class MyJobsDesktopView extends StatefulWidget {
  final chain;

  MyJobsDesktopView({this.chain});

  @override
  _MyJobsDesktopViewState createState() => _MyJobsDesktopViewState();
}

class _MyJobsDesktopViewState extends State<MyJobsDesktopView> {
  @override
  Widget build(BuildContext context) {
    widget.chain == 0
        ? Provider.of<EthBlockchainInteraction>(context, listen: true)
        : Provider.of<PolygonBlockchainInteraction>(context, listen: true);

    return Container(
      height: 500,
      width: (MediaQuery.of(context).size.width / 2) - 10,
      child: Card(
        color: Theme.of(context).primaryColor,
        child: FutureBuilder(
            future: widget.chain == 0
                ? getAllMyEthTransactions()
                : getAllMyPolygonTransactions(),
            builder: (ctx, depositsnapshot) {
              if (depositsnapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else {
                List jobs = depositsnapshot.data;
                return DataTable2(
                    columns: [
                      DataColumn(
                          label: Text(
                        "TxHash",
                        style: TextStyle(color: Theme.of(context).accentColor),
                      )),
                      DataColumn(
                          label: Text(
                        "Methode",
                        style: TextStyle(color: Theme.of(context).accentColor),
                      )),
                      //DataColumn(
                      //    label: Text(
                      //  "From Address",
                      //  style: TextStyle(color: Theme.of(context).accentColor),
                      //)),
                      DataColumn(
                          label: Text(
                        "To Address",
                        style: TextStyle(color: Theme.of(context).accentColor),
                      )),
                      DataColumn(
                          label: Text(
                        "Value",
                        style: TextStyle(color: Theme.of(context).accentColor),
                      )),
                      DataColumn(
                          label: Text(
                        "Amount",
                        style: TextStyle(color: Theme.of(context).accentColor),
                      )),
                      DataColumn(
                          label: Text(
                        "Token",
                        style: TextStyle(color: Theme.of(context).accentColor),
                      )),
                      DataColumn(
                          label: Text(
                        "Status",
                        style: TextStyle(color: Theme.of(context).accentColor),
                      )),
                      if (widget.chain == 2)
                        DataColumn(
                            label: Text(
                          "Activity",
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        )),
                    ],
                    rows: jobs
                        .map(
                          ((element) => DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      element["hash"].substring(0, 5) +
                                          "..." +
                                          element["hash"].substring(
                                              element["hash"].length - 5),
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).highlightColor),
                                    ),
                                  ),

                                  DataCell(Text(
                                    element["input"],
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).highlightColor),
                                  )),
                                  //DataCell(Text(
                                  //  element["from_address"],
                                  //  style: TextStyle(
                                  //      fontSize: 10,
                                  //      color:
                                  //          Theme.of(context).highlightColor),
                                  //)),
                                  DataCell(Text(
                                    element["to_address"].substring(0, 5) +
                                        "..." +
                                        element["to_address"].substring(
                                            element["to_address"].length - 5),
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).highlightColor),
                                  )),
                                  DataCell(Text(
                                    (double.parse(element["value"]) /
                                            1000000000000000000)
                                        .toString(),
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).highlightColor),
                                  )),
                                  DataCell(Text(
                                    (double.parse(element["tokenamount"]) /
                                            1000000000000000000)
                                        .toString(),
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).highlightColor),
                                  )),
                                  DataCell(Text(
                                    element["token_symbol"],
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).highlightColor),
                                  )),
                                  DataCell(Text(
                                    element["confirmed"] == true
                                        ? "confirmed"
                                        : "pending",
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).highlightColor),
                                  )),
                                  if (widget.chain == 2)
                                    DataCell(element["openJob"] != null
                                        ? button(
                                            Theme.of(context).buttonColor,
                                            Theme.of(context).highlightColor,
                                            "Get active",
                                            Provider.of<EthBlockchainInteraction>(
                                                    context,
                                                    listen: false)
                                                .openActivity,
                                            [element["openJob"]])
                                        : Text(""))
                                ],
                              )),
                        )
                        .toList());
              }
            }),
      ),
    );
  }
}
