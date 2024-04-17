import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'battery_data.dart';

class HistoricalDataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Box<BatteryData> batteryBox = Hive.box<BatteryData>('batteryData');

    return Scaffold(
      appBar: AppBar(title: Text('Historical Data')),
      body: ValueListenableBuilder(
        valueListenable: batteryBox.listenable(),
        builder: (context, Box<BatteryData> box, _) {
          if (box.values.isEmpty) {
            return Center(child: Text("No data available"));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final data = box.getAt(index);
              return ListTile(
                title: Text('Date: ${data?.date.toString() ?? 'No date'}'),
                subtitle: Text(
                    'Battery Usage: ${data?.batteryPercentage.toStringAsFixed(2) ?? 'No data'}%'),
              );
            },
          );
        },
      ),
    );
  }
}
