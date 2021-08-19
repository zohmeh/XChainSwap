import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../views/myportfolioview/myportfoliodesktopview.dart';
import '../../functions/functions.dart';
import '../../provider/loginprovider.dart';
import '../../widgets/myJobs/myJobs.dart';

class MyXJobsDesktopView extends StatefulWidget {
  @override
  _MyXJobsDesktopViewState createState() => _MyXJobsDesktopViewState();
}

class _MyXJobsDesktopViewState extends State<MyXJobsDesktopView> {
  @override
  void initState() {
    super.initState();
    checkforloggedIn().then((value) {
      setState(() {
        initialUser = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<LoginModel>(context).user;
    return initialUser != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Follow your XSwaps on Ethereum",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  MyJobsDesktopView(chain: 0),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Follow your XSwaps on Polygon",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  MyJobsDesktopView(chain: 2),
                ],
              ),
            ],
          )
        : Center(
            child: Text("LogIn with Metamask"),
          );
  }
}
