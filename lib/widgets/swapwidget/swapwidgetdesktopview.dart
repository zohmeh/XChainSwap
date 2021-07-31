import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_app_template/provider/blockchainprovider.dart';
import 'package:web_app_template/widgets/dropdownlist/drowpdownlist.dart';
import '../../functions/functions.dart';
import '../../widgets/buttons/button.dart';
import '../../widgets/inputfields/inputField.dart';

class SwapWidgetDesktopview extends StatefulWidget {
  final TextEditingController swapamount = TextEditingController();

  SwapWidgetDesktopview();

  @override
  _SwapWidgetDesktopviewState createState() => _SwapWidgetDesktopviewState();
}

class _SwapWidgetDesktopviewState extends State<SwapWidgetDesktopview> {
  Iterable fromToken = [
    {"address": "0"}
  ];
  Iterable toToken = [
    {"address": "0"}
  ];
  var fromChain;
  var toChain;
  String fromAmount;
  Future tokens;
  var newQuote;
  List tokenList;
  var quote;

  onChanged(String _value, int _chain, bool _isFromToken) {
    setState(() {
      if (_isFromToken) {
        fromToken =
            tokenList[_chain].where((element) => element["address"] == _value);
        fromChain = _chain;
      } else {
        toToken =
            tokenList[_chain].where((element) => element["address"] == _value);
        toChain = _chain;
      }
    });
  }

  @override
  void initState() {
    tokens = fetchTokens();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //tokenList = widget.tokens;
    return Container(
      padding: EdgeInsets.all(30),
      height: (MediaQuery.of(context).size.height) / 3,
      width: (MediaQuery.of(context).size.width) / 3,
      child: Card(
        color: Theme.of(context).primaryColor,
        //elevation: 10,
        child: FutureBuilder(
            future: tokens,
            builder: (ctx, tokenssnapshot) {
              if (tokenssnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Dropdownlist(
                              tokenList: tokenssnapshot.data[0],
                              label: "Select Token Ethereum",
                              onChanged: onChanged,
                              chain: 0,
                              isFromToken: true),
                          Dropdownlist(
                              tokenList: tokenssnapshot.data[2],
                              label: "Select Token Polygon",
                              onChanged: onChanged,
                              chain: 2,
                              isFromToken: true),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 300,
                            height: 60,
                            child: inputField(
                              ctx: context,
                              controller: widget.swapamount,
                              labelText: "Input the amount to swap",
                              topMargin: 0,
                              leftMargin: 0,
                              rightMargin: 0,
                              bottomMargin: 0,
                              onChanged: (value) async {
                                fromAmount = (double.parse(value) *
                                        pow(10,
                                            fromToken.elementAt(0)["decimals"]))
                                    .toString();
                                newQuote = await getExpectedReturn([
                                  fromToken.elementAt(0)["address"],
                                  toToken.elementAt(0)["address"],
                                  fromAmount,
                                  fromChain,
                                  toChain
                                ]);
                                setState(() {
                                  quote = newQuote;
                                });
                              },
                              onSubmitted: (value) async {
                                fromAmount = (double.parse(value) *
                                        pow(10,
                                            fromToken.elementAt(0)["decimals"]))
                                    .toString();
                                newQuote = await getExpectedReturn([
                                  fromToken.elementAt(0)["address"],
                                  toToken.elementAt(0)["address"],
                                  fromAmount,
                                  fromChain,
                                  toChain
                                ]);
                                setState(() {
                                  quote = newQuote;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      button(
                          Theme.of(context).buttonColor,
                          Theme.of(context).highlightColor,
                          "Swap Tokens",
                          fromChain == 0
                              ? Provider.of<EthBlockchainInteraction>(context,
                                      listen: false)
                                  .swapTokens
                              : Provider.of<PolygonBlockchainInteraction>(
                                      context,
                                      listen: false)
                                  .swapTokens,
                          [
                            fromToken.elementAt(0)["address"],
                            toToken.elementAt(0)["address"],
                            fromAmount,
                            fromChain,
                            toChain,
                            "",
                            "new",
                            ""
                          ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: 100,
                              height: 60,
                              child: Text(
                                "Expected Return: ",
                                style: TextStyle(
                                    color: Theme.of(context).highlightColor),
                              )),
                          SizedBox(width: 10),
                          Container(
                              width: 200,
                              height: 60,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.black)),
                              child: quote != null
                                  ? Text(
                                      quote,
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).highlightColor),
                                    )
                                  : Text("")),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Dropdownlist(
                              tokenList: tokenssnapshot.data[0],
                              label: "Select Token Ethereum",
                              onChanged: onChanged,
                              chain: 0,
                              isFromToken: false),
                          Dropdownlist(
                              tokenList: tokenssnapshot.data[2],
                              label: "Select Token Polygon",
                              onChanged: onChanged,
                              chain: 2,
                              isFromToken: false),
                        ],
                      ),
                    ]);
              }
            }),
      ),
    );
  }
}
