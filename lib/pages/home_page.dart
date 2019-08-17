import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:jashan/data/user.dart';
import 'package:jashan/pages/create_party_page.dart';
import 'package:jashan/pages/settings_page.dart';

class HomePage extends StatelessWidget {
  final JashanUser user;
  final GlobalKey scaffoldKey = new GlobalKey();

  HomePage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/crowd.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height / 2,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                color: Colors.black.withOpacity(0.5),
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding:
                        EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _clickGear(context),
                            child: Icon(
                              Icons.settings,
                              color: Theme
                                  .of(context)
                                  .accentColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Image.asset('assets/images/jashan_white.png'),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height / 2,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: Column(
                  children: <Widget>[
                    Text(
                      'Welcome ${user.username}!',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width / 2,
                      height: 50,
                      child: RaisedButton(
                        child: Text(
                          "HOST",
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .accentColor,
                            fontSize: 28,
                          ),
                        ),
                        color: Theme
                            .of(context)
                            .primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(75),
                        ),
                        onPressed: () => _host(context),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width / 2,
                      height: 50,
                      child: RaisedButton(
                        child: Text(
                          "CONNECT",
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .accentColor,
                            fontSize: 28,
                          ),
                        ),
                        color: Theme
                            .of(context)
                            .primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(75),
                        ),
                        onPressed: () => _connect(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _host(BuildContext context) async {
    if (user.accessToken != null) {
      Response availableDevicesResponse = await get(
          'https://api.spotify.com/v1/me/player/devices',
          headers: {'Authorization': 'Bearer ${user.accessToken}'});
      List availableDevices = json.decode(availableDevicesResponse.body)['devices'];
      if (availableDevices.length > 0) {
        await put('https://api.spotify.com/v1/me/player',
            headers: {
              'Authorization': 'Bearer ${user.accessToken}',
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: '{'
              '"device_ids": ['
                '"${availableDevices[0]['id']}"'
              ']'
            '}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StartPartyPage(user),
          ),
        );
      } else {
        (scaffoldKey.currentState as ScaffoldState).showSnackBar(
          SnackBar(
            content: Text(
              "No active device with Spotify! Consider opening Spotify, then trying again.",
            ),
          ),
        );
      }
    } else {
      (scaffoldKey.currentState as ScaffoldState).showSnackBar(
        SnackBar(
          content: Text(
            "Can't detect your Spotify account! Consider linking your Spotify "
                "account, then trying again.",
          ),
        ),
      );
    }
  }

  void _connect() {

  }

  void _clickGear(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(user),
      ),
    );
  }
}
