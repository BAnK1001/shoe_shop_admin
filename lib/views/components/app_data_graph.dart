import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../models/app_data.dart';

class AppDataGraph extends StatelessWidget {
  const AppDataGraph({
    super.key,
    required this.data,
  });

  final List<AppData> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: 400,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SfCartesianChart(
          primaryXAxis: const CategoryAxis(),
          // Chart title
          title: const ChartTitle(
            text: 'ShoesShop Analysis for app data',
          ),
          legend: const Legend(isVisible: true),
          // Enable tooltip
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries<dynamic, dynamic>>[
            LineSeries<AppData, String>(
              dataSource: data,
              xValueMapper: (AppData sales, _) => sales.title,
              yValueMapper: (AppData sales, _) => sales.number,
              name: 'Numbers',
              // Enable data label
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            )
          ],
        ),
      ),
    );
  }
}
