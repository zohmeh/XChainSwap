import 'dart:convert';
import 'dart:js_util';
import 'package:flutter/material.dart';
import '../widgets/javascript_controller.dart';
import 'package:queue/queue.dart';

class EthBlockchainInteraction with ChangeNotifier {
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

  Future swapTokens(List _arguments) async {
    String _fromTokenAddress = _arguments[0];
    String _toTokenAddress = _arguments[1];
    String _fromTokenAmount = _arguments[2];
    int _fromChain = _arguments[3];
    int _toChain = _arguments[4];
    String txHash = _arguments[5];
    String status = _arguments[6];
    String jobId = _arguments[7];
    List chain = [1, 56, 137];

    if (status == "new") {
      var promiseStoreJob = storeJobData(_fromTokenAddress, _toTokenAddress,
          _fromTokenAmount, _fromChain, _toChain);
      jobId = await promiseToFuture(promiseStoreJob);
    }

    //Casestudie for different swaps
    if (_fromChain == _toChain) {
      var promiseNetworkCheck = networkCheck(chain[_fromChain]);
      await promiseToFuture(promiseNetworkCheck);
      var promiseSwap = doSwap(_fromTokenAddress, _toTokenAddress,
          _fromTokenAmount, _fromChain, jobId);
      status = await promiseToFuture(promiseSwap);
      notifyListeners();
    } else {
      if (_fromChain == 0 && _toChain == 2) {
        //Check if the FromToken is ETH or Matic, beacause these will be bridged directly
        if (_fromTokenAddress == "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
          switch (status) {
            case "new":
              var promiseNetworkCheck = networkCheck(chain[_fromChain]);
              await promiseToFuture(promiseNetworkCheck);
              var promiseBridging =
                  bridgingEth(_fromTokenAmount, _fromChain, _toChain, jobId);
              status = await promiseToFuture(promiseBridging);
              notifyListeners();
              continue checking;
            checking:
            case "ethbridged":
              var queue = Queue(delay: Duration(milliseconds: 500));
              status = await queue.add(() async => getStatus(jobId, "eth"));
              notifyListeners();
              continue swapping;
            swapping:
            case "ethcompleted":
              var _newFromTokenAddress =
                  "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619";
              //var promiseNetworkCheck2 = networkCheck(chain[_toChain]);
              //PolygonBlockchainInteraction().polygonSwap(_newFromTokenAddress, _toTokenAddress,
              //    _fromTokenAmount, _toChain);
              //print(promiseDoSwap);
              print("Do the swap" + jobId);
              status = "done";
              break;
          }
        } else if (_fromTokenAddress ==
            "0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0".toLowerCase()) {
          switch (status) {
            case "new":
              var promiseNetworkCheck = networkCheck(chain[_fromChain]);
              await promiseToFuture(promiseNetworkCheck);
              var promiseBridging = bridgingMatic(_fromTokenAmount, jobId);
              status = await promiseToFuture(promiseBridging);
              notifyListeners();
              continue checking;
            checking:
            case "maticbridged":
              var queue = Queue(delay: Duration(milliseconds: 500));
              status = await queue.add(() async => getStatus(jobId, "matic"));
              notifyListeners();
              continue swapping;
            swapping:
            case "maticcompleted":
              var _newFromTokenAddress =
                  "0x0000000000000000000000000000000000001010";
              //var promiseNetworkCheck2 = networkCheck(chain[_toChain]);
              //PolygonBlockchainInteraction().polygonSwap(_newFromTokenAddress, _toTokenAddress,
              //    _fromTokenAmount, _toChain);
              //print(promiseDoSwap);
              print("Do the swap" + jobId);
              status = "done";
          }
        }
        //all other FromTokens will first be swapped into Eth on Eth and then bridged to Polygon and again swapped into the final Token on Polygon
        else {
          switch (status) {
            case "new":
              var promiseNetworkCheck = networkCheck(chain[_fromChain]);
              await promiseToFuture(promiseNetworkCheck);
              //getting the swapped amount in eth
              //Swapping Token to ETH on Eth
              var _ethBridgingAmount = "";
              var promiseBridging =
                  bridgingEth(_ethBridgingAmount, _fromChain, _toChain, jobId);
              status = await promiseToFuture(promiseBridging);
              notifyListeners();
              continue checking;
            checking:
            case "ethbridged":
              var queue = Queue(delay: Duration(milliseconds: 500));
              status = await queue.add(() async => getStatus(jobId, "eth"));
              notifyListeners();
              continue swapping;
            swapping:
            case "ethcompleted":
              var _newFromTokenAddress =
                  "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619";
              //var promiseNetworkCheck2 = networkCheck(chain[_toChain]);
              //PolygonBlockchainInteraction().polygonSwap(_newFromTokenAddress, _toTokenAddress,
              //    _fromTokenAmount, _toChain);
              //print(promiseDoSwap);
              print("Do the swap" + jobId);
              status = "done";
              break;
          }
        }
      } else if (_fromChain == 2 && _toChain == 0) {
        //Check if FromToken is WETH this will be bridged directly
        if (_fromTokenAddress ==
            "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619".toLowerCase()) {
          switch (status) {
            case "new":
              var promiseNetworkCheck = networkCheck(chain[_fromChain]);
              await promiseToFuture(promiseNetworkCheck);
              status = await PolygonBlockchainInteraction().polygonBridging(
                  _fromTokenAmount, _fromChain, _toChain, jobId);
              continue checking;
            checking:
            case "ethbridged":
              var queue = Queue(delay: Duration(milliseconds: 500));
              status =
                  await queue.add(() async => getStatus(jobId, "erc20Eth"));
              break;
          }
        } else {
          switch (status) {
            case "new":
              var promiseNetworkCheck = networkCheck(chain[_fromChain]);
              await promiseToFuture(promiseNetworkCheck);
              //var promiseDoSwap = doSwap(_fromTokenAddress, "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619".toLowerCase(),
              //    _fromTokenAmount, _fromChain);
              //print(promiseDoSwap);
              //getting the swapped amount in
              //PolygonBlockchainInteraction().polygonSwap(_fromTokenAddress, "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619".toLowerCase(),
              //   _fromTokenAmount, _fromChain)
              var _ethBridgingAmount = "";
              //var promiseBridging =
              //    bridgingEth(_ethBridgingAmount, _fromChain, _toChain, jobId);
              //status = await promiseToFuture(promiseBridging);
              //notifyListeners();
              PolygonBlockchainInteraction().polygonBridging(
                  _fromTokenAmount, _fromChain, _toChain, jobId);
              continue checking;
            checking:
            case "ethbridged":
              var queue = Queue(delay: Duration(milliseconds: 500));
              status =
                  await queue.add(() async => getStatus(jobId, "erc20Eth"));
              notifyListeners();
              break;
          }
        }
      }
    }
  }

