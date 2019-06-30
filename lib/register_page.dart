import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jashan/page.dart';

class RegisterPage extends FrontPage {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        SizedBox(
          height: 150,
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
                    CupertinoIcons.person,
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
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    CupertinoIcons.mail,
                    color: Colors.white,
                  ),
                  hintStyle: TextStyle(color: Colors.white),
                  border: UnderlineInputBorder(),
                  hintText: 'Email',
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
                    CupertinoIcons.padlock,
                    color: Colors.white,
                  ),
                  hintStyle: TextStyle(color: Colors.white),
                  border: UnderlineInputBorder(),
                  hintText: 'Password',
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
                    CupertinoIcons.padlock,
                    color: Colors.white,
                  ),
                  hintStyle: TextStyle(color: Colors.white),
                  border: UnderlineInputBorder(),
                  hintText: 'Confirm password',
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            RaisedButton(
              child: Text(
                "        SIGN UP        ",
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
      ],
    );
  }
}
