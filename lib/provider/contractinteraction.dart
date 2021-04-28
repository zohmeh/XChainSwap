import 'package:flutter/material.dart';
import 'package:js/js_util.dart';
import '../widgets/javascript_controller.dart';

class Contractinteraction with ChangeNotifier {
  var _tx;

  String get tx {
    return _tx;
  }

  setTxHash() {
    _tx = "pending";
    notifyListeners();
  }
}
