import 'package:flutter/material.dart';
import '../../routing/route_names.dart';
import '../../services/navigation_service.dart';
import '../../widgets/buttons/ibutton.dart';

import '../../locator.dart';

class Navbardesktop2 extends StatefulWidget {
  @override
  _Navbardesktop2State createState() => _Navbardesktop2State();
}

class _Navbardesktop2State extends State<Navbardesktop2> {
  List buttonColors = [Colors.white, Colors.white];

  _changeSide(List _arguments) {
    locator<NavigationService>().navigateTo(_arguments[0]);
    //setState(() {
    //  buttonColors = [Colors.white, Colors.white];
    //  buttonColors[_arguments[1]] = Colors.purpleAccent;
    //});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ibutton("swap.png", Theme.of(context).backgroundColor,
              buttonColors[0], "Swap", _changeSide, [HomeRoute, 0]),
          SizedBox(width: 20),
          ibutton(
            "bill.png",
            Theme.of(context).backgroundColor,
            buttonColors[1],
            "My XSwaps",
            _changeSide,
            [JobRoute, 1],
          )
        ],
      ),
    );
  }
}
