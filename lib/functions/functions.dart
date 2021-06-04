import 'dart:convert';
import 'dart:js_util';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:web_app_template/helpers/coinGeckoTokenList.dart';
import '../../helpers/coinGeckoTokenList.dart';
import '../widgets/javascript_controller.dart';
import 'package:http/http.dart' as http;

class Paraswap with ChangeNotifier {
  var quote;

  //get rates for chosen pair from kyber api
  Future getRate(List _arguments) async {
    //convert with decimals
    var promise = fetch1InchTokens();
    var tokens = await promiseToFuture(promise);
    var tokensdecoded = json.decode(tokens);
    var decimals = tokensdecoded[_arguments[0]]["decimals"];

    double _amount = double.parse(_arguments[2]) * pow(10, decimals);

    var promise1 = getQuote(_arguments[0], _arguments[1], _amount.toString());
    var quote = await promiseToFuture(promise1);
    var quotedecoded = json.decode(quote);
    quote = quotedecoded;
    notifyListeners();
  }
}

Future getRate(List _arguments) async {
  var fromAmount = BigInt.from(double.parse(_arguments[2]));
  var promise1 = getQuote(_arguments[0], _arguments[1], fromAmount.toString());
  var quote = await promiseToFuture(promise1);
  var quotedecoded = json.decode(quote);
  return quotedecoded;
}

Future getAllSwaps() async {
  List allSwaps = [];
  List srcToken = [];
  Map srcVolume = {};
  List dstToken = [];
  Map dstVolume = {};
  List srcTokenCount = [];
  List dstTokenCount = [];
  double srcTokenVolume = 0.0;
  double dstTokenVolume = 0.0;
  var srcTokenVolumeAddresse;
  var dstTokenVolumeAddresse;

  var promise1 = fetch1InchTokens();
  var tokens = await promiseToFuture(promise1);
  var tokensdecoded = json.decode(tokens);

  var promise = getSwaps();
  var swaps = await promiseToFuture(promise);
  for (var i = 0; i < swaps.length; i++) {
    var swap = json.decode(swaps[i]);
    allSwaps.add(swap);
    srcTokenCount.add(swap["srcToken"]);
    dstTokenCount.add(swap["dstToken"]);

    // storing srcToken and there sold volume
    if (srcToken.contains(swap["srcToken"])) {
      srcVolume[swap["srcToken"]] +=
          (double.parse(swap["amount"]) / pow(10, swap["srcTokenDecimals"]));
    } else {
      srcToken.add(swap["srcToken"]);
      srcVolume[swap["srcToken"]] =
          (double.parse(swap["amount"]) / pow(10, swap["srcTokenDecimals"]));
    }

    // storing dstToken and there sold volume
    if (dstToken.contains(swap["dstToken"])) {
      dstVolume[swap["dstToken"]] += (double.parse(swap["minReturnAmount"]) /
          pow(10, swap["dstTokenDecimals"]));
    } else {
      dstToken.add(swap["dstToken"]);
      dstVolume[swap["dstToken"]] = (double.parse(swap["minReturnAmount"]) /
          pow(10, swap["dstTokenDecimals"]));
    }

    if (srcVolume[swap["srcToken"]] > srcTokenVolume) {
      srcTokenVolume = srcVolume[swap["srcToken"]];
      srcTokenVolumeAddresse = swap["srcToken"];
    }

    if (dstVolume[swap["dstToken"]] > dstTokenVolume) {
      dstTokenVolume = dstVolume[swap["dstToken"]];
      dstTokenVolumeAddresse = swap["dstToken"];
    }
  }

  // counting for most sold and most often bought tokens
  var mostSoldToken = srcTokenCount.toSet().reduce((i, j) =>
      srcTokenCount.where((v) => v == i).length >
              srcTokenCount.where((v) => v == j).length
          ? i
          : j);

  var mostBoughtToken = dstTokenCount.toSet().reduce((i, j) =>
      dstTokenCount.where((v) => v == i).length >
              dstTokenCount.where((v) => v == j).length
          ? i
          : j);

  print(srcTokenVolumeAddresse);
  print(dstTokenVolumeAddresse);
  return [
    allSwaps,
    tokensdecoded[mostSoldToken.toLowerCase()],
    tokensdecoded[mostBoughtToken.toLowerCase()],
    tokensdecoded[srcTokenVolumeAddresse.toLowerCase()],
    tokensdecoded[dstTokenVolumeAddresse.toLowerCase()]
  ];
}

