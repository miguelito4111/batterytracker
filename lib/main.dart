import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'historical_data_screen.dart';
import 'app_details_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Power Monitor',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.grey[900],        // blue as the accent color
        scaffoldBackgroundColor: Colors.grey[850],
        appBarTheme: AppBarTheme(
          color: Colors.grey[900],
          elevation: 0,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,  // Buttons will have a blue color
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.green, backgroundColor: Colors.grey[800],   // Button text color for light themes
          ),
        ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blue),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainScreen(),
        '/historical': (context) => HistoricalDataScreen(),
        '/details': (context) => AppDetailsScreen(),
      },
    );
  }
}
