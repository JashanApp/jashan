import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jashan/log_in_page.dart';
import 'package:jashan/page.dart';
import 'package:jashan/register_page.dart';

void main() => runApp(JashanApp());

class JashanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jashan',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        accentColor: Colors.blueAccent,
        primaryTextTheme: Typography(platform: TargetPlatform.iOS).white,
        textTheme: Typography(platform: TargetPlatform.iOS).white,
      ),
      routes: {
        '/': (context) => FrontPageViewer(LogInPage()),
        '/register': (context) => FrontPageViewer(RegisterPage()),
      },
    );
  }
}