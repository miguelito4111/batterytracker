import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_usage_data.dart';

class AppUsageScreen extends StatefulWidget {
  @override
  _AppUsageScreenState createState() => _AppUsageScreenState();
}

class _AppUsageScreenState extends State<AppUsageScreen> {
  static const platform = MethodChannel('com.example.powermonitor/channel');
  late Box<AppUsageData> appUsageBox;

  @override
  void initState() {
    super.initState();
    appUsageBox = Hive.box<AppUsageData>('appUsageData');
    fetchAndStoreAppUsageData();
  }

  Future<void> fetchAndStoreAppUsageData() async {
    try {
      final List<dynamic> usageStats =
          await platform.invokeMethod('getAppUsageStats');
      for (var stat in usageStats) {
        final appUsage = AppUsageData(
          appName: stat['appName'],
          batteryUsed: stat['batteryUsed'],
          date: DateTime.parse(stat['date']),
        );
        appUsageBox.add(appUsage);
      }
    } on PlatformException catch (e) {
      print("Failed to fetch app usage data: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Usage Details'),
      ),
      body: ValueListenableBuilder(
        valueListenable: appUsageBox.listenable(),
        builder: (context, Box<AppUsageData> box, _) {
          if (box.values.isEmpty) {
            return Center(child: Text("No data available"));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final data = box.getAt(index);
              return ListTile(
                title: Text(data!.appName),
                subtitle: Text(
                    'Battery used: ${data.batteryUsed.toStringAsFixed(2)}%, Date: ${data.date}'),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
