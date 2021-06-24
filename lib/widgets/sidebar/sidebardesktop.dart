import 'package:flutter/material.dart';
import '../buttons/ibutton.dart';
import '../../routing/route_names.dart';
import '../../services/navigation_service.dart';
import '../../locator.dart';

class SidebarDesktop extends StatefulWidget {
  final side;

  SidebarDesktop(this.side);

  @override
  _SidebarDesktopState createState() => _SidebarDesktopState();
}

class _SidebarDesktopState extends State<SidebarDesktop> {
  _changeSide(List _arguments) {
    locator<NavigationService>().navigateTo(_arguments[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
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
      child: Column(
        children: [
          /*ibutton(
              Icons.gavel_rounded,
              Theme.of(context).primaryColor,
              widget.side == 0
                  ? Theme.of(context).accentColor
                  : Theme.of(context).highlightColor,
              "All Portfolios",
              _changeSide,
              [AllPortfoliosRoute]),
          SizedBox(height: 20),
          */
          ibutton(
              Icons.account_balance_wallet_rounded,
              Theme.of(context).primaryColor,
              widget.side == 1
                  ? Theme.of(context).accentColor
                  : Theme.of(context).highlightColor,
              "My Portfolio",
              _changeSide,
              [HomeRoute]),
          SizedBox(height: 20),
          ibutton(
              Icons.sync_alt_rounded,
              Theme.of(context).primaryColor,
              widget.side == 2
                  ? Theme.of(context).accentColor
                  : Theme.of(context).highlightColor,
              "Swap Tokens",
              _changeSide,
              [SwapTokensRoute]),
          /*SizedBox(height: 20),
          ibutton(
              Icons.settings_applications_rounded,
              Theme.of(context).primaryColor,
              widget.side == 3
                  ? Theme.of(context).accentColor
                  : Theme.of(context).highlightColor,
              "Settings",
              _changeSide,
              [SettingsRoute]),*/
        ],
      ),
    );
  }
}