  Future openActivity(List _arguments) async {
    String _jobId = _arguments[0];
    List chain = [5, 5, 80001];
    //get the job by id
    var promiseJob = getJobById(_jobId);
    var job = await promiseToFuture(promiseJob);
    var jobdecoded = json.decode(job);

    var promiseNetworkCheck2 = networkCheck(chain[jobdecoded["toChain"]]);
    await promiseToFuture(promiseNetworkCheck2);
    var promiseERC20Exit = erc20Exit(_jobId);
    await promiseToFuture(promiseERC20Exit);
    //statusEth = status;
    notifyListeners();
    var _newFromTokenAddress = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";
    //var promiseDoSwap = doSwap(_newfromTokenAddress, _toTokenAddress,
    //    _fromTokenAmount, _toChain);
    //print(promiseDoSwap);
    print("Do the swap" + _jobId);
  }
}

class PolygonBlockchainInteraction with ChangeNotifier {
  Future polygonSwap(
      _fromTokenAddress, _toTokenAddress, _amount, _chain, _jobId) async {
    var promiseDoSwap =
        doSwap(_fromTokenAddress, _toTokenAddress, _amount, _chain, _jobId);
    await promiseToFuture(promiseDoSwap);
    notifyListeners();
  }

  Future<String> polygonBridging(
      _fromTokenAmount, _fromChain, _toChain, _jobId) async {
    String status;
    var promiseBridging =
        bridgingEth(_fromTokenAmount, _fromChain, _toChain, _jobId);
    status = await promiseToFuture(promiseBridging);
    notifyListeners();
    return status;
  }

  Future<String> polygonChecking(_jobId) async {
    String status;
    var promiseCheckInclusion = checkForInclusion(_jobId);
    status = await promiseToFuture(promiseCheckInclusion);
    notifyListeners();
    return status;
  }
}
