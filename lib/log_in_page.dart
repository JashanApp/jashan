import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart';
import 'package:jashan/front_page.dart';
import 'package:jashan/home_page.dart';

class LogInPage extends FrontPage {
  @override
  State<StatefulWidget> createState() {
    return LogInPageState();
  }
}

class LogInPageState extends State<LogInPage> {
  String _username;
  String _password;
  String _usernameVerification;
  String _passwordVerification;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    width: 300,
                    child: TextFormField(
                      validator: (username) {
                        return _usernameVerification;
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
                      validator: (password) {
                        return _passwordVerification;
                      },
                      controller: _passwordController,
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
                ],
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
              onPressed: () {
                _logIn(context);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(75),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            RaisedButton(
              child: Text(
                "  LOG IN WITH SPOTIFY  ",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              color: Colors.white,
              onPressed: () {
                _logInWithSpotify(context);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(75),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    _registerAccountButton(context);
                  },
                  child: Text(
                    'Don\'t have an account?',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _registerAccountButton(context);
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
          ],
        ),
      ),
    );
  }

  void _registerAccountButton(BuildContext context) {
    Navigator.of(context).pushNamed('/register');
  }

  Future _logIn(BuildContext context) async {
    _verifyUsername();
    _verifyPassword();
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        QuerySnapshot snapshot = await Firestore.instance
            .collection('users')
            .where('username', isEqualTo: _username)
            .getDocuments();
        if (snapshot.documents.isEmpty) {
          _usernameVerification =
              'An account with that username does not exist.';
          _passwordVerification = null;
          _formKey.currentState.validate();
        } else {
          var data = snapshot.documents.removeLast();
          FirebaseUser user = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                  email: data.data['email'], password: _password);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(user),
            ),
          );
        }
      } catch (e) {
        if (e.code == 'ERROR_WRONG_PASSWORD') {
          _usernameVerification = null;
          _passwordVerification = 'The password inputted is incorrect.';
          _formKey.currentState.validate();
        }
        print(e.message);
      }
    }
  }

  void _verifyUsername() {
    if (_usernameController.text.isEmpty) {
      _usernameVerification = 'The username cannot be blank.';
    } else {
      _usernameVerification = null;
    }
  }

  void _verifyPassword() {
    if (_passwordController.text.isEmpty) {
      _passwordVerification = 'The password cannot be blank.';
    } else {
      _passwordVerification = null;
    }
  }

  void _logInWithSpotify(BuildContext context) {
    const String CLIENT_ID = '13734e89943a4249864bb67a9fdd3f9f';
    const String CLIENT_SECRET = 'f4046fa141c24926b3ee730529ffcf2b';
    const String RESPONSE_TYPE = 'code';
    const String REDIRECT_URI = 'https://google.com';
    const String SCOPE = 'user-modify-playback-state';
    const bool DEBUG = false;
    // todo add a state

    FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();
    flutterWebviewPlugin
        .launch('https://accounts.spotify.com/authorize?client_id=$CLIENT_ID'
            '&response_type=$RESPONSE_TYPE&redirect_uri=$REDIRECT_URI'
            '&scope=$SCOPE&show_dialog=$DEBUG}');
    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (url.contains('?code=')) {
        final String code =
            url.substring(url.indexOf('?code=') + '?code='.length);
        print(code);
        flutterWebviewPlugin.close();
        const String GRANT_TYPE = 'authorization_code';
        Map<String, dynamic> body = {
          "grant_type": GRANT_TYPE,
          "code": code,
          "redirect_uri": REDIRECT_URI
        };
        post('https://accounts.spotify.com/api/token',
                headers: {
                  'Content-Type': 'application/x-www-form-urlencoded',
                  'Authorization':
                      'Basic ${base64.encode(utf8.encode('$CLIENT_ID:$CLIENT_SECRET'))}'
                },
                body: body)
            .then((response) {
          if (response.statusCode == 200) {
            Map valueMap = json.decode(response.body);
            print(valueMap);

            // get list of playlists:
            /*get('https://api.spotify.com/v1/me/playlists', headers: {
              'Authorization':
                  'Bearer ${valueMap['access_token']}'
            }).then((response2) {
              Map playlistsResult = json.decode(response2.body);
              List<dynamic> test = playlistsResult['items'];
              test.forEach((thing) {
                print(thing['name']);
              });
            });*/

            // search songs:
            /*get('https://api.spotify.com/v1/search?q="That\'s All She Wrote"&type=track', headers: {
              'Authorization':
              'Bearer ${valueMap['access_token']}'
            }).then((response2) {
              print(response2.body);
            });*/

            // play song:
            /*put('https://api.spotify.com/v1/me/player/play',
                    headers: {
                      'Authorization': 'Bearer ${valueMap['access_token']}',
                      'Content-Type': 'application/json',
                      'Accept': 'application/json'
                    },
                    body: '{'
                        '"context_uri": "spotify:album:5ht7ItJgpBH7W6vJ5BqpPr",'
                        '"offset": {"position": 5},'
                        '"position_ms": 0'
                        '}')
                .then((response2) {
              print(response2.body);
            });*/
          }
        });
      }
    });
  }
}
