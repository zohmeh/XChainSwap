@JS()
library blockchainlogic.js;

import 'dart:js';

import 'package:js/js.dart';

@JS()
external dynamic login();
external dynamic loggedIn();
external dynamic logout();
external dynamic setUserData(var _file, String _username);
external dynamic fetch1InchTokens(String _chain);
external dynamic getTokenPairRate(
    String fromToken, String toToken, String amount);
external dynamic storeJobData(String fromToken, String toToken, String amount,
    int fromchain, int tochain);
external dynamic getEthTokenBalances();
external dynamic getPolygonTokenBalances();
external dynamic getEthBalance();
external dynamic getBscBalance();
external dynamic getPolygonBalance();
external dynamic getMyEthTransactions();
external dynamic getMyPolygonTransactions();
external dynamic getSwaps();
external dynamic getQuote(
    String _fromToken, String _toToken, String _amount, String _chain);
external dynamic getTransactionStatus(String _txHash);
external dynamic networkCheck(int _networkId);
external dynamic doSwap(
    /*String _fromTokenAddress, String _toTokenAddress,
    String _amount, int _fromChain,*/
    String _jobId,
    int step);
external bridgingEth(String _jobId, String _newFromToken);
external bridgingMatic(String _jobId, String _newFromToken);
external checkEthCompleted(String _jobId);
external checkMaticCompleted(String _txHash);
external erc20Exit(String _txHash);
external checkForInclusion(String _txHash);
external getMyJobs();
external getJobById(String _jobId);
external deleteJobById(String _jobId);
