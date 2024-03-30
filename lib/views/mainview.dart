import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'dart:async';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  double phLevel = 0.0, lowestReading = 0.0;
  bool isSet = false;
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
      //debugPrint('state change');
      // debugPrint('$phLevel');
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

  Widget getLowestReading() {
    if (phLevel > 6) {
      return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 5),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        'Lowest Reading: ${phLevel.toStringAsFixed(1)}',
        style: TextStyle(
          fontSize: 24,
          color: const Color.fromARGB(255, 255, 0, 0),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget getGauge() {
    return Container(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Readings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: "Calibre",
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 5),
              child: Text(
                'Current Reading: ${phLevel.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
