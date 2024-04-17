import 'package:flutter/material.dart';
import 'package:battery/battery.dart';
import 'package:hive/hive.dart';
import 'battery_data.dart'; // Import battery data model
import 'historical_data_screen.dart';
import 'app_details_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Battery _battery = Battery();
  late final Box<BatteryData> _batteryBox;

  @override
  void initState() {
    super.initState();
    _batteryBox = Hive.box<BatteryData>('batteryData');
    _battery.onBatteryStateChanged.listen((BatteryState state) async {
      int batteryLevel = await _battery.batteryLevel;
      _storeBatteryData(batteryLevel);
    });
  }

  Future<void> _storeBatteryData(int batteryPercentage) async {
    final batteryData = BatteryData(
      date: DateTime.now(),
      batteryPercentage: batteryPercentage.toDouble(),
    );
    await _batteryBox.add(batteryData);
  }

  Future<void> _getBatteryUsage() async {
    try {
      final int result =
          await _battery.batteryLevel; // Using the battery package
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Battery Percentage'),
            content: Text('$result%'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the pop-up
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text("Failed to get battery usage: '${e.toString()}'."),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the pop-up
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Power Consumption Overview'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
              onPressed: _getBatteryUsage,
              child: Text('Get Current Battery Percentage'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HistoricalDataScreen()),
                );
              },
              child: Text('View Historical Data'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppDetailsScreen()),
                );
              },
              child: Text('View App Details'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _batteryBox.close(); // Close the Hive box when not needed
    super.dispose();
  }
}
