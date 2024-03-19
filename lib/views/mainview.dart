import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'dart:async';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  double phLevel = 0.0;
  Timer? timer;
  List<double> phData = [];
  void getData() async {
    final phRef = FirebaseDatabase.instance.ref('ph').child('current');
    final value = await phRef.get();
    if (!value.exists) {
      debugPrint('data not fetched!');
      return;
    }

    setState(() {
      phLevel = double.parse(value.value.toString());
      phData.add(phLevel);
      debugPrint('state change');
      debugPrint('$phLevel');
    });
  }

  @override
  void initState() {
    super.initState();
    //getData();
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) => getData());
  }

  Future<Widget> renderLineGraph() async {
    if (phData.isEmpty) return Container();

    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: SfCartesianChart(
        title: ChartTitle(text: 'Ph level every second'),
        legend: Legend(isVisible: true, title: LegendTitle(text: 'ph level')),
        series: <LineSeries<double, int>>[
          LineSeries<double, int>(
            dataSource: phData,
            xValueMapper: (d, i) {
              return i;
            },
            yValueMapper: (d, i) {
              return d;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 24),
              child: SfRadialGauge(
                axes: [
                  RadialAxis(
                    minimum: 0,
                    maximum: 14,
                    ranges: [
                      GaugeRange(
                        startValue: 0,
                        endValue: 6,
                        color: const Color.fromARGB(255, 255, 0, 0),
                        label: 'Acidic',
                      ),
                      GaugeRange(
                        startValue: 6.1,
                        endValue: 7.9,
                        color: const Color.fromARGB(255, 0, 255, 0),
                        label: 'Neurtral',
                      ),
                      GaugeRange(
                        startValue: 8.0,
                        endValue: 14,
                        color: const Color.fromARGB(255, 0, 0, 255),
                        label: 'Base',
                      ),
                    ],
                    pointers: [
                      NeedlePointer(
                        value: phLevel,
                        enableAnimation: true,
                      ),
                    ],
                    annotations: [
                      GaugeAnnotation(
                        widget: Container(
                          padding: const EdgeInsets.fromLTRB(0, 175, 0, 0),
                          child: Text(
                            'PH Level: ${phLevel.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontFamily: 'Calibre',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        angle: 180.0 * (phLevel / 180.0),
                        positionFactor: 0,
                      )
                    ],
                  ),
                ],
              ),
            ),
            FutureBuilder(
                future: renderLineGraph(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return snapshot.requireData;
                  }
                  return Container(
                    child: const Text('No data'),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
