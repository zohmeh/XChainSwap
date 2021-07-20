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
    var promiseStatus = getTransactionStatus(_txHash.toString());
    var status = await promiseToFuture(promiseStatus);
    return status;
  }

  Future swapTokens(List _arguments) async {
    String _fromTokenAddress = _arguments[0];
    String _toTokenAddress = _arguments[1];
    String _fromTokenAmount = _arguments[2];
    int _fromChain = _arguments[3];
    int _toChain = _arguments[4];

    var _fromAmount = BigInt.from(double.parse(_fromTokenAmount));

    var promiseStoreJob = storeJobData(_fromTokenAddress, _toTokenAddress,
        _fromAmount.toString(), _fromChain, _toChain);
    var jobId = await promiseToFuture(promiseStoreJob);

    var chain = [5, 5, 80001];

    //Casestudie for different swaps
    if (_fromChain == _toChain) {
      var promiseNetworkCheck = networkCheck(chain[_fromChain]);
      await promiseToFuture(promiseNetworkCheck);
      //var promiseDoSwap = doSwap(_fromTokenAddress, _toTokenAddress,
      //    _fromAmount.toString(), _fromChain);
      //print(promiseDoSwap);
      print("Do the swap");
    } else {
      if (_fromChain == 0 && _toChain == 2) {
        //Check if the FromToken is ETH or Matic, beacause these will be bridged directly
        if (_fromTokenAddress == "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
          var promiseNetworkCheck = networkCheck(chain[_fromChain]);
          await promiseToFuture(promiseNetworkCheck);
          var promiseBridging =
              bridgingEth(_fromAmount.toString(), _fromChain, _toChain);
          txHash = await promiseToFuture(promiseBridging);
          notifyListeners();
          var promiseCheckEthCompleted = checkEthCompleted(txHash);
          status = await promiseToFuture(promiseCheckEthCompleted);
          notifyListeners();
          var _newFromTokenAddress =
              "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619";
          //var promiseNetworkCheck2 = networkCheck(chain[_toChain]);
          //await promiseToFuture(promiseNetworkCheck2);
          //var promiseDoSwap = doSwap(_newfromTokenAddress, _toTokenAddress,
          //    _fromAmount.toString(), _toChain);
          //print(promiseDoSwap);
          print("Do the swap");
        } else if (_fromTokenAddress ==
            "0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0".toLowerCase()) {
          var promiseNetworkCheck = networkCheck(chain[_fromChain]);
          await promiseToFuture(promiseNetworkCheck);
          var promiseBridging = bridgingMatic(_fromAmount.toString());
          txHash = await promiseToFuture(promiseBridging);
          notifyListeners();
          var promiseCheckMaticCompleted = checkMaticCompleted(txHash);
          status = await promiseToFuture(promiseCheckMaticCompleted);
          notifyListeners();
          var _newFromTokenAddress =
              "0x0000000000000000000000000000000000001010";
          //var promiseNetworkCheck2 = networkCheck(chain[_toChain]);
          //await promiseToFuture(promiseNetworkCheck2);
          //var promiseDoSwap = doSwap(_newfromTokenAddress, _toTokenAddress,
          //    _fromAmount.toString(), _toChain);
          //print(promiseDoSwap);
          print("Do the swap");
        }
        //all other FromTokens will first be swapped into Eth on Eth and then bridged to Polygon and again swapped into the final Token on Polygon
        else {
          var promiseNetworkCheck = networkCheck(chain[_fromChain]);
          await promiseToFuture(promiseNetworkCheck);
          //getting the swapped amount in eth
          var _ethBridgingAmount = "";
          var promiseBridging =
              bridgingEth(_ethBridgingAmount, _fromChain, _toChain);
          txHash = await promiseToFuture(promiseBridging);
          notifyListeners();
          var promiseCheckEthCompleted = checkEthCompleted(txHash);
          status = await promiseToFuture(promiseCheckEthCompleted);
          notifyListeners();
          var _newFromTokenAddress =
              "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619";
          var promiseNetworkCheck2 = networkCheck(chain[_toChain]);
          await promiseToFuture(promiseNetworkCheck2);
          //var promiseDoSwap = doSwap(_newfromTokenAddress, _toTokenAddress,
          //    _ethBridgingAmount, _toChain);
          //print(promiseDoSwap);
          print("Do the swap");
        }
      } else if (_fromChain == 2 && _toChain == 0) {
        //Check if FromToken is WETH this will be bridged directly
        if (_fromTokenAddress ==
            "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619".toLowerCase()) {
          var promiseNetworkCheck = networkCheck(chain[_fromChain]);
          await promiseToFuture(promiseNetworkCheck);
          var promiseBridging =
              bridgingEth(_fromTokenAmount, _fromChain, _toChain);
          txHash = await promiseToFuture(promiseBridging);
          notifyListeners();
          var promiseCheckInclusion = checkForInclusion(txHash);
          status = await promiseToFuture(promiseCheckInclusion);
          notifyListeners();
          var promiseNetworkCheck2 = networkCheck(chain[_toChain]);
          await promiseToFuture(promiseNetworkCheck2);
          var promiseERC20Exit = erc20Exit(txHash);
          txHash = await promiseToFuture(promiseERC20Exit);
          notifyListeners();
          var _newFromTokenAddress =
              "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";
          //var promiseDoSwap = doSwap(_newfromTokenAddress, _toTokenAddress,
          //    _fromTokenAmount, _toChain);
          //print(promiseDoSwap);
          print("Do the swap");
        } else {
          var promiseNetworkCheck = networkCheck(chain[_fromChain]);
          await promiseToFuture(promiseNetworkCheck);
          //var promiseDoSwap = doSwap(_fromTokenAddress, "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619".toLowerCase(),
          //    _fromTokenAmount, _fromChain);
          //print(promiseDoSwap);
          //getting the swapped amount in
          var _ethBridgingAmount = "";
          var promiseBridging =
              bridgingEth(_ethBridgingAmount, _fromChain, _toChain);
          txHash = await promiseToFuture(promiseBridging);
          notifyListeners();
          var promiseCheckInclusion = checkForInclusion(txHash);
          status = await promiseToFuture(promiseCheckInclusion);
          notifyListeners();
          var promiseNetworkCheck2 = networkCheck(chain[_toChain]);
          await promiseToFuture(promiseNetworkCheck2);
          var promiseERC20Exit = erc20Exit(txHash);
          txHash = await promiseToFuture(promiseERC20Exit);
          notifyListeners();
          var _newFromTokenAddress =
              "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";
          //var promiseDoSwap = doSwap(_newfromTokenAddress, _toTokenAddress,
          //    _fromTokenAmount, _toChain);
          //print(promiseDoSwap);
          print("Do the swap");
        }
      }
    }

    //var queue = Queue(delay: Duration(milliseconds: 500));
    //var _status = await queue.add(() => getStatus(swapping));
    //status = _status;
    //notifyListeners();
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
    "chain": "Ethereum"
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
  var promise = getMyPolygonTransactions();
  var transactions = await promiseToFuture(promise);
  var transactionsdecoded = json.decode(transactions);
  return transactionsdecoded;
}
