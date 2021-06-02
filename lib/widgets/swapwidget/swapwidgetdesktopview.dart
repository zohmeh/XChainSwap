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

  @override
  void initState() {
    tokens = fetchTokens();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: tokens,
      builder: (ctx, tokensnapshot) {
        if (tokensnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          List<Map> tokenList = tokensnapshot.data;
          return Container(
            padding: EdgeInsets.all(30),
            height: width / 3,
            width: width / 3,
            child: Card(
              color: Theme.of(context).primaryColor,
              //elevation: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: width / 15,
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
                            quote =
                                await getRate([fromToken, toToken, fromAmount]);
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
                            quote =
                                await getRate([fromToken, toToken, fromAmount]);
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
                                      Container(
                                          margin: EdgeInsets.only(left: 20),
                                          child: Text(
                                            map["name"],
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .accentColor),
                                          )),
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
                      [fromToken, toToken, fromAmount]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          width: width / 15,
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
                                      Flexible(
                                        child: Container(
                                            width: 122,
                                            margin: EdgeInsets.only(left: 20),
                                            child: Text(
                                              map["name"],
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .accentColor),
                                            )),
                                      ),
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
