import 'dart:math';
import 'package:flutter/material.dart';
import '../../functions/functions.dart';
import '../../widgets/buttons/button.dart';
import '../../widgets/inputfields/inputField.dart';

class SwapWidgetDesktopview extends StatefulWidget {
  final TextEditingController swapamount = TextEditingController();
  @override
  _SwapWidgetDesktopviewState createState() => _SwapWidgetDesktopviewState();
}

class _SwapWidgetDesktopviewState extends State<SwapWidgetDesktopview> {
  String fromToken;
  String toToken;
  String fromAmount;
  Future tokens;
  var quote;
  int chain = 0;

  List colors = [Colors.white, Colors.purpleAccent, Colors.purpleAccent];
  List color = [1, 0, 0];

  chainChoice(_choice) {
    setState(() {
      chain = _choice;
      color = [0, 0, 0];
      color[_choice] = 1;
      fromToken = null;
      toToken = null;
      fromAmount = null;
      widget.swapamount.text = "";
      quote = null;
    });
  }

  @override
  void initState() {
    tokens = fetchTokens();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //var width = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: tokens,
      builder: (ctx, tokensnapshot) {
        if (tokensnapshot.connectionState == ConnectionState.waiting) {
          return Container(
              width: (MediaQuery.of(context).size.width - 150) / 2,
              child: Center(child: CircularProgressIndicator()));
        } else {
          List<Map> tokenList = tokensnapshot.data[chain];
          return Container(
            padding: EdgeInsets.all(30),
            height: (MediaQuery.of(context).size.height) / 2,
            width: (MediaQuery.of(context).size.width - 150) / 2,
            child: Card(
              color: Theme.of(context).primaryColor,
              //elevation: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          onPressed: () => chainChoice(0),
                          child: Text(
                            "Ethereumchain",
                            style: TextStyle(color: colors[color[0]]),
                          )),
                      TextButton(
                          onPressed: () => chainChoice(1),
                          child: Text(
                            "BSCchain",
                            style: TextStyle(color: colors[color[1]]),
                          )),
                      TextButton(
                          onPressed: () => chainChoice(2),
                          child: Text(
                            "Polygon",
                            style: TextStyle(color: colors[color[2]]),
                          )),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 300,
                        child: inputField(
                          ctx: context,
                          controller: widget.swapamount,
                          labelText: "Input the amount to swap",
                          topMargin: 0,
                          leftMargin: 0,
                          rightMargin: 0,
                          bottomMargin: 0,
                          onChanged: (value) async {
                            //search for decimal
                            for (var i = 0; i < tokenList.length; i++) {
                              if (tokenList[i]["address"] == fromToken) {
                                setState(() {
                                  fromAmount = (double.parse(value) *
                                          pow(10, tokenList[i]["decimals"]))
                                      .toString();
                                });
                              }
                            }
                            quote = await getRate(
                                [fromToken, toToken, fromAmount, chain]);
                          },
                          onSubmitted: (value) async {
                            //search for decimal
                            for (var i = 0; i < tokenList.length; i++) {
                              if (tokenList[i]["address"] == fromToken) {
                                setState(() {
                                  fromAmount = (double.parse(value) *
                                          pow(10, tokenList[i]["decimals"]))
                                      .toString();
                                });
                              }
                            }
                            quote = await getRate(
                                [fromToken, toToken, fromAmount, chain]);
                          },
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton<String>(
                            isDense: true,
                            hint: new Text(
                              "Select Token",
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                            ),
                            value: fromToken,
                            onChanged: (value) {
                              setState(() {
                                fromToken = value;
                              });
                            },
                            items: tokenList.map((Map map) {
                              return new DropdownMenuItem<String>(
                                value: map["address"],
                                child: Container(
                                  width: 300,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Image.network(
                                        map["logoURI"],
                                        width: 25,
                                      ),
                                      Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Text(
                                            map["symbol"],
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .accentColor),
                                          )),
                                      //Container(
                                      //    margin: EdgeInsets.only(left: 20),
                                      //    child: Flexible(
                                      //      child: Text(
                                      //        map["name"],
                                      //        style: TextStyle(
                                      //            color: Theme.of(context)
                                      //                .accentColor),
                                      //      ),
                                      //    )),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      )
                    ],
                  ),
                  button(
                      Theme.of(context).buttonColor,
                      Theme.of(context).highlightColor,
                      "Swap Tokens",
                      swapTokens,
                      [fromToken, toToken, fromAmount, chain]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          width: 300,
                          child: quote != null
                              ? Text(
                                  (int.parse(quote["toTokenAmount"]) /
                                          pow(10, quote["toToken"]["decimals"]))
                                      .toString(),
                                  style: TextStyle(
                                      color: Theme.of(context).highlightColor),
                                )
                              : Text("")),
                      DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton<String>(
                            isDense: true,
                            hint: new Text(
                              "Select Token",
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                            ),
                            value: toToken,
                            onChanged: (value) {
                              setState(() {
                                toToken = value;
                              });
                            },
                            items: tokenList.map((Map map) {
                              return new DropdownMenuItem<String>(
                                value: map["address"],
                                child: Container(
                                  width: 300,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Image.network(
                                        map["logoURI"],
                                        width: 25,
                                      ),
                                      Container(
                                          width: 123,
                                          margin: EdgeInsets.only(left: 10),
                                          child: Text(
                                            map["symbol"],
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .accentColor),
                                          )),
                                      //Flexible(
                                      //  child: Container(
                                      //      width: 122,
                                      //      margin: EdgeInsets.only(left: 20),
                                      //      child: Text(
                                      //        map["name"],
                                      //        style: TextStyle(
                                      //            color: Theme.of(context)
                                      //                .accentColor),
                                      //      )),
                                      //),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
