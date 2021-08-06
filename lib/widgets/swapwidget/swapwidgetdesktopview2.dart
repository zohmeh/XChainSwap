import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_app_template/provider/blockchainprovider.dart';
import 'package:web_app_template/widgets/dropdownlist/drowpdownlist.dart';
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

  onButtonClick(List _arguments) {
    BuildContext _context = _arguments[0];
    var _tokens = _arguments[1];

    return showDialog(
      barrierColor: Color(0x00000000),
      context: _context,
      builder: (context) {
        return Stack(children: [
          Positioned(
            bottom: 50,
            right: 25,
            child: Container(
              height: 300,
              width: 200,
              color: Colors.red,
              child: ListView.separated(
                  separatorBuilder: (context, idx) {
                    return Divider();
                  },
                  itemCount: _tokens.length,
                  itemBuilder: (ctx, idx) {
                    return FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          children: [
                            Image.network(_tokens[idx]["logoURI"], width: 35),
                            SizedBox(width: 10),
                            Text(_tokens[idx]["symbol"])
                          ],
                        ));
                  }),
            ),
          ),
        ]);
      },
    );
  }

  @override
  void initState() {
    tokens = fetchTokens();
    super.initState();
  }

  final button1Key = GlobalKey();
  final button2Key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      height: (MediaQuery.of(context).size.height) / 3 + 20,
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
                /*RenderBox box1 = button1Key.currentContext.findRenderObject();
                Offset position1 =
                    box1.localToGlobal(Offset.zero); //this is global position
                RenderBox box2 = button2Key.currentContext.findRenderObject();
                Offset position2 =
                    box2.localToGlobal(Offset.zero); //this is global position

                double y1 = position1.dy;
                double x1 = position1.dx;
                print(y1);
                print(x1);
                double y2 = position2.dy;
                double x2 = position2.dx;
                print(y2);
                print(x2);*/
                tokenList = tokenssnapshot.data;
                return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            PopupMenuButton(
                                child: Text(
                                  "Select Token Ethereum",
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor),
                                ),
                                itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: Container(
                                          height: 300,
                                          width: 200,
                                          color: Colors.red,
                                          child: ListView.separated(
                                              separatorBuilder: (context, idx) {
                                                return Divider();
                                              },
                                              itemCount: tokenList[0].length,
                                              itemBuilder: (ctx, idx) {
                                                return FlatButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Image.network(
                                                            tokenList[0][idx]
                                                                ["logoURI"],
                                                            width: 35),
                                                        SizedBox(width: 10),
                                                        Text(tokenList[0][idx]
                                                            ["symbol"])
                                                      ],
                                                    ));
                                              }),
                                        ),
                                        value: 1,
                                      ),
                                    ]),
                            /*button(
                                Theme.of(context).primaryColor,
                                Theme.of(context).accentColor,
                                "Select Token Ethereum",
                                onButtonClick,
                                [context, tokenList[0]]),*/
                            PopupMenuButton(
                                child: Text(
                                  "Select Token Polygon",
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor),
                                ),
                                itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: Container(
                                          height: 300,
                                          width: 200,
                                          color: Colors.red,
                                          child: ListView.separated(
                                              separatorBuilder: (context, idx) {
                                                return Divider();
                                              },
                                              itemCount: tokenList[2].length,
                                              itemBuilder: (ctx, idx) {
                                                return FlatButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Image.network(
                                                            tokenList[2][idx]
                                                                ["logoURI"],
                                                            width: 35),
                                                        SizedBox(width: 10),
                                                        Text(tokenList[2][idx]
                                                            ["symbol"])
                                                      ],
                                                    ));
                                              }),
                                        ),
                                        value: 1,
                                      ),
                                    ])
                          ]),
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
                            PopupMenuButton(
                                child: Text(
                                  "Select Token Ethereum",
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor),
                                ),
                                itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: Container(
                                          height: 300,
                                          width: 200,
                                          color: Colors.red,
                                          child: ListView.separated(
                                              separatorBuilder: (context, idx) {
                                                return Divider();
                                              },
                                              itemCount: tokenList[0].length,
                                              itemBuilder: (ctx, idx) {
                                                return FlatButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Image.network(
                                                            tokenList[0][idx]
                                                                ["logoURI"],
                                                            width: 35),
                                                        SizedBox(width: 10),
                                                        Text(tokenList[0][idx]
                                                            ["symbol"])
                                                      ],
                                                    ));
                                              }),
                                        ),
                                        value: 1,
                                      ),
                                    ]),
                            /*button(
                                Theme.of(context).primaryColor,
                                Theme.of(context).accentColor,
                                "Select Token Ethereum",
                                onButtonClick,
                                [context, tokenList[0]]),*/
                            PopupMenuButton(
                                child: Text(
                                  "Select Token Polygon",
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor),
                                ),
                                itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: Container(
                                          height: 300,
                                          width: 200,
                                          color: Colors.red,
                                          child: ListView.separated(
                                              separatorBuilder: (context, idx) {
                                                return Divider();
                                              },
                                              itemCount: tokenList[2].length,
                                              itemBuilder: (ctx, idx) {
                                                return FlatButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Image.network(
                                                            tokenList[2][idx]
                                                                ["logoURI"],
                                                            width: 35),
                                                        SizedBox(width: 10),
                                                        Text(tokenList[2][idx]
                                                            ["symbol"])
                                                      ],
                                                    ));
                                              }),
                                        ),
                                        value: 1,
                                      ),
                                    ])
                          ]),
                    ]);
              }
            }),
      ),
    );
  }
}
