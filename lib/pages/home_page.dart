import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jashan/data/user.dart';
import 'package:jashan/pages/create_party_page.dart';
import 'package:jashan/pages/settings_page.dart';

class HomePage extends StatelessWidget {
  final JashanUser user;

  HomePage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SettingsPage(user),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.settings,
                              color: Colors.white,
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
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
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
                      width: MediaQuery.of(context).size.width / 2,
                      height: 50,
                      child: RaisedButton(
                        child: Text(
                          "HOST",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                        color: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(75),
                        ),
                        onPressed: () {
                          print(user.accessToken);
                          if (user.accessToken != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StartPartyPage(user),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      height: 50,
                      child: RaisedButton(
                        child: Text(
                          "CONNECT",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                        color: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(75),
                        ),
                        onPressed: () {},
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
}
