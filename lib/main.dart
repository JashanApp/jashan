import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jashan/log_in_page.dart';
import 'package:jashan/front_page.dart';
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
        primaryTextTheme: Typography(platform: TargetPlatform.android).white,
        textTheme: Typography(platform: TargetPlatform.android).white,
      ),
      routes: {
        '/': (context) => FrontPageViewer(LogInPage()),
        '/register': (context) => FrontPageViewer(RegisterPage()),
      },
    );
  }
}