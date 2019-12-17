import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:jashan/data/party_info.dart';
import 'package:jashan/data/track.dart';
import 'package:jashan/data/user.dart';
import 'package:jashan/pages/party/party_page.dart';
import 'package:jashan/widgets/track_card.dart';

class StartPartyPage extends StatefulWidget {
  final JashanUser user;

  StartPartyPage(this.user);

  @override
  State<StatefulWidget> createState() {
    return _StartPartyPageState();
  }
}

class _StartPartyPageState extends State<StartPartyPage> {
  static String defaultDropboxText = 'Select an Existing Playlist';

  String _selectedText = '';
  String _dropdownValue = defaultDropboxText;

  final TextEditingController _createTextController = TextEditingController();
  final Map<String, String> _idForPlaylist = new Map<String, String>();
  final List<Track> _tracks = List<Track>();
  final GlobalKey scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _idForPlaylist[_StartPartyPageState.defaultDropboxText] = null;
    get('https://api.spotify.com/v1/me/playlists',
            headers: {
              'Authorization': 'Bearer ${widget.user.accessToken}',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            })
        .then((response) {
      setState(() {
        Map playlistsResult = json.decode(response.body);
        List<dynamic> playlists = playlistsResult['items'];
        playlists.forEach((playlist) {
          _idForPlaylist[playlist['name']] = playlist['id'];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      iconTheme: Theme.of(context).iconTheme,
      title: Text('Start Party'),
      backgroundColor: Theme.of(context).primaryColor,
    );
    double height = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top -
        kToolbarHeight;
    return Scaffold(
      appBar: appBar,
      key: scaffoldKey,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: height * 0.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton<String>(
                            value: _dropdownValue,
                            onChanged: (String newValue) =>
                                _onNewPlaylist(newValue),
                            items: _idForPlaylist.keys
                                .map<DropdownMenuItem<String>>(
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
                    TextField(
                      onChanged: (playlistName) {
                        if (_dropdownValue ==
                            _StartPartyPageState.defaultDropboxText) {
                          _onChangedNewName(playlistName);
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
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: height * 0.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        _selectedText,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: height * 0.65,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: height * 0.45,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: _tracks.isNotEmpty
                            ? ListView.builder(
                                itemBuilder: (BuildContext context, int index) {
                                  return TrackCard(
                                    data: _tracks[index],
                                    titleChars: 32,
                                    artistChars: 35,
                                  );
                                },
                                itemCount: _tracks.length,
                              )
                            : Center(
                                child: Text(
                                  'No songs!',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 65,
                        child: RaisedButton(
                          child: Text(
                            "Create Party!",
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 28,
                            ),
                          ),
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(75),
                          ),
                          onPressed: () => _createParty(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNewPlaylist(String newPlaylistName) {
    setState(() {
      _dropdownValue = newPlaylistName;
      if (_dropdownValue == _StartPartyPageState.defaultDropboxText) {
        _selectedText = _createTextController.text;
        _tracks.clear();
      } else {
        _selectedText = newPlaylistName;
        _populatePlaylistSongs();
      }
    });
  }

  void _onChangedNewName(String newPlaylistName) {
    setState(() {
      _tracks.clear();
      _selectedText = newPlaylistName;
    });
  }

  void _populatePlaylistSongs() {
    get('https://api.spotify.com/v1/playlists/${_idForPlaylist[_dropdownValue]}/tracks',
            headers: {'Authorization': 'Bearer ${widget.user.accessToken}'})
        .then((response) {
      setState(() {
        _tracks.clear();
        List tracks = json.decode(response.body)['items'];
        tracks.forEach((track) {
          Map trackInfo = track['track'];
          String imageUrl = trackInfo['album']['images'][0]['url'];
          String name = trackInfo['name'];
          int durationMs = trackInfo['duration_ms'];
          String uri = trackInfo['uri'];
          List artists = trackInfo['artists'];
          String artistsString = artists[0]['name'];
          for (int i = 1; i < artists.length; i++) {
            artistsString += ', ${artists[i]['name']}';
          }
          _tracks.add(
            Track(
              thumbnail: Image.network(imageUrl),
              thumbnailUrl: imageUrl,
              title: name,
              artist: artistsString,
              uri: uri,
              durationMs: durationMs,
            ),
          );
        });
      });
    });
  }

  void _createParty() async {
    if (_selectedText != '') {
      int partyId = await _createPartyId();
      var document =
      Firestore.instance.collection('parties').document('$partyId');
      document.setData({
        'owner_username': widget.user.username,
        'owner_access_token': widget.user.accessToken,
        'party_name': _selectedText,
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PartyPage(
                partyInfo: PartyInfo(
                  id: partyId,
                  title: _selectedText,
                  owner: widget.user,
                ),
                user: widget.user,
                initialTracks: _tracks,
              ),
        ),
      );
    } else {
      ScaffoldState scaffoldState = scaffoldKey.currentState;
      scaffoldState.showSnackBar(SnackBar(
        content: Text("You need to select a playlist or write a party name!"),
      ));
    }
  }

  Future<int> _createPartyId() async {
    final Random random = new Random();
    final int digits = 5;
    bool valid = false;
    int partyId;
    while (!valid) {
      partyId = pow(10, digits - 1) +
          random.nextInt(pow(10, digits) - pow(10, digits - 1));
      var snap = await Firestore.instance
          .collection('parties')
          .document('$partyId')
          .get();
      if (!snap.exists) {
        valid = true;
      }
    }
    return partyId;
  }
}
