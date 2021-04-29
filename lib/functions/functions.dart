import 'dart:convert';
import 'dart:js_util';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/javascript_controller.dart';

class Paraswap with ChangeNotifier {
  var amount;

  //get rates for chosen pair from paraswap api
  Future getRate(List _arguments) async {
    var decimals;
    var promise1 =
        getTokenPairRate(_arguments[0], _arguments[1], _arguments[2]);
    var rates = await promiseToFuture(promise1);

    //fetch token from paraswap to get the decimals for toToken
    var promise2 = fetchParaswapTokens();
    var tokens = await promiseToFuture(promise2);
    var tokensdecoded = json.decode(tokens);

    for (var i = 0; i < tokensdecoded.length; i++) {
      if (tokensdecoded[i]["symbol"] == _arguments[1]) {
        decimals = tokensdecoded[i]["decimals"];
      }
    }

    var ratesdecoded = json.decode(rates);
    amount = (int.parse(ratesdecoded["unit"]) / (pow(10, decimals))).toString();
    notifyListeners();
  }
}

Future<List<String>> fetchTokens() async {
  List<String> tokenSymbols = [];
  var promise = fetchParaswapTokens();
  var tokens = await promiseToFuture(promise);
  var tokensdecoded = json.decode(tokens);
  for (var i = 0; i < tokensdecoded.length; i++) {
    tokenSymbols.add(tokensdecoded[i]["symbol"]);
  }
  return tokenSymbols;
}
