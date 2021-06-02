import 'dart:math';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import '../../functions/functions.dart';

class OneInchAnalytics extends StatefulWidget {
  final TextEditingController swapamount = TextEditingController();
  @override
  _OneInchAnalyticsState createState() => _OneInchAnalyticsState();
}

class _OneInchAnalyticsState extends State<OneInchAnalytics> {
  Future swaps;

  @override
  void initState() {
    swaps = getAllSwaps();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //var width = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: swaps,
      builder: (ctx, swapsnapshot) {
        if (swapsnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          List swapList = swapsnapshot.data;
          return Container(
            height: MediaQuery.of(context).size.height,
            width: (MediaQuery.of(context).size.width - 150) / 2,
            child: DataTable2(
              columns: [
                DataColumn(
                    label: Text(
                  "From Token",
                  style: TextStyle(color: Theme.of(context).accentColor),
                )),
                DataColumn(
                    label: Text(
                  "To Token",
                  style: TextStyle(color: Theme.of(context).accentColor),
                )),
                DataColumn(
                    label: Text(
                  "Amount",
                  style: TextStyle(color: Theme.of(context).accentColor),
                )),
              ],
              rows: swapList
                  .map(
                    ((element) => DataRow(
                          cells: [
                            DataCell(Text(
                              element["srcToken"],
                              style: TextStyle(
                                  color: Theme.of(context).highlightColor),
                            )),
                            DataCell(Text(
                              element["dstToken"],
                              style: TextStyle(
                                  color: Theme.of(context).highlightColor),
                            )),
                            DataCell(Text(
                              element["amount"],
                              style: TextStyle(
                                  color: Theme.of(context).highlightColor),
                            )),
                          ],
                        )),
                  )
                  .toList(),
            ),
          );
        }
      },
    );
  }
}
