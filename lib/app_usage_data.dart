import 'package:hive/hive.dart';

part 'app_usage_data.g.dart'; // Hive will generate this file

@HiveType(typeId: 1)
class AppUsageData {
  @HiveField(0)
  final String appName;
  @HiveField(1)
  final double batteryUsed;
  @HiveField(2)
  final DateTime date;

  AppUsageData(
      {required this.appName, required this.batteryUsed, required this.date});
}
