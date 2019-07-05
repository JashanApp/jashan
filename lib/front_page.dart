import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FrontPageViewer extends StatelessWidget {
  final FrontPage frontPage;

  FrontPageViewer(this.frontPage);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color.fromRGBO(0, 71, 255, 1), Color.fromRGBO(255, 117, 0, 1)],
          ),
        ),
        child: frontPage,
      ),
    );
  }
}

abstract class FrontPage extends StatefulWidget {
}