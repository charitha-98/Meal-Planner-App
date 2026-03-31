import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget buildPieChart(double protein, double carbs, double fat) {
  double total = protein + carbs + fat;

  return Stack(
    alignment: Alignment.center,
    children: [
      SizedBox(
        height: 180,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 50,
            sections: total == 0
                ? [
                    PieChartSectionData(
                      color: Colors.grey[200],
                      value: 100,
                      showTitle: false,
                      radius: 40,
                    ),
                  ]
                : [
                    PieChartSectionData(
                      color: const Color.fromARGB(255, 208, 211, 15),
                      value: protein,
                      title: 'P',
                      radius: 50,
                      titleStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      color: const Color.fromARGB(255, 199, 8, 8),
                      value: carbs,
                      title: 'C',
                      radius: 50,
                      titleStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.redAccent,
                      value: fat,
                      title: 'F',
                      radius: 50,
                      titleStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
          ),
        ),
      ),

      if (total == 0)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pie_chart_outline, color: Colors.grey[400]),
            Text(
              "No Data",
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
    ],
  );
}
