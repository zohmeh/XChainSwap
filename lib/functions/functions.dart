import 'dart:convert';
import 'dart:js_util';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:web_app_template/helpers/coinGeckoTokenList.dart';
import '../../helpers/coinGeckoTokenList.dart';
import '../widgets/javascript_controller.dart';
import 'package:http/http.dart' as http;
import 'package:queue/queue.dart';

class BlockchainInteraction with ChangeNotifier {
  var status;
  var txHash;

  Future getStatus(String _txHash) async {
    var promiseStatus = getDepositStatus(_txHash.toString());
    var status = await promiseToFuture(promiseStatus);
    return status;
  }

  Future swapTokens(/*List _arguments*/) async {
    //String fromTokenAddress = _arguments[0];
    //String toTokenAddress = _arguments[1];
    //String fromTokenAmount = _arguments[2];
    //int fromChain = _arguments[3];
    //int toChain = _arguments[4];

    //var fromAmount = BigInt.from(double.parse(fromTokenAmount));

    var promiseSwap = swap(
        /*fromTokenAddress, toTokenAddress, fromAmount.toString(),
      fromChain, toChain*/
        );
    var _txHash = await promiseToFuture(promiseSwap);
    txHash = _txHash;
    notifyListeners();

    var queue = Queue(delay: Duration(milliseconds: 500));
    var _status = await queue.add(() => getStatus(_txHash));
    status = _status;
    notifyListeners();
  }
}

Future getDeposits() async {
  var promise = getMyDeposits();
  var deposits = await promiseToFuture(promise);
  var depositsDecoded = json.decode(deposits);
  return depositsDecoded;
}

Future getRate(List _arguments) async {
  String chain;
  if (_arguments[3] == 0) {
    chain = "1";
  }
  if (_arguments[3] == 1) {
    chain = "56";
  }
  if (_arguments[3] == 2) {
    chain = "137";
  }
  var fromAmount = BigInt.from(double.parse(_arguments[2]));
  var promise1 =
      getQuote(_arguments[0], _arguments[1], fromAmount.toString(), chain);
  var quote = await promiseToFuture(promise1);
  var quotedecoded = json.decode(quote);
  return quotedecoded;
}

Future fetchTokens() async {
  //fetch all tokens for ethereumchain
  List<Map> ethertokenList = [];
  var etherpromise = fetch1InchTokens("1");
  var ethertokens = await promiseToFuture(etherpromise);
  var ethertokensdecoded = json.decode(ethertokens);
  var ethertokensdecodedList = ethertokensdecoded.values.toList();

  for (var i = 0; i < ethertokensdecodedList.length; i++) {
    Map ethertoken = {
      "symbol": ethertokensdecodedList[i]["symbol"],
      "name": ethertokensdecodedList[i]["name"],
      "address": ethertokensdecodedList[i]["address"],
      "decimals": ethertokensdecodedList[i]["decimals"],
      "logoURI": ethertokensdecodedList[i]["logoURI"]
    };
    ethertokenList.add(ethertoken);
  }
  ethertokenList.sort((a, b) => a["symbol"].compareTo(b["symbol"]));

  //fetch all tokens for bscchain
  List<Map> bsctokenList = [];
  var bscpromise = fetch1InchTokens("56");
  var bsctokens = await promiseToFuture(bscpromise);
  var bsctokensdecoded = json.decode(bsctokens);
  var bsctokensdecodedList = bsctokensdecoded.values.toList();

  for (var i = 0; i < bsctokensdecodedList.length; i++) {
    Map bsctoken = {
      "symbol": bsctokensdecodedList[i]["symbol"],
      "name": bsctokensdecodedList[i]["name"],
      "address": bsctokensdecodedList[i]["address"],
      "decimals": bsctokensdecodedList[i]["decimals"],
      "logoURI": bsctokensdecodedList[i]["logoURI"]
    };
    bsctokenList.add(bsctoken);
  }
  bsctokenList.sort((a, b) => a["symbol"].compareTo(b["symbol"]));

  //fetch all tokens for polygon
  List<Map> polygontokenList = [];
  var polygonpromise = fetch1InchTokens("137");
  var polygontokens = await promiseToFuture(polygonpromise);
  var polygontokensdecoded = json.decode(polygontokens);
  var polygontokensdecodedList = polygontokensdecoded.values.toList();

  for (var i = 0; i < polygontokensdecodedList.length; i++) {
    Map polygontoken = {
      "symbol": polygontokensdecodedList[i]["symbol"],
      "name": polygontokensdecodedList[i]["name"],
      "address": polygontokensdecodedList[i]["address"],
      "decimals": polygontokensdecodedList[i]["decimals"],
      "logoURI": polygontokensdecodedList[i]["logoURI"]
    };
    polygontokenList.add(polygontoken);
  }
  polygontokenList.sort((a, b) => a["symbol"].compareTo(b["symbol"]));

  return [ethertokenList, bsctokenList, polygontokenList];
}

//get my Balances from Moralis
Future getBalances() async {
  var myBalances = [];
  var ethbalance = await getMyEthBalance();
  Map eth = {
    "name": "Ether",
    "symbol": "Eth",
    "balance": ethbalance,
    "decimals": "18",
    "chain": "Ethereumchain"
  };
  myBalances.add(eth);
  /*var bscbalance = await getMyBscBalance();
  Map bsc = {
    "name": "Binance Coin",
    "symbol": "BNB",
    "balance": bscbalance,
    "decimals": "18"
  };
  myBalances.add(bsc);*/
  var polygonbalance = await getMyPolygonBalance();
  Map polygon = {
    "name": "Polygon",
    "symbol": "matic",
    "balance": polygonbalance,
    "decimals": "18",
    "chain": "Polygonchain"
  };
  myBalances.add(polygon);
  //Eth Tokens
  var promise = getEthTokenBalances();
  var balance = await promiseToFuture(promise);
  for (var i = 0; i < balance.length; i++) {
    var myBalance = json.decode(balance[i]);
    myBalance["chain"] = "Ethereumchain";
    myBalances.add(myBalance);
  }
  //Polygon Tokens
  promise = getPolygonTokenBalances();
  balance = await promiseToFuture(promise);
  for (var i = 0; i < balance.length; i++) {
    var myBalance = json.decode(balance[i]);
    myBalance["chain"] = "Polygonchain";
    myBalances.add(myBalance);
  }
  /*for (var i = 0; i < myBalances.length; i++) {
    var coinGeckoId =
        coinGeckoTokens[myBalances[i]["symbol"].toLowerCase()]["id"];
    var response = await http.get(Uri.parse(
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=${coinGeckoId}&order=market_cap_desc&per_page=100&page=1&sparkline=false'));
    var jsonData = json.decode(response.body);
    var currentPrice = jsonData[0]["current_price"];
    currentPrice == null
        ? myBalances[i]["current_price"] = 0
        : myBalances[i]["current_price"] = jsonData[0]["current_price"];
  }*/
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
Future getMyPolygonBalance() async {
  var promise = getPolygonBalance();
  var polygonbalance = await promiseToFuture(promise);
  return polygonbalance;
}

//get my Transactions from Moralis
Future getAllMyTransactions() async {
  var promise = getMyTransactions();
  var transactions = await promiseToFuture(promise);
  var transactionsdecoded = json.decode(transactions);
  return transactionsdecoded;
}

//get all my Assests
Future getMyAssets() async {
  var tokens = await getBalances();
  //var nfts = await getMyNFTBalance();
  return ([tokens]); //, nfts]);
}
