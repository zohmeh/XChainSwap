import 'dart:convert';
import 'dart:js';
import 'dart:js_util';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/javascript_controller.dart';

class Paraswap with ChangeNotifier {
  var toAmount;
  var fromTokenAddress;
  var toTokenAddress;
  var fromAmount;
  var fromTokenDecimal;
  var toTokenDecimal;
  var minRate;

  //get rates for chosen pair from kyber api
  Future getRate(List _arguments) async {
    if (_arguments[2] != "") {
      //find from and to token addresses
      fromAmount = _arguments[2];
      List tokens = [];

      tokens = await fetchTokens();

      for (var i = 0; i < tokens.length; i++) {
        if (tokens[i]["symbol"] == _arguments[0]) {
          fromTokenAddress = tokens[i]["address"];
          fromTokenDecimal = tokens[i]["decimals"];
        }
        if (tokens[i]["symbol"] == _arguments[1]) {
          toTokenAddress = tokens[i]["address"];
          toTokenDecimal = tokens[i]["decimals"];
        }
      }
      var promise1 = getTokenPairRate(fromTokenAddress, toTokenAddress,
          (int.parse(fromAmount) * pow(10, fromTokenDecimal)).toString());
      var rates = await promiseToFuture(promise1);

      var ratesdecoded = json.decode(rates);
      minRate = int.parse(ratesdecoded["slippageRate"]);
      toAmount =
          (int.parse(ratesdecoded["expectedRate"]) / pow(10, toTokenDecimal)) *
              int.parse(fromAmount);
      notifyListeners();
    } else {
      return;
    }
  }

  Future swapTokens() async {
    var minToAmount = toAmount; // * 0.97;
    var promise = swap(
        fromTokenAddress,
        toTokenAddress,
        (int.parse(fromAmount) * pow(10, fromTokenDecimal)).toString(),
        (minToAmount * pow(10, toTokenDecimal)).toString(),
        minRate.toString());
    var tokens = await promiseToFuture(promise);
    //var tokensdecoded = json.decode(tokens);
  }
}

Future<List<dynamic>> fetchTokens() async {
  var promise = fetchParaswapTokens();
  var tokens = await promiseToFuture(promise);
  var tokensdecoded = json.decode(tokens);

  return tokensdecoded["data"];
}

//get my Balances from Moralis
Future getBalances() async {
  var promise = getAllBalances();
  var balance = await promiseToFuture(promise);
  var balancedecoded = json.decode(balance);
  return balancedecoded;
}

//get my EthBalance from Moralis
Future getMyEthBalance() async {
  var promise = getEthBalance();
  var ethbalance = await promiseToFuture(promise);
  return ethbalance;
}

//get my Transactions from Moralis
Future getAllMyTransactions() async {
  var promise = getMyTransactions();
  var transactions = await promiseToFuture(promise);
  var transactionsdecoded = json.decode(transactions);
  return transactionsdecoded;
}

//deploy my portfolio
Future deployMyPortfolio(List _arguments) async {
  var promise = deployPortfolio();
  var deploy = await promiseToFuture(promise);
}

//get all deployed portfolios
Future getAllDeployedPortfolios() async {
  var promise = getDeployedPortfolios();
  var portfolios = await promiseToFuture(promise);
  var portfoliosdecoded = json.decode(portfolios);
  return portfoliosdecoded;
}

//follow a portfolios
Future follow(List _arguments) async {
  var promise = followPortfolio(_arguments[0]);
  var follow = await promiseToFuture(promise);
}

//get all portfolios i follow
Future getMyFollowedPortfolios() async {
  var promise = getFollowedPortfolios();
  var followed = await promiseToFuture(promise);
  var followeddecoded = json.decode(followed);
  return followeddecoded;
}
