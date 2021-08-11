import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:provider/provider.dart';
import 'package:web_app_template/helpers/tokenAmountConverter.dart';
import '../../functions/functions.dart';
import '../../provider/blockchainprovider.dart';
import '../../widgets/buttons/button.dart';
import 'package:url_launcher/url_launcher.dart';

class MyJobsDesktopView extends StatefulWidget {
  final chain;

  MyJobsDesktopView({this.chain});

  @override
  _MyJobsDesktopViewState createState() => _MyJobsDesktopViewState();
}

class _MyJobsDesktopViewState extends State<MyJobsDesktopView> {
  Future transactions;

  @override
  void initState() {
    widget.chain == 0
        ? transactions = getAllMyEthTransactions()
        : transactions = getAllMyPolygonTransactions();
    super.initState();
  }

  void _launchURL(String _url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

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
            future: transactions,
            builder: (ctx, transactionssnapshot) {
              if (transactionssnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                List tx = transactionssnapshot.data;
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
                    DataColumn(
                        label: Text(
                      "To \n Address",
                      style: TextStyle(color: Theme.of(context).accentColor),
                    )),
                    DataColumn(
                        label: Text(
                      widget.chain == 0 ? "Ether" : "Matic",
                      style: TextStyle(color: Theme.of(context).accentColor),
                    )),
                    DataColumn(
                        label: Text(
                      "Token \n Amount",
                      style: TextStyle(color: Theme.of(context).accentColor),
                    )),
                    DataColumn(
                        label: Text(
                      "Token \n Symbol",
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
                        style: TextStyle(color: Theme.of(context).accentColor),
                      )),
                  ],
                  rows: tx
                      .map(
                        ((element) => DataRow(
                              cells: [
                                DataCell(
                                  InkWell(
                                    child: Text(
                                      element["hash"].substring(0, 5) +
                                          "..." +
                                          element["hash"].substring(
                                              element["hash"].length - 5),
                                      style: TextStyle(
                                          color: Theme.of(context).buttonColor),
                                    ),
                                    onTap: () => widget.chain == 0
                                        ? _launchURL(
                                            'https://etherscan.io/tx/${element["hash"]}')
                                        : _launchURL(
                                            'https://polygonscan.com/tx/${element["hash"]}'),
                                  ),
                                ),
                                DataCell(Text(
                                  element["method"],
                                  style: TextStyle(
                                      color: Theme.of(context).highlightColor),
                                )),
                                DataCell(Text(
                                  element["toAddress"].substring(0, 5) +
                                      "..." +
                                      element["toAddress"].substring(
                                          element["toAddress"].length - 5),
                                  style: TextStyle(
                                      color: Theme.of(context).highlightColor),
                                )),
                                DataCell(Expanded(
                                  child: Text(
                                    convertTokenAmount(
                                      element["value"],
                                      element["tokenDecimals"],
                                    ),
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).highlightColor),
                                  ),
                                )),
                                DataCell(
                                  Expanded(
                                    child: element["tokenAmount"] == false
                                        ? Text("")
                                        : Text(
                                            convertTokenAmount(
                                              element["tokenAmount"],
                                              element["tokenDecimals"],
                                            ),
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .highlightColor),
                                          ),
                                  ),
                                ),
                                DataCell(element["tokenSymbol"] == false
                                    ? Text("")
                                    : Text(
                                        element["tokenSymbol"],
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .highlightColor),
                                      )),
                                DataCell(Text(
                                  element["status"] == true
                                      ? "confirmed"
                                      : "pending",
                                  style: TextStyle(
                                      color: Theme.of(context).highlightColor),
                                )),
                                if (widget.chain == 2)
                                  DataCell(element["activity"] ==
                                          "erc20Ethcompleted"
                                      ? button(
                                          Theme.of(context).buttonColor,
                                          Theme.of(context).highlightColor,
                                          "Action",
                                          Provider.of<EthBlockchainInteraction>(
                                                  context,
                                                  listen: false)
                                              .openActivity,
                                          [element["activityId"]])
                                      : Text(""))
                              ],
                            )),
                      )
                      .toList(),
                );
              }
            }),
      ),
    );
  }
}
