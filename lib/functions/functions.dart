import 'dart:convert';
import 'dart:js_util';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:web_app_template/helpers/coinGeckoTokenList.dart';
import 'package:web_app_template/provider/blockchainprovider.dart';
import '../../helpers/coinGeckoTokenList.dart';
import '../widgets/javascript_controller.dart';
import 'package:http/http.dart' as http;
import 'package:queue/queue.dart';

Future<String> getStatus(String _jobId, String _token) async {
  if (_token == "eth") {
    var promiseCheckEthCompleted = checkEthCompleted(_jobId);
    var status = await promiseToFuture(promiseCheckEthCompleted);
    return status;
  }
  if (_token == "matic") {
    var promiseCheckMaticCompleted = checkMaticCompleted(_jobId);
    var status = await promiseToFuture(promiseCheckMaticCompleted);
    return status;
  }
  if (_token == "erc20Eth") {
    var status = await PolygonBlockchainInteraction().polygonChecking(_jobId);
    return status;
  } else {
    return "error";
  }
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
    "chain": "Ethereum"
  };
  myBalances.add(eth);

  var polygonbalance = await getMyPolygonBalance();
  Map polygon = {
    "name": "Polygon",
    "symbol": "matic",
    "balance": polygonbalance,
    "decimals": "18",
    "chain": "Polygon"
  };
  myBalances.add(polygon);
  //Eth Tokens
  var promise = getEthTokenBalances();
  var balance = await promiseToFuture(promise);
  for (var i = 0; i < balance.length; i++) {
    var myBalance = json.decode(balance[i]);
    myBalance["chain"] = "Ethereum";
    myBalances.add(myBalance);
  }
  //Polygon Tokens
  promise = getPolygonTokenBalances();
  balance = await promiseToFuture(promise);
  for (var i = 0; i < balance.length; i++) {
    var myBalance = json.decode(balance[i]);
    myBalance["chain"] = "Polygon";
    myBalances.add(myBalance);
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
        : myBalances[i]["current_price"] = currentPrice;
  }
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

//get all my Assests
Future getMyAssets() async {
  var tokens = await getBalances();
  //var nfts = await getMyNFTBalance();
  return ([tokens]); //, nfts]);
}

Future getAllMyEthTransactions() async {
  var promise = getMyEthTransactions();
  var transactions = await promiseToFuture(promise);
  var transactionsdecoded = json.decode(transactions);
  return transactionsdecoded;
}

Future getAllMyPolygonTransactions() async {
  //get all my transactions on polygon
  var promise = getMyPolygonTransactions();
  var transactions = await promiseToFuture(promise);
  var transactionsdecoded = json.decode(transactions);

  //get all my open jobs
  var promiseJobs = getMyJobs();
  var jobs = await promiseToFuture(promiseJobs);
  var jobsdecoded = json.decode(jobs);

  for (var i = 0; i < transactionsdecoded.length; i++) {
    for (var j = 0; j < jobsdecoded.length; j++) {
      if (transactionsdecoded[i]["hash"] == jobsdecoded[j]["txHash"] &&
          jobsdecoded[j]["status"] == "erc20Ethcompleted") {
        transactionsdecoded[i]["openJob"] = jobsdecoded[j]["objectId"];
      }
    }
  }
  return transactionsdecoded;
}

Future getAllMyJobs() async {
  var promise = getMyJobs();
  var jobs = await promiseToFuture(promise);
  var jobsdecoded = json.decode(jobs);

  for (int i = 0; i < jobsdecoded.length; i++) {
    var queue = Queue(delay: Duration(milliseconds: 500));
    await queue.add(() => EthBlockchainInteraction().swapTokens([
          jobsdecoded[i]["fromTokenAddress"],
          jobsdecoded[i]["toTokenAddress"],
          jobsdecoded[i]["amount"],
          jobsdecoded[i]["fromChain"],
          jobsdecoded[i]["toChain"],
          jobsdecoded[i]["txHash"],
          jobsdecoded[i]["status"],
          jobsdecoded[i]["objectId"]
        ]));
  }
  return jobsdecoded;
}

Future deleteJob(_jobId) async {
  var promise = deleteJobById(_jobId);
  await promiseToFuture(promise);
}

Future<List> swap(_fromTokenAddress, _toTokenAddress, _fromTokenAmount,
    _fromChain, jobId) async {
  var promiseSwap = doSwap(
      _fromTokenAddress, _toTokenAddress, _fromTokenAmount, _fromChain, jobId);
  return await promiseToFuture(promiseSwap);
}

Future checkNetwork(_chain) async {
  var promiseNetworkCheck = networkCheck(_chain);
  await promiseToFuture(promiseNetworkCheck);
}

Future<String> ethBridging(
    _fromTokenAmount, _fromChain, _toChain, jobId) async {
  var promiseBridging =
      bridgingEth(_fromTokenAmount, _fromChain, _toChain, jobId);
  return await promiseToFuture(promiseBridging);
}

Future<String> maticBridging(_fromTokenAmount, jobId) async {
  var promiseBridging = bridgingMatic(_fromTokenAmount, jobId);
  return await promiseToFuture(promiseBridging);
}
