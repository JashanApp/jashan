import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:jashan/user.dart';

class StartPartyPage extends StatefulWidget {
  final JashanUser user;

  StartPartyPage(this.user);

  @override
  State<StatefulWidget> createState() {
    return _StartPartyPageState();
  }
}

class _StartPartyPageState extends State<StartPartyPage> {
  String _selectedText = '';
  String _dropdownValue = '';

  final TextEditingController _createTextController = TextEditingController();
  final List<String> _playlistSongs = new List<String>();

  @override
  void initState() {
    super.initState();
    _playlistSongs.add('');
    get('https://api.spotify.com/v1/me/playlists',
            headers: {'Authorization': 'Bearer ${widget.user.accessToken}'})
        .then((response2) {
      setState(() {
        Map playlistsResult = json.decode(response2.body);
        List<dynamic> test = playlistsResult['items'];
        test.forEach((thing) {
          _playlistSongs.add(thing['name']);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Party'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                ),
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<String>(
                      value: _dropdownValue,
                      onChanged: (String newValue) {
                        setState(() {
                          _dropdownValue = newValue;
                          if (_dropdownValue == '') {
                            _selectedText = _createTextController.text;
                          } else {
                            _selectedText = newValue;
                          }
                        });
                      },
                      items: _playlistSongs.map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  'or',
                  style: TextStyle(
                    fontWeight: FontWeight.w100,
                    color: Colors.black,
                    fontSize: 28,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                onChanged: (playlistName) {
                  if (_dropdownValue == '') {
                    setState(() {
                      _selectedText = playlistName;
                    });
                  }
                },
                style: TextStyle(
                  color: Colors.black,
                ),
                controller: _createTextController,
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(),
                  hintText: 'Create New Playlist Name',
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Divider(),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      _selectedText,
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: 65,
                        child: RaisedButton(
                          child: Text(
                            "Start Party!",
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
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
