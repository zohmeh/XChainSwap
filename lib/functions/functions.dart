import 'dart:convert';
import 'dart:js_util';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:web_app_template/helpers/coinGeckoTokenList.dart';
import 'package:web_app_template/helpers/mappedTokens.dart';
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
    var status = await polygonChecking(_jobId);
    return status;
  } else {
    return "error";
  }
}

Future getQuote(List _arguments) async {
  var _fromTokenAddress = _arguments[0];
  var _toTokenAddress = _arguments[1];
  var _amount = _arguments[2];
  var _chain = _arguments[3];

  try {
    var url = Uri.parse(
        "https://api.1inch.exchange/v3.0/${_chain}/quote?fromTokenAddress=${_fromTokenAddress}&toTokenAddress=${_toTokenAddress}&amount=${_amount}");
    var response = await http.get(url);
    var quote = json.decode(response.body);
    return quote;
  } catch (error) {
    print(error);
  }
}

Future<String> getExpectedReturn(List _arguments) async {
  String _fromTokenAddress = _arguments[0];
  String _toTokenAddress = _arguments[1];
  String _fromAmount = _arguments[2];
  int _fromChain = _arguments[3];
  int _toChain = _arguments[4];
  List chain = ["1", "56", "137"];
  String expectedReturn;

  if (_fromChain == _toChain) {
    var quote = await getQuote(
        [_fromTokenAddress, _toTokenAddress, _fromAmount, chain[_fromChain]]);
    expectedReturn = (int.parse(quote["toTokenAmount"]) /
            pow(10, quote["toToken"]["decimals"]))
        .toString();
  } else if (_fromChain == 0 && _toChain == 2) {
    if (mappedPoSTokensEth.contains(_fromTokenAddress)) {
      var index = mappedPoSTokensEth.indexOf(_fromTokenAddress);
      _fromTokenAddress = mappedPoSTokensPolygon[index];
      var quote = await getQuote(
          [_fromTokenAddress, _toTokenAddress, _fromAmount, chain[_fromChain]]);

      expectedReturn = (int.parse(quote["toTokenAmount"]) /
              pow(10, quote["toToken"]["decimals"]))
          .toString();
    } else {
      //getting the amount of eth
      var quote = await getQuote(
          [_fromTokenAddress, _toTokenAddress, _fromAmount, chain[_fromChain]]);
      var ethAmount = quote["toTokenAmount"];

      //with new eth amount quote on toChain
      quote = await getQuote(
          [_fromTokenAddress, _toTokenAddress, ethAmount, chain[_fromChain]]);
      expectedReturn = (int.parse(quote["toTokenAmount"]) /
              pow(10, quote["toToken"]["decimals"]))
          .toString();
    }
  } else if (_fromChain == 2 && _toChain == 0) {
    if (mappedPoSTokensPolygon.contains(_fromTokenAddress)) {
      var index = mappedPoSTokensPolygon.indexOf(_fromTokenAddress);
      _fromTokenAddress = mappedPoSTokensEth[index];
      var quote = await getQuote(
          [_fromTokenAddress, _toTokenAddress, _fromAmount, chain[_fromChain]]);
      expectedReturn = (int.parse(quote["toTokenAmount"]) /
              pow(10, quote["toToken"]["decimals"]))
          .toString();
    } else {
      //getting the amount of eth
      var quote = await getQuote(
          [_fromTokenAddress, _toTokenAddress, _fromAmount, chain[_fromChain]]);
      var ethAmount = quote["toTokenAmount"];

      //with new eth amount quote on toChain
      quote = await getQuote(
          [_fromTokenAddress, _toTokenAddress, ethAmount, chain[_fromChain]]);
      expectedReturn = (int.parse(quote["toTokenAmount"]) /
              pow(10, quote["toToken"]["decimals"]))
          .toString();
    }
  }

  return expectedReturn;
}

Future fetchTokens() async {
  try {
    var url = Uri.parse("https://api.1inch.exchange/v3.0/1/tokens");
    var response = await http.get(url);
    var ethertokensdecoded = json.decode(response.body);
    List<dynamic> ethertokensdecodedList =
        ethertokensdecoded["tokens"].values.toList();
    ethertokensdecodedList.sort((a, b) => a["symbol"].compareTo(b["symbol"]));
    List eth =
        ethertokensdecodedList.map((e) => e as Map<dynamic, dynamic>)?.toList();

    url = Uri.parse("https://api.1inch.exchange/v3.0/137/tokens");
    response = await http.get(url);
    var polygontokensdecoded = json.decode(response.body);
    List<dynamic> polygontokensdecodedList =
        polygontokensdecoded["tokens"].values.toList();
    polygontokensdecodedList.sort((a, b) => a["symbol"].compareTo(b["symbol"]));
    List poly = polygontokensdecodedList
        .map((e) => e as Map<dynamic, dynamic>)
        ?.toList();

    return [eth, [], poly];
  } catch (error) {
    print(error);
  }
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
    "name": "Matic",
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
    //coinGecko for price
    var response = await http.get(Uri.parse(
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=${coinGeckoId}&order=market_cap_desc&per_page=100&page=1&sparkline=false'));
    var jsonData = json.decode(response.body);
    var currentPrice = jsonData[0]["current_price"];
    currentPrice == null
        ? myBalances[i]["current_price"] = 0
        : myBalances[i]["current_price"] = currentPrice;
    //coinGecko for image
    var responseImage = await http.get(
        Uri.parse('https://api.coingecko.com/api/v3/coins/${coinGeckoId}'));
    var jsonDataImage = json.decode(responseImage.body);
    myBalances[i]["image"] = jsonDataImage["image"]["thumb"];
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

    if (jobsdecoded[i]["fromChain"] == jobsdecoded[i]["toChain"]) {
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
    } else if (jobsdecoded[i]["fromChain"] == 0 &&
        jobsdecoded[i]["toChain"] == 2) {
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
    } else if (jobsdecoded[i]["fromChain"] == 2 &&
        jobsdecoded[i]["toChain"] == 0) {
      await queue.add(() => PolygonBlockchainInteraction().swapTokens([
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
  }
  return jobsdecoded;
}

Future deleteJob(_jobId) async {
  var promise = deleteJobById(_jobId);
  await promiseToFuture(promise);
}

Future<List> swap(jobId, step) async {
  var promiseSwap = doSwap(jobId, step);
  return await promiseToFuture(promiseSwap);
}

Future checkNetwork(_chain) async {
  var promiseNetworkCheck = networkCheck(_chain);
  await promiseToFuture(promiseNetworkCheck);
}

Future<String> ethBridging(jobId, _newFromToken) async {
  var promiseBridging = bridgingEth(jobId, _newFromToken);
  return await promiseToFuture(promiseBridging);
}

Future<String> maticBridging(jobId, _newFromToken) async {
  var promiseBridging = bridgingMatic(jobId, _newFromToken);
  return await promiseToFuture(promiseBridging);
}

Future<String> polygonChecking(_jobId) async {
  String status;
  var promiseCheckInclusion = checkForInclusion(_jobId);
  status = await promiseToFuture(promiseCheckInclusion);
  return status;
}

Future getJobWithId(_jobId) async {
  var promiseJob = getJobById(_jobId);
  var job = await promiseToFuture(promiseJob);
  var jobdecoded = json.decode(job);
  return jobdecoded;
}

Future loadAtStart() async {
  var balances = await getBalances();
  var tokens = await fetchTokens();
  var ethTransactions = await getAllMyEthTransactions();
  var polygonTransactions = await getAllMyPolygonTransactions();
  return [balances, tokens, ethTransactions, polygonTransactions];
}
