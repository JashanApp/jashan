import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jashan/front_page.dart';

class RegisterPage extends FrontPage {
  @override
  State<StatefulWidget> createState() {
    return RegisterPageState();
  }
}

class RegisterPageState extends State<RegisterPage> {
  String _username;
  String _password;
  String _email;
  String _usernameValidation;
  String _emailValidation;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    width: 300,
                    child: TextFormField(
                      validator: (username) {
                        return _usernameValidation;
                      },
                      controller: _usernameController,
                      onSaved: (username) => _username = username,
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
                    child: TextFormField(
                      validator: (email) {
                        return _emailValidation;
                      },
                      controller: _emailController,
                      onSaved: (email) => _email = email,
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
                    child: TextFormField(
                      validator: (password) {
                        if (password.isEmpty) {
                          return 'Your password can\'t be blank.';
                        }
                        return null;
                      },
                      onSaved: (password) => _password = password,
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
                    child: TextFormField(
                      validator: (passwordConfirmed) {
                        if (passwordConfirmed.isEmpty) {
                          return 'Your password can\'t be blank.';
                        } else if (_password != passwordConfirmed) {
                          return 'Your passwords do not match each other.';
                        }
                        return null;
                      },
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
                ],
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
                _signUp(context);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _signUp(BuildContext context) async {
    await _validateUsername();
    await _validateEmail();
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password);
        Firestore.instance.collection('users').add(
          {
            'username': _username,
            'email': _email,
          },
        ).then(
          (result) {
            Navigator.pushReplacementNamed(context, '/');
          },
        );
      } catch (e) {
        print(e.message);
      }
    }
  }

  Future _validateUsername() async {
    if (_usernameController.text.isEmpty) {
      _usernameValidation = 'Your username can\'t be blank.';
    } else {
      bool usernameUsed = await _isUsed('username', _usernameController.text);
      if (usernameUsed) {
        _usernameValidation = 'That username is already in use.';
      } else {
        _usernameValidation = null;
      }
    }
  }

  Future _validateEmail() async {
    if (_emailController.text.isEmpty) {
      _emailValidation = 'Your email can\'t be blank.';
    } else {
      bool emailUsed = await _isUsed('email', _emailController.text);
      if (emailUsed) {
        _emailValidation = 'That email is already in use.';
      } else {
        _emailValidation = null;
      }
    }
  }

  Future<bool> _isUsed(String field, String value) async {
    QuerySnapshot snapshot = await Firestore.instance
        .collection('users')
        .where(field, isEqualTo: value)
        .getDocuments();
    if (snapshot.documents.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
