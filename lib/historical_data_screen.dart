import 'package:flutter/material.dart';

class HistoricalDataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historical Data',
          style: TextStyle(color: Colors.white), // Set app bar title text color to white
        ),
        iconTheme: IconThemeData(color: Colors.white), // Set back arrow icon color to white
      ),
      body: ListView.builder(
        itemCount: 7, // One week of data for demonstration
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              'Day ${index + 1}',
              style: TextStyle(color: Colors.white), // Set list tile title text color to white
            ),
            subtitle: Text(
              'Total Usage: ${100 - index * 10}%',
              style: TextStyle(color: Colors.white), // Set list tile subtitle text color to white
            ),
          );
        },
      ),
    );
  }
}
