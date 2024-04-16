import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppDetailsScreen extends StatefulWidget {
  @override
  _AppDetailsScreenState createState() => _AppDetailsScreenState();
}

class _AppDetailsScreenState extends State<AppDetailsScreen> {
  static const platform = MethodChannel('com.example.powermonitor/channel');
  String _usageDetails = 'Fetching app usage details...';

  @override
  void initState() {
    super.initState();
    getAppUsageDetails();
  }

  Future<void> getAppUsageDetails() async {
    try {
      final String result = await platform.invokeMethod('getAppUsageStats');
      setState(() {
        _usageDetails = result;
      });
    } on PlatformException catch (e) {
      setState(() {
        _usageDetails = "Failed to get app usage details: '${e.message}'.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(_usageDetails),
        ),
      ),
    );
  }
}
