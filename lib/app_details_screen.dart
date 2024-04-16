import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:typed_data';

class AppDetailsScreen extends StatefulWidget {
  @override
  _AppDetailsScreenState createState() => _AppDetailsScreenState();
}

class _AppDetailsScreenState extends State<AppDetailsScreen> {
  static const platform = MethodChannel('com.example.powermonitor/channel');
  String _usageDetails = 'Fetching app usage details...';
  String _iconBase64 = '';
  String _packageName = 'com.example.batterytracker';

  Future<String> fetchAppIcon(String packageName) async {
    try {
      final String iconBase64 = await platform.invokeMethod('getAppIcon', {'packageName': packageName});
      return iconBase64;
    } on PlatformException catch (e) {
      print("Failed to fetch icon: ${e.message}");
      return ''; // Return an empty string to indicate failure
    }
  }

    Widget buildIcon(String base64String) {
  if (base64String.isEmpty) {
    return Icon(Icons.error);  // Display an error icon if no icon data
  }

  // Ensure all invalid characters are removed
  String sanitizedBase64 = base64String.replaceAll(RegExp(r'\s+'), '');

  try {
    Uint8List bytes = base64.decode(sanitizedBase64);
    return Image.memory(bytes);
  } catch (e) {
    print("Failed to decode Base64: $e");
    return Icon(Icons.error);  // Display an error icon if decoding fails
  }
}
  @override
  void initState() {
    super.initState();
    getAppUsageDetails();
    fetchAppIcon(_packageName).then((base64String) {
      setState(() {
        _iconBase64 = base64String;
      });
    });
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(_usageDetails),
          ),
          _iconBase64.isEmpty ? Icon(Icons.error_outline) : buildIcon(_iconBase64), // Display the icon
        ],
      ),
    ),
  );
}
}
