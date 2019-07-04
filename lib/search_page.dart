import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jashan/user.dart';

class SearchPage extends StatefulWidget {
  JashanUser user;

  SearchPage(this.user);

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  Widget _appBarTitle = Container();
  bool _searching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: _appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: _searching ? Icon(Icons.close) : Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              setState(() {
                _searching = !_searching;
                if (_searching) {
                  _appBarTitle = TextField(
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      hintText: "Search...",
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  _appBarTitle = Container();
                }
              });
            },
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: Container(),
    );
  }
}
