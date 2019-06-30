import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jashan/page.dart';

class LogInPage extends FrontPage {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        SizedBox(
          height: 210,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              width: 300,
              child: TextField(
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    Icons.person_outline,
                    color: Colors.white,
                  ),
                  hintStyle: TextStyle(color: Colors.white),
                  border: UnderlineInputBorder(),
                  hintText: 'Username',
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: 300,
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                  ),
                  hintStyle: TextStyle(color: Colors.white),
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
                GestureDetector(
                  onTap: () {},
                  child: Text('Forgot password?'),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            RaisedButton(
              child: Text(
                "        LOG IN        ",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              color: Colors.white,
              onPressed: () {},
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(75),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 130,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                registerAccountButton(context);
              },
              child: Text(
                'Don\'t have an account?',
              ),
            ),
            GestureDetector(
              onTap: () {
                registerAccountButton(context);
              },
              child: Text(
                ' SIGN UP',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 40,
        )
      ],
    );
  }

  void registerAccountButton(BuildContext context) {
    Navigator.of(context).pushNamed('/register');
  }
}
