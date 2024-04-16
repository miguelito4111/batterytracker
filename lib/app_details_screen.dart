import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppUsageInfo {
  final String packageName;
  final int lastTimeUsed;
  final int totalTimeForeground;

  AppUsageInfo(
      {required this.packageName,
      required this.lastTimeUsed,
      required this.totalTimeForeground});

  factory AppUsageInfo.fromJson(Map<String, dynamic> json) {
    return AppUsageInfo(
      packageName: json['Pkg'],
      lastTimeUsed: int.parse(json['LastTimeUsed']),
      totalTimeForeground:
          int.parse(json['TotalTimeForeground'].replaceAll(' seconds', '')),
    );
  }
}

class AppDetailsScreen extends StatefulWidget {
  @override
  _AppDetailsScreenState createState() => _AppDetailsScreenState();
}

class _AppDetailsScreenState extends State<AppDetailsScreen> {
  static const platform = MethodChannel('com.example.powermonitor/channel');
  List<AppUsageInfo> _usageDetails = [];

  @override
  void initState() {
    super.initState();
    getAppUsageDetails();
  }

  Future<void> getAppUsageDetails() async {
    try {
      final String result = await platform.invokeMethod('getAppUsageStats');
      setState(() {
        _usageDetails = parseUsageData(result);
      });
    } on PlatformException catch (e) {
      print("Failed to get app usage details: '${e.message}'.");
    }
  }

  List<AppUsageInfo> parseUsageData(String rawData) {
    List<AppUsageInfo> usageInfoList = [];
    RegExp regex = RegExp(
        r'Pkg: (.*?), LastTimeUsed: (\d+), TotalTimeForeground: (\d+) seconds');
    for (final match in regex.allMatches(rawData)) {
      usageInfoList.add(AppUsageInfo(
        packageName: match.group(1) ?? '',
        lastTimeUsed: int.tryParse(match.group(2) ?? '0') ?? 0,
        totalTimeForeground: int.tryParse(match.group(3) ?? '0') ?? 0,
      ));
    }
    return usageInfoList
        .where((info) => info.totalTimeForeground > 0)
        .toList(); // Filtering entries with no active usage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Details'),
      ),
      body: _usageDetails.isNotEmpty
          ? buildAppDetailsList()
          : CircularProgressIndicator(),
    );
  }

  Widget buildAppDetailsList() {
    return ListView.builder(
      itemCount: _usageDetails.length,
      itemBuilder: (context, index) {
        final app = _usageDetails[index];
        return ListTile(
          title: Text(app.packageName),
          subtitle: Text(
              'Last Used: ${app.lastTimeUsed}, Total Foreground Time: ${app.totalTimeForeground} seconds'),
        );
      },
    );
  }
}
