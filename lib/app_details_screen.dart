import 'package:flutter/material.dart';

class AppDetailsScreen extends StatelessWidget { //will display app name , and app icon(if possible) and will show their estimated battery usage
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('App Details')),
      body: Center(
        child: Text('Details about app usage will be displayed here.'),
      ),
    );
  }
}