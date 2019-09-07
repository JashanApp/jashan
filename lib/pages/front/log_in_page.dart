import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart';
import 'package:jashan/data/user.dart';
import 'package:jashan/pages/front/front_page.dart';
import 'package:jashan/pages/front/register_page.dart';
import 'package:jashan/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _rememberMe = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    attemptInitialLogin();
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Image.asset("assets/images/jashan_white.png"),
            SizedBox(
              height: 50,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextFormField(
                      validator: (username) {
                        return _usernameVerification;
                      },
                      onSaved: (username) => _username = username,
                      decoration: InputDecoration(
                        suffixIcon: Icon(
                          Icons.person_outline,
                          color: Theme.of(context).accentColor,
                        ),
                        hintStyle:
                            TextStyle(color: Theme.of(context).accentColor),
                        border: UnderlineInputBorder(),
                        hintText: 'Username',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextFormField(
                      validator: (password) {
                        return _passwordVerification;
                      },
                      onSaved: (password) => _password = password,
                      obscureText: true,
                      decoration: InputDecoration(
                        suffixIcon: Icon(
                          Icons.lock_outline,
                          color: Theme.of(context).accentColor,
                        ),
                        hintStyle:
                            TextStyle(color: Theme.of(context).accentColor),
                        border: UnderlineInputBorder(),
                        hintText: 'Password',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.1,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Checkbox(
                        onChanged: (bool value) =>
                            setState(() => _rememberMe = !_rememberMe),
                        value: _rememberMe,
                        activeColor: Colors.black,
                      ),
                      Text('Remember me'),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: InkWell(
                      onTap: () {},
                      child: Text('Forgot password?'),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: RaisedButton(
                child: Text(
                  "LOG IN",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                color: Theme.of(context).accentColor,
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
              width: MediaQuery.of(context).size.width / 2,
              child: RaisedButton(
                child: Text(
                  "LOG IN WITH SPOTIFY",
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                color: Colors.green,
                onPressed: () => _logInWithSpotify(context),
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
                InkWell(
                  onTap: () => _registerAccountButton(context),
                  child: Text(
                    'Don\'t have an account?',
                  ),
                ),
                InkWell(
                  onTap: () => _registerAccountButton(context),
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
        if (_rememberMe) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('email', email);
          prefs.setString('password', _password);
          prefs.setString('username', _username);
          prefs.setBool('spotify', false);
        }
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
    final String scope = Uri.encodeFull(
        'user-read-playback-state user-modify-playback-state user-read-email playlist-modify-private playlist-modify-public');
    const bool DEBUG = false;
    // todo add a state

    FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();
    flutterWebviewPlugin.launch(
        'https://accounts.spotify.com/authorize?client_id=$CLIENT_ID'
        '&response_type=$RESPONSE_TYPE&redirect_uri=$REDIRECT_URI'
        '&scope=$scope&show_dialog=$DEBUG}',
        userAgent:
            'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36');
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
          Map token = json.decode(accessTokenResponse.body);

          Response userProfileResponse =
              await get('https://api.spotify.com/v1/me', headers: {
            'Authorization': 'Bearer ${token['access_token']}',
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          });
          Map userProfile = json.decode(userProfileResponse.body);
          QuerySnapshot snapshot = await Firestore.instance
              .collection('users')
              .where('email', isEqualTo: userProfile['email'])
              .getDocuments();
          String username;
          JashanUser jashanUser;
          String defaultSpotifyPassword =
              '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8';
          if (snapshot.documents.isNotEmpty) {
            var data = snapshot.documents.removeLast();
            username = data.data['username'];
          } else {
            String usernameParsedFromEmail = userProfile['email']
                .substring(0, userProfile['email'].indexOf('@'));
            RegisterPage.signUp(usernameParsedFromEmail, userProfile['email'],
                defaultSpotifyPassword);
            username = usernameParsedFromEmail;
          }
          jashanUser = JashanUser(username: username);
          if (_rememberMe) {
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            prefs.setString('email', userProfile['email']);
            prefs.setString('password', defaultSpotifyPassword);
            /* todo fix the above code from the fact that it will not work when
              users make existing accounts linked with spotify and log in
              with spotify after doing that, or if a user who registered
              using spotify changes their password */
            prefs.setString('username', username);
            prefs.setBool('spotify', true);
          }
          jashanUser.accessToken = token['access_token'];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(jashanUser),
            ),
          );
        }
      }
    });
  }

  Future attemptInitialLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email');
    String password = prefs.getString('password');
    String username = prefs.getString('username');
    bool spotify = prefs.getBool('spotify');
    if (email != null && password != null && username != null) {
      if (spotify) {
        _logInWithSpotify(context);
      } else {
        try {
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
          JashanUser jashanUser = JashanUser(username: username);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(jashanUser),
            ),
          );
        } catch (e) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'There was an error when logging in with your saved credentials (' +
                      e.code +
                      ').'),
            ),
          );
          print(e.message);
        }
      }
    }
  }
}
