@JS()
library blockchainlogic.js;

import 'dart:js';

import 'package:js/js.dart';

@JS()
external dynamic login();
external dynamic loggedIn();
external dynamic logout();
external dynamic setUserData(var _file, String _username);
external dynamic fetch1InchTokens();
external dynamic getTokenPairRate(
    String fromToken, String toToken, String amount);
external dynamic swap(String fromToken, String toToken, String amount);
external dynamic getTokenBalances();
external dynamic getEthBalance();
external dynamic getBscBalance();
external dynamic getMyTransactions();
external dynamic deployPortfolio();
external dynamic getDeployedPortfolios();
external dynamic followPortfolio(String portfolioId);
external dynamic getFollowedPortfolios();
external dynamic getMyNFT();
external dynamic getQuote(String _fromToken, String _toToken, String _amount);
