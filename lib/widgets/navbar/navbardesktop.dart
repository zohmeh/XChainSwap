import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/useravatar.dart';
import '../../provider/contractinteraction.dart';
import '../../provider/loginprovider.dart';
import '../buttons/button.dart';

class Navbardesktop extends StatefulWidget {
  @override
  _NavbardesktopState createState() => _NavbardesktopState();
}

class _NavbardesktopState extends State<Navbardesktop> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LoginModel>(context).user;
    final image = Provider.of<LoginModel>(context).image;
    final tx = Provider.of<Contractinteraction>(context).tx;
    return Container(
      height: 75,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "DushiFolio",
            style: TextStyle(
                color: Theme.of(context).highlightColor, fontSize: 30),
          ),
          user != null
              ? Row(
                  children: [
                    Column(
                      children: [
                        Container(),
                        Container(
                          width: 200,
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Your latest Transaction",
                            style: TextStyle(
                                color: Theme.of(context).highlightColor),
                          ),
                        ),
                        tx != null
                            ? Flexible(
                                child: Container(
                                    width: 200,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: tx == "true"
                                        ? Text("successful",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .highlightColor,
                                                fontSize: 10))
                                        : tx == "pending"
                                            ? Text("pending",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .highlightColor,
                                                    fontSize: 10))
                                            : Text("error",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .highlightColor,
                                                    fontSize: 10))),
                              )
                            : Container(
                                width: 200,
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: Text("No Transaction",
                                    style: TextStyle(
                                        color: Theme.of(context).highlightColor,
                                        fontSize: 10))),
                      ],
                    ),
                    Useravatar(image: image, width: 50, height: 50),
                    SizedBox(width: 15),
                    Container(
                      child: Text(
                        user.toString(),
                        style: TextStyle(
                            color: Theme.of(context).highlightColor,
                            fontSize: 15),
                      ),
                    ),
                    button(
                        Theme.of(context).buttonColor,
                        Theme.of(context).highlightColor,
                        "LogOut",
                        Provider.of<LoginModel>(context).logOut)
                  ],
                )
              : button(
                  Theme.of(context).buttonColor,
                  Theme.of(context).highlightColor,
                  "LogIn",
                  Provider.of<LoginModel>(context).logIn),
        ],
      ),
    );
  }
}
