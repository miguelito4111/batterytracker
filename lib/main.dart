import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'historical_data_screen.dart';
import 'app_details_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) { //navigation builder, chooses what screen the app will initialize on
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