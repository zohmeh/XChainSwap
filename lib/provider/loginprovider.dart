import 'package:flutter/material.dart';
import 'package:js/js_util.dart';
import 'package:web_app_template/functions/functions.dart';
import '../widgets/javascript_controller.dart';

class LoginModel with ChangeNotifier {
  var _user;
  var image;

  String get user {
    return _user;
  }

  Future logIn() async {
    var promise = login();
    var logIn = await promiseToFuture(promise);
    _user = logIn[0];
    image = logIn[1];
    notifyListeners();
  }

  Future logOut() async {
    var promise = logout();
    var loggedOut = await promiseToFuture(promise);
    _user = loggedOut;
    notifyListeners();
  }

  Future checkforloggedIn() async {
    var promise = loggedIn();
    var loggedin = await promiseToFuture(promise);
    _user = loggedin;
    notifyListeners();
  }

  Future setMyData(List _arguments) async {
    var promise = setUserData(_arguments[0], _arguments[1]);
    var userdata = await promiseToFuture(promise);
    _user = userdata;
    notifyListeners();
  }
}
