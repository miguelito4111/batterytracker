import 'package:hive/hive.dart';

part 'battery_data.g.dart'; // Hive will generate this file

@HiveType(typeId: 0)
class BatteryData {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final double batteryPercentage;

  BatteryData({required this.date, required this.batteryPercentage});
}
