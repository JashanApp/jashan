import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(JashanApp());

class JashanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jashan',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Jashan Demo'),
        ),
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}