Future<List<Map>> fetchTokens() async {
  List<Map> tokenList = [];
  var promise = fetch1InchTokens();
  var tokens = await promiseToFuture(promise);
  var tokensdecoded = json.decode(tokens);
  var tokensdecodedList = tokensdecoded.values.toList();

  for (var i = 0; i < tokensdecodedList.length; i++) {
    Map token = {
      "symbol": tokensdecodedList[i]["symbol"],
      "name": tokensdecodedList[i]["name"],
      "address": tokensdecodedList[i]["address"],
      "decimals": tokensdecodedList[i]["decimals"],
      "logoURI": tokensdecodedList[i]["logoURI"]
    };
    tokenList.add(token);
  }
  tokenList.sort((a, b) => a["symbol"].compareTo(b["symbol"]));
  return tokenList;
}

Future swapTokens(List _arguments) async {
  var fromAmount = BigInt.from(double.parse(_arguments[2]));
  var promise = swap(_arguments[0], _arguments[1], fromAmount.toString());
  await promiseToFuture(promise);
}

//get my Balances from Moralis
Future getBalances() async {
  var myBalances = [];
  var ethbalance = await getMyEthBalance();
  Map eth = {
    "name": "Ether",
    "symbol": "Eth",
    "balance": ethbalance,
    "decimals": "18"
  };
  myBalances.add(eth);
  var bscbalance = await getMyBscBalance();
  Map bsc = {
    "name": "Binance Coin",
    "symbol": "BNB",
    "balance": bscbalance,
    "decimals": "18"
  };
  myBalances.add(bsc);
  var promise = getTokenBalances();
  var balance = await promiseToFuture(promise);
  for (var i = 0; i < balance.length; i++) {
    myBalances.add(json.decode(balance[i]));
  }
  for (var i = 0; i < myBalances.length; i++) {
    var coinGeckoId =
        coinGeckoTokens[myBalances[i]["symbol"].toLowerCase()]["id"];
    var response = await http.get(Uri.parse(
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=${coinGeckoId}&order=market_cap_desc&per_page=100&page=1&sparkline=false'));
    var jsonData = json.decode(response.body);
    var currentPrice = jsonData[0]["current_price"];
    currentPrice == null
        ? myBalances[i]["current_price"] = 0
        : myBalances[i]["current_price"] = jsonData[0]["current_price"];
  }

  var test = await http
      .get(Uri.parse('https://api.coingecko.com/api/v3/asset_platforms'));
  var testData = json.decode(test.body);
  print(testData);
  return myBalances;
}

//get my EthBalance from Moralis
Future getMyEthBalance() async {
  var promise = getEthBalance();
  var ethbalance = await promiseToFuture(promise);
  return ethbalance;
}

//get my EthBalance from Moralis
Future getMyBscBalance() async {
  var promise = getBscBalance();
  var bscbalance = await promiseToFuture(promise);
  return bscbalance;
}

//get my EthBalance from Moralis
Future getMyNFTBalance() async {
  var myNFT = [];
  var promise = getMyNFT();
  var nftbalance = await promiseToFuture(promise);
  for (var i = 0; i < nftbalance.length; i++) {
    var nft = json.decode(nftbalance[i]);
    myNFT.add(nft);
  }
  return myNFT;
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

//get all my Assests
Future getMyAssets() async {
  var tokens = await getBalances();
  var nfts = await getMyNFTBalance();
  return ([tokens, nfts]);
}
