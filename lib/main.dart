import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'battery_data.dart'; // Ensure this is correctly imported
import 'main_screen.dart';
import 'historical_data_screen.dart';
import 'app_details_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BatteryDataAdapter()); // Register your adapter
  await Hive.openBox<BatteryData>(
      'batteryData'); // Correctly open your box as BatteryData
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Power Monitor',
      initialRoute: '/',
      routes: {
        '/': (context) => MainScreen(),
        '/historical': (context) => HistoricalDataScreen(),
        '/details': (context) => AppDetailsScreen(),
      },
    );
  }
}
