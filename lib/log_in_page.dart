import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart';
import 'package:jashan/front_page.dart';
import 'package:jashan/home_page.dart';
import 'package:jashan/register_page.dart';
import 'package:jashan/user.dart';

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
            SizedBox(
              width: 200,
              child: RaisedButton(
                child: Text(
                  "LOG IN",
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
            ),
            SizedBox(
              height: 5,
            ),
            SizedBox(
              width: 200,
              child: RaisedButton(
                child: Text(
                  "LOG IN WITH SPOTIFY",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                color: Colors.green,
                onPressed: () {
                  _logInWithSpotify(context);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(75),
                ),
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
    _formKey.currentState.save();
    _verifyUsername();
    _verifyPassword();
    if (_formKey.currentState.validate()) {
      try {
        String email;
        if (_username.contains('@')) {
          email = _username;
        } else {
          QuerySnapshot snapshot = await Firestore.instance
              .collection('users')
              .where('username', isEqualTo: _username)
              .getDocuments();
          if (snapshot.documents.isEmpty) {
            _usernameVerification =
                'An account with that username does not exist.';
            _passwordVerification = null;
            _formKey.currentState.validate();
            return;
          } else {
            var data = snapshot.documents.removeLast();
            email = data.data['email'];
          }
        }
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: _password);
        JashanUser jashanUser = JashanUser(username: _username);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(jashanUser),
          ),
        );
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
    if (_username.isEmpty) {
      _usernameVerification = 'The username cannot be blank.';
    } else {
      _usernameVerification = null;
    }
  }

  void _verifyPassword() {
    if (_password.isEmpty) {
      _passwordVerification = 'The password cannot be blank.';
    } else {
      _passwordVerification = null;
    }
  }

  void _logInWithSpotify(BuildContext context) async {
    const String CLIENT_ID = '13734e89943a4249864bb67a9fdd3f9f';
    const String CLIENT_SECRET = 'f4046fa141c24926b3ee730529ffcf2b';
    const String RESPONSE_TYPE = 'code';
    const String REDIRECT_URI = 'https://google.com';
    final String scope =
        Uri.encodeFull('user-modify-playback-state user-read-email');
    const bool DEBUG = false;
    // todo add a state

    FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();
    flutterWebviewPlugin
        .launch('https://accounts.spotify.com/authorize?client_id=$CLIENT_ID'
            '&response_type=$RESPONSE_TYPE&redirect_uri=$REDIRECT_URI'
            '&scope=$scope&show_dialog=$DEBUG}');
    flutterWebviewPlugin.onUrlChanged.listen((String url) async {
      if (url.contains('?code=')) {
        final String code =
            url.substring(url.indexOf('?code=') + '?code='.length);
        flutterWebviewPlugin.close();
        const String GRANT_TYPE = 'authorization_code';
        Map<String, dynamic> body = {
          "grant_type": GRANT_TYPE,
          "code": code,
          "redirect_uri": REDIRECT_URI
        };
        Response accessTokenResponse =
            await post('https://accounts.spotify.com/api/token',
                headers: {
                  'Content-Type': 'application/x-www-form-urlencoded',
                  'Authorization':
                      'Basic ${base64.encode(utf8.encode('$CLIENT_ID:$CLIENT_SECRET'))}'
                },
                body: body);

        if (accessTokenResponse.statusCode == 200) {
          Map valueMap = json.decode(accessTokenResponse.body);
          print(valueMap);

          Response userProfileResponse =
              await get('https://api.spotify.com/v1/me', headers: {
            'Authorization': 'Bearer ${valueMap['access_token']}',
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          });
          Map userProfile = json.decode(userProfileResponse.body);

          print(userProfile);
          QuerySnapshot snapshot = await Firestore.instance
              .collection('users')
              .where('email', isEqualTo: userProfile['email'])
              .getDocuments();
          JashanUser jashanUser;
          if (snapshot.documents.isNotEmpty) {
            var data = snapshot.documents.removeLast();
            jashanUser = JashanUser(username: data.data['username']);
          } else {
            String username = userProfile['email']
                .substring(0, userProfile['email'].indexOf('@'));
            RegisterPage.signUp(username, userProfile['email'],
                '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8');
            jashanUser = JashanUser(username: username);
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(jashanUser),
            ),
          );

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
      }
    });
  }
}
