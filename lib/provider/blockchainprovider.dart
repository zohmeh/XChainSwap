import 'dart:convert';
import 'dart:js_util';
import 'package:flutter/material.dart';
import '../../helpers/mappedTokens.dart';
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
    //String txHash = _arguments[5];
    String status = _arguments[6];
    String jobId = _arguments[7];
    String _slippage = _arguments[8];
    List chain = [1, 56, 137];

    if (status == "new") {
      var promiseStoreJob = storeJobData(_fromTokenAddress, _toTokenAddress,
          _fromTokenAmount, _fromChain, _toChain, _slippage);
      jobId = await promiseToFuture(promiseStoreJob);
    }

    //Casestudie for different swaps
    if (_fromChain == _toChain) {
      await checkNetwork(chain[_fromChain]);
      List values = await swap(jobId, 0);
      status = values[0];
      await deleteJob(jobId);
      notifyListeners();
    } else {
      if (_fromChain == 0 && _toChain == 2) {
        //Check if fromToken is contained in PoS List for direct bridging
        if (mappedPoSTokensEth.contains(_fromTokenAddress)) {
          var index = mappedPoSTokensEth.indexOf(_fromTokenAddress);
          switch (status) {
            case "new":
              await checkNetwork(chain[_fromChain]);
              status = await ethBridging(jobId, mappedPoSTokensPolygon[index]);
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
              //    if (_toTokenAddress != mappedPoSTokensPolygon[index]) {
              await checkNetwork(chain[_toChain]);
              List values =
                  await PolygonBlockchainInteraction().doSwap([jobId, 0]);
              status = values[0];
              await deleteJob(jobId);
              break;
          }
        }
      }
      //Check if fromToken is Matic for direct bridging
      else if (_fromTokenAddress ==
          "0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0".toLowerCase()) {
        switch (status) {
          case "new":
            await checkNetwork(chain[_fromChain]);
            status = await maticBridging(
                jobId, "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
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
            await checkNetwork(chain[_toChain]);
            List values =
                await PolygonBlockchainInteraction().doSwap([jobId, 0]);
            status = values[0];
            await deleteJob(jobId);
            break;
        }
      }
      //all other fromTokens will first be swapped into Eth on Eth and then bridged to Polygon and again swapped into the final Token on Polygon
      else {
        switch (status) {
          case "new":
            await checkNetwork(chain[_fromChain]);
            //Swapping Token to ETH on Eth
            List values = await swap(jobId, 1);
            status = values[0];
            notifyListeners();
            continue swap;
          swap:
          case "swapped":
            status = await ethBridging(jobId,
                "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619".toLowerCase());
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
            await checkNetwork(chain[_toChain]);
            List values =
                await PolygonBlockchainInteraction().doSwap([jobId, 0]);
            status = values[0];
            await deleteJob(jobId);
            break;
        }
      }
    }
  }

  Future openActivity(List _arguments) async {
    String _jobId = _arguments[0];
    List chain = [1, 56, 137];
    String status;

    var promiseJob = getJobById(_jobId);
    var job = await promiseToFuture(promiseJob);
    var jobdecoded = json.decode(job);

    await checkNetwork(chain[jobdecoded["toChain"]]);
    var promiseERC20Exit = erc20Exit(_jobId);
    status = await promiseToFuture(promiseERC20Exit);
    notifyListeners();
    List values = await swap(_jobId, 0);
    status = values[0];
    await deleteJob(_jobId);
    notifyListeners();
  }
}

class PolygonBlockchainInteraction with ChangeNotifier {
  Future doSwap(List _arguments) async {
    String jobId = _arguments[0];
    int step = _arguments[1];
    String status;

    List values = await swap(jobId, step);
    status = values[0];
    notifyListeners();
    return values;
  }

  Future swapTokens(List _arguments) async {
    String _fromTokenAddress = _arguments[0];
    String _toTokenAddress = _arguments[1];
    String _fromTokenAmount = _arguments[2];
    int _fromChain = _arguments[3];
    int _toChain = _arguments[4];
    //String txHash = _arguments[5];
    String status = _arguments[6];
    String jobId = _arguments[7];
    String _slippage = _arguments[8];
    List chain = [1, 56, 137];
    List values;

    if (status == "new") {
      var promiseStoreJob = storeJobData(_fromTokenAddress, _toTokenAddress,
          _fromTokenAmount, _fromChain, _toChain, _slippage);
      jobId = await promiseToFuture(promiseStoreJob);
    }

    //Casestudie for different swaps
    if (_fromChain == _toChain) {
      await checkNetwork(chain[_fromChain]);
      List values = await swap(jobId, 0);
      status = values[0];
      await deleteJob(jobId);
      notifyListeners();
    } else if (_fromChain == 2 && _toChain == 0) {
      //Check if FromToken is WETH this will be bridged directly
      if (mappedPoSTokensPolygon.contains(_fromTokenAddress)) {
        var index = mappedPoSTokensPolygon.indexOf(_fromTokenAddress);
        switch (status) {
          case "new":
            await checkNetwork(chain[_fromChain]);
            status = await ethBridging(jobId, mappedPoSTokensEth[index]);
            notifyListeners();
            continue checking;
          checking:
          case "ethbridged":
            var queue = Queue(delay: Duration(milliseconds: 500));
            status = await queue.add(() async => getStatus(jobId, "erc20Eth"));
            notifyListeners();
            break;
        }
      } else {
        switch (status) {
          case "new":
            await checkNetwork(chain[_fromChain]);
            values = await swap(jobId, 2);
            status = values[0];
            notifyListeners();
            continue swap;
          swap:
          case "swapped":
            status = await ethBridging(jobId,
                "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE".toLowerCase());
            notifyListeners();
            continue checking;
          checking:
          case "ethbridged":
            var queue = Queue(delay: Duration(milliseconds: 500));
            status = await queue.add(() async => getStatus(jobId, "erc20Eth"));
            notifyListeners();
            break;
        }
      }
    }
  }
}
