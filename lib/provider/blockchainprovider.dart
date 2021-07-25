import 'dart:convert';
import 'dart:js_util';
import 'package:flutter/material.dart';
import '../../functions/functions.dart';
import '../widgets/javascript_controller.dart';
import 'package:queue/queue.dart';

class EthBlockchainInteraction with ChangeNotifier {
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
      await checkNetwork(chain[_fromChain]);
      List values = await swap(_fromTokenAddress, _toTokenAddress,
          _fromTokenAmount, _fromChain, jobId);
      status = values[0];
      await deleteJob(jobId);
      notifyListeners();
    } else {
      if (_fromChain == 0 && _toChain == 2) {
        //Check if the FromToken is ETH or Matic, beacause these will be bridged directly
        if (_fromTokenAddress == "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
          switch (status) {
            case "new":
              await checkNetwork(chain[_fromChain]);
              status = await ethBridging(
                  _fromTokenAmount, _fromChain, _toChain, jobId);
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
              List values = await PolygonBlockchainInteraction().polygonSwap(
                  _newFromTokenAddress,
                  _toTokenAddress,
                  _fromTokenAmount,
                  _toChain,
                  jobId);
              status = values[0];
              await deleteJob(jobId);
              break;
          }
        } else if (_fromTokenAddress ==
            "0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0".toLowerCase()) {
          switch (status) {
            case "new":
              await checkNetwork(chain[_fromChain]);
              status = await maticBridging(_fromTokenAmount, jobId);
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
                  "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"; //"0x0000000000000000000000000000000000001010";
              List values = await PolygonBlockchainInteraction().polygonSwap(
                  _newFromTokenAddress,
                  _toTokenAddress,
                  _fromTokenAmount,
                  _toChain,
                  jobId);
              status = values[0];
              await deleteJob(jobId);
              break;
          }
        }
        //all other FromTokens will first be swapped into Eth on Eth and then bridged to Polygon and again swapped into the final Token on Polygon
        else {
          switch (status) {
            case "new":
              await checkNetwork(chain[_fromChain]);
              //Swapping Token to ETH on Eth
              List values = await swap(
                  _fromTokenAddress,
                  "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
                  _fromTokenAmount,
                  _fromChain,
                  jobId);
              status = values[0];
              var _ethBridgingAmount = values[1].toString();
              status = await ethBridging(
                  _ethBridgingAmount, _fromChain, _toChain, jobId);
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
              await checkNetwork(chain[_toChain]);
              List values = await PolygonBlockchainInteraction().polygonSwap(
                  _newFromTokenAddress,
                  _toTokenAddress,
                  _fromTokenAmount,
                  _toChain,
                  jobId);
              status = values[0];
              await deleteJob(jobId);
              break;
          }
        }
      } else if (_fromChain == 2 && _toChain == 0) {
        //Check if FromToken is WETH this will be bridged directly
        if (_fromTokenAddress ==
            "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619".toLowerCase()) {
          switch (status) {
            case "new":
              await checkNetwork(chain[_fromChain]);
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
              await checkNetwork(chain[_fromChain]);
              List values = await PolygonBlockchainInteraction().polygonSwap(
                  _fromTokenAddress,
                  "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619".toLowerCase(),
                  _fromTokenAmount,
                  _fromChain,
                  jobId);
              var _ethBridgingAmount = values[1].toString();
              status = await PolygonBlockchainInteraction().polygonBridging(
                  _ethBridgingAmount, _fromChain, _toChain, jobId);
              continue checking;
            checking:
            case "ethbridged":
              var queue = Queue(delay: Duration(milliseconds: 500));
              status =
                  await queue.add(() async => getStatus(jobId, "erc20Eth"));
              break;
          }
        }
      }
    }
  }

  Future openActivity(List _arguments) async {
    String _jobId = _arguments[0];
    List chain = [1, 56, 137];
    String status;
    //get the job by id
    var promiseJob = getJobById(_jobId);
    var job = await promiseToFuture(promiseJob);
    var jobdecoded = json.decode(job);

    await checkNetwork(chain[jobdecoded["toChain"]]);
    var promiseERC20Exit = erc20Exit(_jobId);
    status = await promiseToFuture(promiseERC20Exit);
    notifyListeners();
    var _newFromTokenAddress = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";
    List values = await swap(_newFromTokenAddress, jobdecoded["toTokenAddress"],
        jobdecoded["amount"], jobdecoded["toChain"], jobdecoded["objectId"]);
    status = values[0];
    await deleteJob(_jobId);
    notifyListeners();
  }
}

class PolygonBlockchainInteraction with ChangeNotifier {
  Future<List> polygonSwap(
      _fromTokenAddress, _toTokenAddress, _amount, _chain, _jobId) async {
    List chain = [1, 56, 137];
    await checkNetwork(chain[_chain]);
    List values =
        await swap(_fromTokenAddress, _toTokenAddress, _amount, _chain, _jobId);
    notifyListeners();
    return values;
  }

  Future<String> polygonBridging(
      _fromTokenAmount, _fromChain, _toChain, _jobId) async {
    String status;
    status = await ethBridging(_fromTokenAmount, _fromChain, _toChain, _jobId);
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
