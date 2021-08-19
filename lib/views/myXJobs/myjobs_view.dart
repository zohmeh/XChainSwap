import 'package:flutter/material.dart';
import '../../views/myXJobs/myXJobsdesktopview.dart';
import '../../responsive.dart';

class MyJobsView extends StatefulWidget {
  @override
  _MyJobsViewState createState() => _MyJobsViewState();
}

class _MyJobsViewState extends State<MyJobsView> {
  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: MyXJobsDesktopView(),
      tablet: MyXJobsDesktopView(),
      desktop: MyXJobsDesktopView(),
    );
  }
}
