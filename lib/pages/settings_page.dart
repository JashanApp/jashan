import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jashan/data/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  final JashanUser user;

  SettingsPage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        children: <Widget>[
          InkWell(
            onTap: () {
              _logOut(context);
            },
            child: ListTile(
              title: Text(
                'Log out',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _logOut(BuildContext context) async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();
    prefs.remove('username');
    prefs.remove('email');
    prefs.remove('password');
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/');
  }
}
