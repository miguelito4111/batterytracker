import 'package:flutter/material.dart';

class HistoricalDataScreen extends StatelessWidget { //will use a database (like sqlite) to save previous usage percentages of apps
//, and show a graph of overall usage
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historical Data')),
      body: ListView.builder(
        itemCount: 7, // One week of data for demonstration
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Day ${index + 1}'),
            subtitle: Text('Total Usage: ${100 - index * 10}%'),
          );
        },
      ),
    );
  }
}