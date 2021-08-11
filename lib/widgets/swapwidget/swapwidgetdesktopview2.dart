import 'dart:js_util';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_app_template/provider/blockchainprovider.dart';
import 'package:web_app_template/widgets/buttons/popUpButton.dart';
import 'package:web_app_template/widgets/javascript_controller.dart';
import '../../functions/functions.dart';
import '../../widgets/buttons/button.dart';
import '../../widgets/inputfields/inputField.dart';

class SwapWidgetDesktopview2 extends StatefulWidget {
  final TextEditingController swapamount = TextEditingController();

  SwapWidgetDesktopview2();

  @override
  _SwapWidgetDesktopviewState2 createState() => _SwapWidgetDesktopviewState2();
}

class _SwapWidgetDesktopviewState2 extends State<SwapWidgetDesktopview2> {
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
  String slippage = "1";
  List slippageList = ["0.1", "0.5", "1", "3"];
  int _radioValue = 2;

  onChanged(String _value, int _chain, bool _isFromToken, int _id) {
    setState(() {
      var token =
          tokenList[_chain].where((element) => element["address"] == _value);
      var tokenName = token.elementAt(0)["name"];
      var tokenImage = token.elementAt(0)["logoURI"];
      initialText[_id] = tokenName;
      initialImg[_id] = tokenImage;

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

  Future onClickMax(List _arguments) async {
    String _tokenAddress = _arguments[0];
    int _chain = _arguments[1];
    var promise = getBalancesByAddress(_tokenAddress, _chain);
    var amount = await promiseToFuture(promise);
    setState(() {
      fromAmount = amount[1];
      widget.swapamount.text = amount[0];
    });
  }

  @override
  void initState() {
    tokens = fetchTokens();
    super.initState();
  }

  List initialText = [
    "Select Token Ethereum",
    "Select Token Polygon",
    "Select Token Ethereum",
    "Select Token Polygon"
  ];

  List initialImg = ["", "", "", ""];

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding: EdgeInsets.all(100),
      height: (MediaQuery.of(context).size.height) / 3 + 35,
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
                tokenList = tokenssnapshot.data;
                return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                                width: 200,
                                height: 25,
                                child: popUpButton(
                                    imgSource: initialImg[0],
                                    text: initialText[0],
                                    color: Theme.of(context).accentColor,
                                    tokenList: tokenList[0],
                                    toDo: onChanged,
                                    arguments: [0, true, 0])),
                            Container(
                                width: 200,
                                height: 25,
                                child: popUpButton(
                                    imgSource: initialImg[1],
                                    text: initialText[1],
                                    color: Theme.of(context).accentColor,
                                    tokenList: tokenList[2],
                                    toDo: onChanged,
                                    arguments: [2, true, 1]))
                          ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              width: 300,
                              height: 60,
                              child: Row(
                                children: [
                                  Container(
                                    width: 225,
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
                                                pow(
                                                    10,
                                                    fromToken.elementAt(
                                                        0)["decimals"]))
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
                                                pow(
                                                    10,
                                                    fromToken.elementAt(
                                                        0)["decimals"]))
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
                                  Container(
                                    width: 73,
                                    height: 60,
                                    child: button(
                                        Theme.of(context).buttonColor,
                                        Theme.of(context).highlightColor,
                                        "Max",
                                        onClickMax, [
                                      fromToken.elementAt(0)["address"],
                                      fromChain
                                    ]),
                                  )
                                ],
                              )),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            child: Text(
                              "Max Slippage",
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                            ),
                          ),
                          Container(
                            height: 60,
                            width: 120,
                            child: RadioListTile(
                              title: Text(
                                "0.1%",
                                style: TextStyle(
                                    color: Theme.of(context).accentColor),
                              ),
                              value: 0,
                              groupValue: _radioValue,
                              onChanged: (value) {
                                setState(() {
                                  _radioValue = value;
                                  slippage = slippageList[value];
                                });
                              },
                              activeColor: Theme.of(context).accentColor,
                            ),
                          ),
                          Container(
                            height: 60,
                            width: 120,
                            child: RadioListTile(
                              title: Text(
                                "0.5%",
                                style: TextStyle(
                                    color: Theme.of(context).accentColor),
                              ),
                              value: 1,
                              groupValue: _radioValue,
                              onChanged: (value) {
                                setState(() {
                                  _radioValue = value;
                                  slippage = slippageList[value];
                                });
                              },
                              activeColor: Theme.of(context).accentColor,
                            ),
                          ),
                          Container(
                            height: 60,
                            width: 120,
                            child: RadioListTile(
                              title: Text(
                                "1.0%",
                                style: TextStyle(
                                    color: Theme.of(context).accentColor),
                              ),
                              value: 2,
                              groupValue: _radioValue,
                              onChanged: (value) {
                                setState(() {
                                  _radioValue = value;
                                  slippage = slippageList[value];
                                });
                              },
                              activeColor: Theme.of(context).accentColor,
                            ),
                          ),
                          Container(
                            height: 60,
                            width: 120,
                            child: RadioListTile(
                              title: Text(
                                "3.0%",
                                style: TextStyle(
                                    color: Theme.of(context).accentColor),
                              ),
                              value: 3,
                              groupValue: _radioValue,
                              onChanged: (value) {
                                setState(() {
                                  _radioValue = value;
                                  slippage = slippageList[value];
                                });
                              },
                              activeColor: Theme.of(context).accentColor,
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
                            "",
                            slippage
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
                            Container(
                                width: 200,
                                height: 25,
                                child: popUpButton(
                                    imgSource: initialImg[2],
                                    text: initialText[2],
                                    color: Theme.of(context).accentColor,
                                    tokenList: tokenList[0],
                                    toDo: onChanged,
                                    arguments: [0, false, 2])),
                            Container(
                                width: 200,
                                height: 25,
                                child: popUpButton(
                                    imgSource: initialImg[3],
                                    text: initialText[3],
                                    color: Theme.of(context).accentColor,
                                    tokenList: tokenList[2],
                                    toDo: onChanged,
                                    arguments: [2, false, 3]))
                          ]),
                    ]);
              }
            }),
      ),
    );
  }
}
