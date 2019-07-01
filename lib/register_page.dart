import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jashan/page.dart';

class RegisterPage extends FrontPage {
  @override
  State<StatefulWidget> createState() {
    return RegisterPageState();
  }
}

class RegisterPageState extends State<RegisterPage> {
  String _username;
  String _password;
  String _passwordConfirmed;
  String _email;

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
                onChanged: (username) => _username = username,
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
                onChanged: (email) => _email = email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    Icons.alternate_email,
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
                onChanged: (password) => _password = password,
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
            SizedBox(
              height: 10,
            ),
            Container(
              width: 300,
              child: TextField(
                onChanged: (passwordConfirmed) =>
                    _passwordConfirmed = passwordConfirmed,
                obscureText: true,
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    Icons.lock_outline,
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
              onPressed: () {
                signUp(context);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(75),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future signUp(BuildContext context) async {
    if (_password == _passwordConfirmed) {
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password);
        Navigator.pushReplacementNamed(context, '/');
      } catch (e) {
        print(e.message);
      }
    }
  }
}
