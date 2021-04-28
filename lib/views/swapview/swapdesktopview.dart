import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:web_app_template/widgets/javascript_controller.dart';
import '../../widgets/sidebar/sidebardesktop.dart';

class SwapDesktopView extends StatefulWidget {
  @override
  _SwapDesktopViewState createState() => _SwapDesktopViewState();
}

class _SwapDesktopViewState extends State<SwapDesktopView> {
  Future fetchTokens() async {
    var promise = fetchParaswapTokens();
    var tokens = await promiseToFuture(promise);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SidebarDesktop(2),
        Container(
          padding: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width - 150,
          height: MediaQuery.of(context).size.height,
          child: RaisedButton(
            child: Text("Fetch Tokens"),
            onPressed: () => fetchTokens(),
          ),
        ),
      ],
    );
  }
}
