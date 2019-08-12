import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:jashan/pages/party/party_page.dart';
import 'package:jashan/data/playlist_item.dart';
import 'package:jashan/widgets/playlist_item_card.dart';
import 'package:jashan/data/user.dart';

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
  final List<PlaylistItem> _playlistItems = List<PlaylistItem>();

  @override
  void initState() {
    super.initState();
    _idForPlaylist[_StartPartyPageState.defaultDropboxText] = null;
    get('https://api.spotify.com/v1/me/playlists',
            headers: {'Authorization': 'Bearer ${widget.user.accessToken}'})
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
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
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
                          if (_dropdownValue ==
                              _StartPartyPageState.defaultDropboxText) {
                            _selectedText = _createTextController.text;
                          } else {
                            _selectedText = newValue;
                            _populatePlaylistSongs();
                          }
                        });
                      },
                      items: _idForPlaylist.keys.map<DropdownMenuItem<String>>(
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
                  if (_dropdownValue ==
                      _StartPartyPageState.defaultDropboxText) {
                    setState(() {
                      _playlistItems.clear();
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
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: _playlistItems.isNotEmpty
                            ? ListView.builder(
                                itemBuilder: (BuildContext context, int index) {
                                  return PlaylistItemCard(
                                    data: _playlistItems[index],
                                  );
                                },
                                itemCount: _playlistItems.length,
                              )
                            : Center(
                                child: Text(
                                  'No songs!',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        height: 65,
                        child: RaisedButton(
                          child: Text(
                            "Create Party!",
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PartyPage(_selectedText, widget.user),
                              ),
                            );
                          },
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

  void _populatePlaylistSongs() {
    get('https://api.spotify.com/v1/playlists/${_idForPlaylist[_dropdownValue]}/tracks',
            headers: {'Authorization': 'Bearer ${widget.user.accessToken}'})
        .then((response) {
      setState(() {
        _playlistItems.clear();
        List tracks = json.decode(response.body)['items'];
        tracks.forEach((track) {
          Map trackInfo = track['track'];
          String imageUrl = trackInfo['album']['images'][0]['url'];
          String name = trackInfo['name'];
          const int CAP = 35;
          name =
              '${name.substring(0, min(name.length, CAP))}${name.length > CAP ? '...' : ''}';
          List artists = trackInfo['artists'];
          String artistsString = artists[0]['name'];
          for (int i = 1; i < artists.length; i++) {
            artistsString += ', ${artists[i]['name']}';
          }
          artistsString =
              '${artistsString.substring(0, min(artistsString.length, CAP))}${artistsString.length > CAP ? '...' : ''}';
          _playlistItems.add(
            PlaylistItem(
              thumbnail: Image.network(imageUrl),
              title: name,
              artist: artistsString,
            ),
          );
        });
      });
    });
  }
}
