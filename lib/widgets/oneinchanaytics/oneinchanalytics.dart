import 'dart:math';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:web_app_template/widgets/tokensymbols.dart';
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
          List swapList = swapsnapshot.data[0];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 2,
                width: (MediaQuery.of(context).size.width - 150) / 3,
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
                                DataCell(Row(
                                  children: [
                                    element["srcTokenSymbol"] != ""
                                        ? Tokensymbols(
                                            height: 25,
                                            width: 25,
                                            image: element["srcTokenSymbol"])
                                        : Text(""),
                                    SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        element["srcTokenName"] != ""
                                            ? element["srcTokenName"]
                                            : element["srcToken"],
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .highlightColor),
                                      ),
                                    ),
                                  ],
                                )),
                                DataCell(Row(
                                  children: [
                                    element["dstTokenSymbol"] != ""
                                        ? Tokensymbols(
                                            height: 25,
                                            width: 25,
                                            image: element["dstTokenSymbol"])
                                        : Text(""),
                                    SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        element["dstTokenName"] != ""
                                            ? element["dstTokenName"]
                                            : element["dstToken"],
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .highlightColor),
                                      ),
                                    ),
                                  ],
                                )),
                                DataCell(Text(
                                  (double.parse(element["amount"]) /
                                          pow(10, element["srcTokenDecimals"]))
                                      .toStringAsFixed(4),
                                  style: TextStyle(
                                      color: Theme.of(context).highlightColor),
                                )),
                              ],
                            )),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: 15),
              Container(
                //height: MediaQuery.of(context).size.height / 2,
                width: (MediaQuery.of(context).size.width - 150) / 3,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("Most often sold Tokens: ",
                            style: TextStyle(
                                color: Theme.of(context).highlightColor)),
                        SizedBox(width: 15),
                        swapsnapshot.data[1]["logoURI"] != ""
                            ? Tokensymbols(
                                height: 25,
                                width: 25,
                                image: swapsnapshot.data[1]["logoURI"])
                            : Text(""),
                        SizedBox(width: 15),
                        Text(swapsnapshot.data[1]["symbol"],
                            style: TextStyle(
                                color: Theme.of(context).highlightColor)),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Text("Most often bought Tokens: ",
                            style: TextStyle(
                                color: Theme.of(context).highlightColor)),
                        SizedBox(width: 15),
                        swapsnapshot.data[2]["logoURI"] != ""
                            ? Tokensymbols(
                                height: 25,
                                width: 25,
                                image: swapsnapshot.data[2]["logoURI"])
                            : Text(""),
                        SizedBox(width: 15),
                        Text(swapsnapshot.data[2]["symbol"],
                            style: TextStyle(
                                color: Theme.of(context).highlightColor)),
                      ],
                    ),
                    SizedBox(height: 15),
                    swapsnapshot.data[3] != null
                        ? Row(
                            children: [
                              Text("Most sold Tokens in Tokenvolume: ",
                                  style: TextStyle(
                                      color: Theme.of(context).highlightColor)),
                              SizedBox(width: 15),
                              swapsnapshot.data[3]["logoURI"] != ""
                                  ? Tokensymbols(
                                      height: 25,
                                      width: 25,
                                      image: swapsnapshot.data[3]["logoURI"])
                                  : Text(""),
                              SizedBox(width: 15),
                              Text(swapsnapshot.data[3]["symbol"],
                                  style: TextStyle(
                                      color: Theme.of(context).highlightColor)),
                            ],
                          )
                        : Container(),
                    SizedBox(height: 15),
                    swapsnapshot.data[4] != null
                        ? Row(
                            children: [
                              Text("Most bought Tokens in Tokenvolume: ",
                                  style: TextStyle(
                                      color: Theme.of(context).highlightColor)),
                              SizedBox(width: 15),
                              swapsnapshot.data[4]["logoURI"] != ""
                                  ? Tokensymbols(
                                      height: 25,
                                      width: 25,
                                      image: swapsnapshot.data[4]["logoURI"])
                                  : Text(""),
                              SizedBox(width: 15),
                              Text(swapsnapshot.data[4]["symbol"],
                                  style: TextStyle(
                                      color: Theme.of(context).highlightColor)),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
