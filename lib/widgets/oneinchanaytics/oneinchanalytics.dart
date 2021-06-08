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
    return FutureBuilder(
      future: swaps,
      builder: (ctx, swapsnapshot) {
        if (swapsnapshot.connectionState == ConnectionState.waiting) {
          return Container(
              width: (MediaQuery.of(context).size.width - 150) / 2,
              child: Center(child: CircularProgressIndicator()));
        } else {
          List swapList = swapsnapshot.data[0];
          return FutureBuilder(
            future: lunarCrushAnalysis([
              swapsnapshot.data[1]["symbol"],
              swapsnapshot.data[2]["symbol"],
              swapsnapshot.data[3]["symbol"],
              swapsnapshot.data[4]["symbol"]
            ]),
            builder: (ctx, tokensentimentsnapshot) {
              if (tokensentimentsnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Container(
                    width: (MediaQuery.of(context).size.width - 150) / 2);
              } else {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 2,
                        width: (MediaQuery.of(context).size.width - 150) / 2,
                        child: DataTable2(
                          columns: [
                            DataColumn(
                                label: Text(
                              "From Token",
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                            )),
                            DataColumn(
                                label: Text(
                              "To Token",
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                            )),
                            DataColumn(
                                label: Text(
                              "Amount",
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
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
                                                    image: element[
                                                        "srcTokenSymbol"])
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
                                                    image: element[
                                                        "dstTokenSymbol"])
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
                                                  pow(
                                                      10,
                                                      element[
                                                          "srcTokenDecimals"]))
                                              .toStringAsFixed(4),
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .highlightColor),
                                        )),
                                      ],
                                    )),
                              )
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text("Most often sold Tokens: ",
                              style: TextStyle(
                                  color: Theme.of(context).highlightColor)),
                          SizedBox(width: 15),
                          Container(
                            height: 75,
                            width: 300,
                            child: ListTile(
                                leading: swapsnapshot.data[1]["logoURI"] != ""
                                    ? Tokensymbols(
                                        height: 25,
                                        width: 25,
                                        image: swapsnapshot.data[1]["logoURI"])
                                    : Text(""),
                                title: Text(swapsnapshot.data[1]["symbol"],
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).highlightColor)),
                                subtitle: Text(
                                    "Average Sentiment: " +
                                        tokensentimentsnapshot.data[0]
                                                ["average_sentiment"]
                                            .toString(),
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).highlightColor))),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text("Most often bought Tokens: ",
                              style: TextStyle(
                                  color: Theme.of(context).highlightColor)),
                          SizedBox(width: 15),
                          Container(
                            height: 75,
                            width: 300,
                            child: ListTile(
                                leading: swapsnapshot.data[2]["logoURI"] != ""
                                    ? Tokensymbols(
                                        height: 25,
                                        width: 25,
                                        image: swapsnapshot.data[2]["logoURI"])
                                    : Text(""),
                                title: Text(swapsnapshot.data[2]["symbol"],
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).highlightColor)),
                                subtitle: Text(
                                    "Average Sentiment: " +
                                        tokensentimentsnapshot.data[1]
                                                ["average_sentiment"]
                                            .toString(),
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).highlightColor))),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      swapsnapshot.data[3] != null
                          ? Row(
                              children: [
                                Text("Most sold Tokens in Tokenvolume: ",
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).highlightColor)),
                                SizedBox(width: 15),
                                Container(
                                  height: 75,
                                  width: 300,
                                  child: ListTile(
                                      leading:
                                          swapsnapshot.data[3]["logoURI"] != ""
                                              ? Tokensymbols(
                                                  height: 25,
                                                  width: 25,
                                                  image: swapsnapshot.data[3]
                                                      ["logoURI"])
                                              : Text(""),
                                      title: Text(
                                          swapsnapshot.data[3]["symbol"],
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .highlightColor)),
                                      subtitle: Text(
                                          "Average Sentiment: " +
                                              tokensentimentsnapshot.data[2]
                                                      ["average_sentiment"]
                                                  .toString(),
                                          style: TextStyle(
                                              color: Theme.of(context).highlightColor))),
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(height: 15),
                      swapsnapshot.data[4] != null
                          ? Row(
                              children: [
                                Text("Most bought Tokens in Tokenvolume: ",
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).highlightColor)),
                                SizedBox(width: 15),
                                Container(
                                  height: 75,
                                  width: 300,
                                  child: ListTile(
                                      leading:
                                          swapsnapshot.data[4]["logoURI"] != ""
                                              ? Tokensymbols(
                                                  height: 25,
                                                  width: 25,
                                                  image: swapsnapshot.data[4]
                                                      ["logoURI"])
                                              : Text(""),
                                      title: Text(
                                          swapsnapshot.data[4]["symbol"],
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .highlightColor)),
                                      subtitle: Text(
                                          "Average Sentiment: " +
                                              tokensentimentsnapshot.data[3]
                                                      ["average_sentiment"]
                                                  .toString(),
                                          style: TextStyle(
                                              color: Theme.of(context).highlightColor))),
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}
