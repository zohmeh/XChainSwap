import 'dart:convert';
import 'dart:js_util';
import 'package:flutter/material.dart';
import '../../widgets/buttons/button.dart';
import '../../widgets/inputfields/inputField.dart';
import '../javascript_controller.dart';

class SwapWidgetDesktopview extends StatefulWidget {
  final TextEditingController swapamount = TextEditingController();
  @override
  _SwapWidgetDesktopviewState createState() => _SwapWidgetDesktopviewState();
}

class _SwapWidgetDesktopviewState extends State<SwapWidgetDesktopview> {
  String dropdownvalue = "ETH";
  @override
  Widget build(BuildContext context) {
    List<String> tokenSymbols = [];
    Future fetchTokens() async {
      var promise = fetchParaswapTokens();
      var tokens = await promiseToFuture(promise);
      var tokensdecoded = json.decode(tokens);
      for (var i = 0; i < tokensdecoded.length; i++) {
        tokenSymbols.add(tokensdecoded[i]["symbol"]);
      }
      return tokenSymbols;
    }

    return FutureBuilder(
      future: fetchTokens(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          return Card(
            elevation: 10,
            child: Container(
              padding: EdgeInsets.all(30),
              height: 500,
              width: 500,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
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
                        value: dropdownvalue,
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
                            dropdownvalue = value;
                            print(dropdownvalue);
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
                  button(Theme.of(context).buttonColor,
                      Theme.of(context).highlightColor, "Swap Tokens")
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
