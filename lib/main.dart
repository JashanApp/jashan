import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/orange_background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: LogInPage(),
        ),
      ),
    );
  }
}

class LogInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('LOG IN'),
              SizedBox(
                height: 20,
              ),
              Container(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'Username',
                  ),
                ),
              ),
              Container(
                width: 300,
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'Password',
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 35,
                  ),
                  Checkbox(
                    onChanged: (bool value) {},
                    value: false,
                  ),
                  Text('Remember me'),
                  SizedBox(
                    width: 65,
                  ),
                  Text('Forgot password?'),
                ],
              ),
              RaisedButton(
                child: Text("LOG IN"),
                onPressed: () {},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(75),
                ),
              ),
            ],
          ),
        ),
        Text('Don\'t have an account? SIGN UP'),
        SizedBox(
          height: 30,
        )
      ],
    );
  }
}
