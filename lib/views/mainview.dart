import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:monitorph/db/database.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  Timer? dbsave;
  bool isNotifPermiited = false;
  List<double> phData = [];
  List<String> dates = [];
  final _localNotifications = FlutterLocalNotificationsPlugin();
  void getData() async {
    final phRef = FirebaseDatabase.instance.ref('ph').child('current');
    final value = await phRef.get();
    if (!value.exists) {
      debugPrint('data not fetched!');
      return;
    }
    phLevel = double.parse(value.value.toString());
    if (phLevel < 6.0) {
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'channel id',
        'channel name',
        groupKey: 'com.example.flutter_push_notifications',
        channelDescription: 'channel description',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        ticker: 'ticker',
        icon: '@mipmap/ic_launcher',
        color: const Color(0xff2196f3),
      );
      _localNotifications.show(1, "Warning", "Ph level has drop to $phLevel",
          NotificationDetails(android: androidPlatformChannelSpecifics));
      String date = DateTime.now().month.toString() +
          "/" +
          DateTime.now().day.toString() +
          "/" +
          DateTime.now().year.toString();
      String time = DateTime.now().hour.toString() +
          ":" +
          DateTime.now().minute.toString();
      String formatDateTime = date + "-" + time;

      var insertData = {
        'ph': phLevel.toString(),
        'date': formatDateTime,
      };
      await DataBaseHelper.db!.insert('records', insertData);
      setState(() {
        phData.add(phLevel);
        dates.add(formatDateTime);
      });
    }
  }

  void getPermission() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    isNotifPermiited = (await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission())!;
  }

  void awaitDatabase() async {
    final db = await DataBaseHelper.initDatabase();

    // String date = DateTime.now().month.toString() +
    //     "/" +
    //     DateTime.now().day.toString() +
    //     "/" +
    //     DateTime.now().year.toString();
    // String time =
    //     DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString();
    // String formatDateTime = date + "-" + time;

    // var sampleData = {
    //   'ph': 5.4,
    //   'date': formatDateTime,
    // };
    // await DataBaseHelper.db!.insert('records', sampleData);

    final allRecords =
        await db.query('records', columns: ['ph, date'], limit: 25);

    allRecords.forEach((record) {
      phData.add(double.parse(record['ph'].toString()));
      dates.add(record['date'].toString());
    });

    setState(() {});
    //debugPrint(await DataBaseHelper.db!.insert('records', sampleData).toString());
  }

  void saveToDB() async {
    phData.add(phLevel);

    String date = DateTime.now().month.toString() +
        "/" +
        DateTime.now().day.toString() +
        "/" +
        DateTime.now().year.toString();
    String time =
        DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString();
    String formatDateTime = date + "-" + time;
    dates.add(formatDateTime);
    var insertData = {
      'ph': phLevel.toString(),
      'date': formatDateTime,
    };

    await DataBaseHelper.db!.insert('records', insertData);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getPermission();
    awaitDatabase();

    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => getData());
    dbsave = Timer.periodic(Duration(seconds: 60), (Timer t) => saveToDB());
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

  Future<Widget> getRecordTable() async {
    if (phData.isEmpty) return Text('No Record');

    List<TableRow> rows = [];
    const t = TextStyle(
        fontFamily: 'Calibre', fontWeight: FontWeight.bold, fontSize: 20);
    const s = TextStyle(
      fontFamily: 'Calibre',
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Color.fromARGB(255, 255, 255, 255),
    );
    rows.add(TableRow(
      children: [
        const Text(
          'PH',
          textAlign: TextAlign.center,
          style: t,
        ),
        const Text(
          'Date',
          textAlign: TextAlign.center,
          style: t,
        ),
      ],
    ));

    for (var i = 0; i < phData.length; i++) {
      Color col = Colors.red;

      if (phData[i] >= 6.0 && phData[i] <= 8.0) {
        col = Color.fromARGB(204, 0, 255, 0);
      } else if (phData[i] < 6.0) {
        col = Color.fromARGB(190, 247, 33, 33);
      } else {
        col = Color.fromARGB(195, 0, 0, 255);
      }

      rows.add(TableRow(
        children: [
          Container(
            decoration: BoxDecoration(color: col),
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                '${phData[i]}',
                style: s,
              ),
            ),
            alignment: Alignment.center,
          ),
          Container(
            decoration: BoxDecoration(color: col),
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                '${dates[i]}',
                style: s,
              ),
            ),
            alignment: Alignment.center,
          )
        ],
      ));
    }
    double scrWidth = MediaQuery.of(context).size.width;
    // double scrHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Container(
            width: scrWidth,
            margin: const EdgeInsets.only(left: 5, right: 5),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(),
                left: BorderSide(),
                right: BorderSide(),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              color: Color.fromARGB(221, 34, 145, 236),
            ),
            child: Text(
              'Records',
              style: TextStyle(
                fontFamily: 'Calibre',
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
                1: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder.all(color: Colors.black, width: 1.4),
              children: rows,
            ),
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
      body: ListView(
        children: [
          Column(
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
              FutureBuilder(
                  future: getRecordTable(),
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
        ],
      ),
    );
  }
}
