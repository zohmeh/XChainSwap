import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  final balances;

  PieChartWidget({this.balances});

  final List<Color> gradientsColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d9a),
  ];

  @override
  Widget build(BuildContext context) {
    var totalBalance = 0.0;
    List<PieChartSectionData> pieChartSelectionDatas = [];
    List colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.white,
      Colors.blueAccent,
      Colors.amber,
      Colors.pink,
      Colors.deepOrange,
      Colors.lime,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.cyan,
      Colors.teal,
      Colors.grey,
      Colors.indigo,
      Colors.deepPurple,
      Colors.blueGrey,
      Colors.brown,
    ];
    for (var i = 0; i < balances.length; i++) {
      var balance = balances[i]["current_price"] *
          (int.parse(balances[i]["balance"]) /
              pow(10, int.parse(balances[i]["decimals"])));
      totalBalance = totalBalance + balance;
      if (balance != 0) {
        pieChartSelectionDatas.add(PieChartSectionData(
            color: colors[i], value: balance, showTitle: true, title: ""));
      }
    }

    return Column(
      children: [
        Expanded(
          child: Stack(children: [
            PieChart(
              PieChartData(
                  centerSpaceRadius: 75, sections: pieChartSelectionDatas),
            ),
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(
                        color: Theme.of(context).highlightColor,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    totalBalance.toStringAsFixed(2) + " USD",
                    style: TextStyle(
                        color: Theme.of(context).highlightColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            )
          ]),
        ),
        SizedBox(height: 15),
        Expanded(
          child: ListView.builder(
            itemCount: balances.length,
            itemBuilder: (ctx, idx) {
              return Center(
                child: Container(
                  margin: EdgeInsets.all(5),
                  child: Text(
                    balances[idx]["name"],
                    style: TextStyle(
                        color: colors[idx], fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
