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
  List<String> tokenSymbols = [];

  @override
  void initState() {
    fetchTokens().then((result) {
      setState(() {
        tokenSymbols = result;
        fromToken = tokenSymbols[0];
        toToken = tokenSymbols[1];
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var amount = Provider.of<Paraswap>(context).amount;
    var width = MediaQuery.of(context).size.width;
    return Card(
      elevation: 10,
      child: Container(
        padding: EdgeInsets.all(30),
        height: width / 5,
        width: width / 5,
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
                      setState(() {});
                    },
                    onSubmitted: (value) {
                      setState(() {});
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
                    setState(() {
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
                Provider.of<Paraswap>(context).getRate,
                [fromToken, toToken, widget.swapamount.text]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: width / 15,
                    child: amount != null ? Text(amount) : Text("")),
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
                    setState(() {
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
