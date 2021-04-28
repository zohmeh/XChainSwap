import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar/sidebarmobile.dart';
import '../provider/contractinteraction.dart';
import '../provider/loginprovider.dart';

class Mobileview extends StatefulWidget {
  final Widget child;
  const Mobileview({Key key, this.child}) : super(key: key);
  @override
  _Mobileview createState() => _Mobileview();
}

class _Mobileview extends State<Mobileview> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LoginModel>(context).user;
    final tx = Provider.of<Contractinteraction>(context).tx;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      key: _scaffoldKey,
      drawer: SidebarMobile(),
      body: Column(
        children: [
          Container(
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
                IconButton(
                    color: Theme.of(context).highlightColor,
                    onPressed: () {
                      _scaffoldKey.currentState.openDrawer();
                    },
                    icon: Icon(Icons.menu)),
                user != null
                    ? Column(
                        children: [
                          Text(
                            "The Collector",
                            style: TextStyle(
                                color: Theme.of(context).highlightColor),
                          ),
                          Text(
                            user.toString(),
                            style: TextStyle(
                              color: Theme.of(context).highlightColor,
                              fontSize: 10,
                            ),
                          ),
                          tx != null
                              ? Flexible(
                                  child: Container(
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
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text("No Transaction",
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).highlightColor,
                                          fontSize: 10))),
                        ],
                      )
                    : Text(
                        "The Collector",
                        style:
                            TextStyle(color: Theme.of(context).highlightColor),
                      ),
              ],
            ),
          ),
          Expanded(child: widget.child)
        ],
      ),
    );
  }
}
