import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Import the screens
import 'historical_data_screen.dart';
import 'app_details_screen.dart';

class MainScreen extends StatefulWidget { //main screen with buttons that do as they are named
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const platform = MethodChannel('com.example.powermonitor/channel');
  //String _batteryUsage = 'Battery usage will be displayed here';

  Future<void> _getBatteryUsage() async {
  try {
    final String result = await platform.invokeMethod('getBatteryUsage'); //actual method that calls current battery percentage
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Battery Percentage'),
          content: Text(result),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the pop up
              },
            ),
          ],
        );
      },
    );
  } on PlatformException catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text("Failed to get battery usage: '${e.message}'."),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the pop up
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
              child: Text('Get Current batter percentage'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to HistoricalDataScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoricalDataScreen()),
                );
              },
              child: Text('View Historical Data'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to AppDetailsScreen
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
}
