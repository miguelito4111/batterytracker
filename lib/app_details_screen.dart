import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart'; // Import for date formatting

class AppUsageInfo {
  final String packageName;
  final DateTime lastTimeUsed;
  final int totalTimeForeground;

  AppUsageInfo(
      {required this.packageName,
      required this.lastTimeUsed,
      required this.totalTimeForeground});

  factory AppUsageInfo.fromJson(Map<String, dynamic> json) {
    final lastUsed = int.tryParse(json['LastTimeUsed']) ?? 0;
    return AppUsageInfo(
      packageName: json['Pkg'],
      lastTimeUsed: DateTime.fromMillisecondsSinceEpoch(lastUsed),
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
  Map<String, String> _icons = {};

  @override
  void initState() {
    super.initState();
    getAppUsageDetails();
  }

  Future<void> getAppUsageDetails() async {
    try {
      final String result = await platform.invokeMethod('getAppUsageStats');
      List<AppUsageInfo> fetchedDetails = parseUsageData(result);
      setState(() {
        _usageDetails = fetchedDetails;
      });
      fetchIconsForApps(
          fetchedDetails); // Fetch icons after fetching usage details
    } on PlatformException catch (e) {
      print("Failed to get app usage details: '${e.message}'.");
    }
  }

  void fetchIconsForApps(List<AppUsageInfo> apps) async {
    Map<String, String> icons = {};
    for (var app in apps) {
      final String iconBase64 = await fetchAppIcon(app.packageName);
      icons[app.packageName] = iconBase64;
    }
    setState(() {
      _icons = icons;
    });
  }

  Future<String> fetchAppIcon(String packageName) async {
    try {
      final String iconBase64 = await platform
          .invokeMethod('getAppIcon', {'packageName': packageName});
      return iconBase64;
    } on PlatformException catch (e) {
      print("Failed to fetch icon: ${e.message}");
      return ''; // Return an empty string to indicate failure
    }
  }

  List<AppUsageInfo> parseUsageData(String rawData) {
    List<AppUsageInfo> usageInfoList = [];
    RegExp regex = RegExp(
        r'Pkg: (.*?), LastTimeUsed: (\d+), TotalTimeForeground: (\d+) seconds');
    for (final match in regex.allMatches(rawData)) {
      usageInfoList.add(AppUsageInfo.fromJson({
        'Pkg': match.group(1),
        'LastTimeUsed': match.group(2),
        'TotalTimeForeground': '${match.group(3)} seconds'
      }));
    }
    return usageInfoList.where((info) => info.totalTimeForeground > 0).toList();
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
        final formattedDate =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(app.lastTimeUsed);
        return ListTile(
          leading: _icons[app.packageName]?.isEmpty ?? true
              ? Icon(Icons.error)
              : buildIcon(_icons[app.packageName]!),
          title: Text(app.packageName),
          subtitle: Text(
              'Last Used: $formattedDate, Total Foreground Time: ${app.totalTimeForeground} seconds'),
        );
      },
    );
  }

  Widget buildIcon(String base64String) {
    try {
      Uint8List bytes = base64.decode(base64String);
      return Image.memory(bytes, width: 48, height: 48);
    } catch (e) {
      print("Failed to decode Base64: $e");
      return Icon(Icons.error); // Display an error icon if decoding fails
    }
  }
}
