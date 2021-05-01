import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  List<String> tokenSymbols = [];

  @override
  void initState() {
    fromToken = "ETH";
    toToken = "KNC";
    fetchTokens().then((result) {
      setState(() {
        for (var i = 0; i < result.length; i++) {
          tokenSymbols.add(result[i]["symbol"]);
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var toAmount = Provider.of<Paraswap>(context).toAmount;
    var width = MediaQuery.of(context).size.width;
    return Card(
      elevation: 10,
      child: Container(
        padding: EdgeInsets.all(30),
        height: width / 4,
        width: width / 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    onChanged: (value) {
                      setState(() {
                        fromAmount = value;
                        Provider.of<Paraswap>(context, listen: false)
                            .getRate([fromToken, toToken, fromAmount]);
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        fromAmount = value;
                        Provider.of<Paraswap>(context, listen: false)
                            .getRate([fromToken, toToken, fromAmount]);
                      });
                    },
                  ),
                ),
                DropdownButton(
                  value: fromToken,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (value) {
                    fromAmount != null
                        ? setState(() {
                            fromToken = value;
                            Provider.of<Paraswap>(context, listen: false)
                                .getRate([fromToken, toToken, fromAmount]);
                          })
                        : setState(() {
                            fromToken = value;
                          });
                  },
                  items: tokenSymbols.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                )
              ],
            ),
            button(
                Theme.of(context).buttonColor,
                Theme.of(context).highlightColor,
                "Swap Tokens",
                Provider.of<Paraswap>(context).swapTokens),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: width / 15,
                    child: toAmount != null
                        ? Text(toAmount.toString())
                        : Text("")),
                DropdownButton(
                  value: toToken,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (value) {
                    fromAmount != null
                        ? setState(() {
                            toToken = value;
                            Provider.of<Paraswap>(context, listen: false)
                                .getRate([fromToken, toToken, fromAmount]);
                          })
                        : setState(() {
                            toToken = value;
                          });
                  },
                  items: tokenSymbols.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
