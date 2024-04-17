import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // Import for Timer

class AppDetailsScreen extends StatefulWidget {
  @override
  _AppDetailsScreenState createState() => _AppDetailsScreenState();
}

class AppUsageDetails {
  final String packageName;
  final String lastTimeUsed;
  final int totalTimeForeground; // Change to int to represent seconds

  AppUsageDetails({
    required this.packageName,
    required this.lastTimeUsed,
    required this.totalTimeForeground,
  });

  String get formattedTotalTime {
    if (totalTimeForeground < 60) {
      return '$totalTimeForeground seconds';
    } else if (totalTimeForeground < 3600) {
      return '${(totalTimeForeground / 60).toStringAsFixed(1)} minutes';
    } else {
      return '${(totalTimeForeground / 3600).toStringAsFixed(1)} hours';
    }
  }
}

class _AppDetailsScreenState extends State<AppDetailsScreen> {
  static const platform = MethodChannel('com.example.powermonitor/channel');
  List<AppUsageDetails> usageDetails = [];
  Timer? _timer; // Timer to handle periodic updates

  @override
  void initState() {
    super.initState();
    getAppUsageDetails();
    _startTimer(); // Start the timer on init
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the screen is disposed
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (Timer t) => getAppUsageDetails());
    // Refresh every 10 seconds, adjust the duration according to your needs
  }

  Future<void> getAppUsageDetails() async {
  try {
    final String result = await platform.invokeMethod('getAppUsageStats');
    var lines = result.split('\n');
    setState(() {
      usageDetails = lines.map((line) {
        var parts = line.split(', ');
        return AppUsageDetails(
          packageName: parts[0].split(': ')[1],
          lastTimeUsed: parts[1].split(': ')[1],
          totalTimeForeground: int.parse(parts[2].split(': ')[1].split(' ')[0]),

        );
      }).toList();
    });
  } on PlatformException catch (e) {
    print("Failed to get app usage details: ${e.message}");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'App Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: usageDetails.length,
        itemBuilder: (context, index) {
          final detail = usageDetails[index];
          return ListTile(
            title: Text(
              detail.packageName,
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Last used: ${detail.lastTimeUsed}\nTotal foreground time: ${detail.formattedTotalTime}',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.flutter_dash), // Display the Flutter Dash icon
          );
        },
      ),
    );
  }
}
