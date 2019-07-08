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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromRGBO(255, 117, 0, 1), Color.fromRGBO(224, 178, 132, 1)],
          ),
        ),
        child: frontPage,
      ),
    );
  }
}

abstract class FrontPage extends StatefulWidget {
}