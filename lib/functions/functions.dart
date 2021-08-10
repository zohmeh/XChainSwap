import 'dart:convert';
import 'dart:js_util';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:web_app_template/helpers/coinGeckoTokenList.dart';
import 'package:web_app_template/helpers/mappedTokens.dart';
import 'package:web_app_template/provider/blockchainprovider.dart';
import 'package:web_app_template/provider/loginprovider.dart';
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
          [_fromTokenAddress, _toTokenAddress, _fromAmount, chain[_toChain]]);

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
          [_fromTokenAddress, _toTokenAddress, _fromAmount, chain[_toChain]]);
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
    final results = await Future.wait([
      http.get(Uri.parse("https://api.1inch.exchange/v3.0/1/tokens")),
      http.get(Uri.parse("https://api.1inch.exchange/v3.0/137/tokens")),
    ]);
    var ethertokensdecoded = json.decode(results[0].body);
    List<dynamic> ethertokensdecodedList =
        ethertokensdecoded["tokens"].values.toList();
    ethertokensdecodedList.sort((a, b) => a["symbol"].compareTo(b["symbol"]));
    List eth =
        ethertokensdecodedList.map((e) => e as Map<dynamic, dynamic>)?.toList();

    var polygontokensdecoded = json.decode(results[1].body);
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
  var promiseBalance = getMyBalances();

  try {
    final results = await promiseToFuture(promiseBalance);
    for (var i in results) {
      var balance = json.decode(i);
      myBalances.add(balance);
    }
    return myBalances;
  } catch (error) {
    print(error);
  }
}

Future getAllMyEthTransactions() async {
  var transactions = [];
  var promise = getMyEthTransactions();
  var response = await promiseToFuture(promise);
  for (var i in response) {
    var transaction = json.decode(i);
    transactions.add(transaction);
  }
  return transactions;
}

Future getAllMyPolygonTransactions() async {
  var transactions = [];
  var promise = getMyPolygonTransactions();
  var response = await promiseToFuture(promise);
  for (var i in response) {
    var transaction = json.decode(i);
    transactions.add(transaction);
  }
  return transactions;
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

Future checkforloggedIn() async {
  var promise = loggedIn();
  var loggedin = await promiseToFuture(promise);
  var user = loggedin;
  return user;
}
