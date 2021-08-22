@JS()
library blockchainlogic.js;

import 'package:js/js.dart';

@JS()
external dynamic login();
external dynamic loggedIn();
external dynamic logout();
external dynamic setUserData(var _file, String _username);
external dynamic getTokenPairRate(
    String fromToken, String toToken, String amount);
external dynamic storeJobData(String fromToken, String toToken, String amount,
    int fromchain, int tochain, String slippage);
external dynamic getMyBalances();
external dynamic getMyEthTransactions();
external dynamic getMyPolygonTransactions();
external dynamic getSwaps();
external dynamic getTransactionStatus(String _txHash);
external dynamic networkCheck(int _networkId);
external dynamic doSwap(String _jobId, int step);
external bridgingEth(String _jobId, String _newFromToken);
external bridgingMatic(String _jobId, String _newFromToken);
external checkEthCompleted(String _jobId);
external checkMaticCompleted(String _txHash);
external erc20Exit(String _txHash);
external checkForInclusion(String _txHash);
external getMyJobs();
external getJobById(String _jobId);
external deleteJobById(String _jobId);
external returnTokens(String _chain);
external getBalancesByAddress(String _tokenAddress, int _chain);
