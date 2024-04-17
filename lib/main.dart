import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'battery_data.dart';
import 'app_usage_data.dart';
import 'main_screen.dart';
import 'historical_data_screen.dart';
import 'app_details_screen.dart';
import 'app_usage_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BatteryDataAdapter());
  Hive.registerAdapter(AppUsageDataAdapter());
  await Hive.openBox<BatteryData>('batteryData');
  await Hive.openBox<AppUsageData>('appUsageData');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Power Monitor',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.grey[850],
        appBarTheme: AppBarTheme(
          color: Colors.grey[900],
          elevation: 0,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.green,
            backgroundColor: Colors.grey[800],
          ),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blue),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainScreen(),
        '/historical': (context) => HistoricalDataScreen(),
        '/details': (context) => AppDetailsScreen(),
        '/appUsage': (context) => AppUsageScreen(),
      },
    );
  }
}
