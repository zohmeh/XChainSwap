@JS()
library blockchainlogic.js;

import 'package:js/js.dart';
//import 'dart:js_util';

@JS()
external dynamic login();
external dynamic loggedIn();
external dynamic logout();
external dynamic setUserData(var _file, String _username);
external dynamic fetchParaswapTokens();
external dynamic getTokenPairRate(
    String fromToken, String toToken, String amount);
