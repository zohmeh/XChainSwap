import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/loginprovider.dart';
import '../../widgets/buttons/ibutton.dart';
import '../../routing/route_names.dart';
import '../../services/navigation_service.dart';
import '../../locator.dart';
import '../buttons/button.dart';

class SidebarMobile extends StatefulWidget {
  @override
  _SidebarMobileState createState() => _SidebarMobileState();
}

class _SidebarMobileState extends State<SidebarMobile> {
  _changeSide(List _arguments) {
    locator<NavigationService>().navigateTo(_arguments[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
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
          button(
              Theme.of(context).buttonColor,
              Theme.of(context).highlightColor,
              "LogIn",
              Provider.of<LoginModel>(context).logIn),
          button(
              Theme.of(context).buttonColor,
              Theme.of(context).highlightColor,
              "LogOut",
              Provider.of<LoginModel>(context).logOut),
          SizedBox(height: 100),
          ibutton(
              Icons.gavel_rounded,
              Theme.of(context).primaryColor,
              Theme.of(context).highlightColor,
              "All Portfolios",
              _changeSide,
              [AllPortfoliosRoute]),
          SizedBox(height: 20),
          ibutton(
              Icons.account_balance_wallet_rounded,
              Theme.of(context).primaryColor,
              Theme.of(context).highlightColor,
              "My Portfolio",
              _changeSide,
              [HomeRoute]),
          SizedBox(height: 20),
          ibutton(
              Icons.attach_money_rounded,
              Theme.of(context).primaryColor,
              Theme.of(context).highlightColor,
              "Swap Tokens",
              _changeSide,
              [SwapTokensRoute]),
          SizedBox(height: 20),
          ibutton(
              Icons.settings_applications_rounded,
              Theme.of(context).primaryColor,
              Theme.of(context).highlightColor,
              "Settings",
              _changeSide,
              [SettingsRoute]),
        ],
      ),
    );
  }
}
