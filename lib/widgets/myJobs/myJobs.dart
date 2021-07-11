import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:provider/provider.dart';
import 'package:web_app_template/functions/functions.dart';

class MyJobsDesktopView extends StatefulWidget {
  @override
  _MyJobsDesktopViewState createState() => _MyJobsDesktopViewState();
}

class _MyJobsDesktopViewState extends State<MyJobsDesktopView> {
  @override
  Widget build(BuildContext context) {
    Provider.of<BlockchainInteraction>(context, listen: true).status;
    Provider.of<BlockchainInteraction>(context, listen: true).txHash;

    return Container(
      height: 500,
      width: MediaQuery.of(context).size.width / 2,
      child: Card(
        color: Theme.of(context).primaryColor,
        child: FutureBuilder(
            future: getDeposits(),
            builder: (ctx, depositsnapshot) {
              if (depositsnapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else {
                List jobs = depositsnapshot.data;
                return DataTable2(
                    columns: [
                      DataColumn(
                          label: Text(
                        "Transactionhash",
                        style: TextStyle(color: Theme.of(context).accentColor),
                      )),
                      DataColumn(
                          label: Text(
                        "Status",
                        style: TextStyle(color: Theme.of(context).accentColor),
                      )),
                    ],
                    rows: jobs
                        .map(
                          ((element) => DataRow(
                                cells: [
                                  DataCell(Text(
                                    element["transaction_hash"],
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
