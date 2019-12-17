import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:jashan/data/party_info.dart';
import 'package:jashan/data/user.dart';
import 'package:jashan/util/visual_utilities.dart';
import 'package:jashan/widgets/track_card.dart';

class EndPartyPage extends StatelessWidget {
  final PartyInfo _partyInfo;
  final JashanUser user;

  EndPartyPage(this._partyInfo, {@required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text('Party Finished'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: ListView(
          children: <Widget>[
            Center(
              child: AutoSizeText(
                _partyInfo.title,
                maxLines: 1,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return TrackCard(
                      data: _partyInfo.songs[index],
                      titleChars: 32,
                      artistChars: 35,
                    );
                  },
                  itemCount: _partyInfo.songs.length,
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                height: 50,
                child: RaisedButton(
                  child: Text(
                    "SAVE PLAYLIST",
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 28,
                    ),
                  ),
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(75),
                  ),
                  onPressed: () => _saveParty(context),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                height: 50,
                child: RaisedButton(
                  child: Text(
                    "DELETE",
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 28,
                    ),
                  ),
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(75),
                  ),
                  onPressed: () => _deleteParty(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteParty(BuildContext context) {
    Navigator.pop(context);
  }

  void _saveParty(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _NewPlaylistNameDialog(_partyInfo, user: user);
      },
    );
  }
}

class _NewPlaylistNameDialog extends StatefulWidget {
  PartyInfo _partyInfo;
  JashanUser user;

  _NewPlaylistNameDialog(this._partyInfo, {@required this.user});

  @override
  State<StatefulWidget> createState() {
    return _NewPlaylistNameDialogState();
  }
}

class _NewPlaylistNameDialogState extends State<_NewPlaylistNameDialog> {
  String _titleValidator;
  String _newTitle;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Name Your Playlist",
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          initialValue: widget._partyInfo.title,
          validator: (username) {
            return _titleValidator;
          },
          onSaved: (newTitle) => _newTitle = newTitle,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text(
            "OK",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          onPressed: () async {
            _formKey.currentState.save();
            if (_newTitle.isEmpty) {
              _titleValidator = "The title cannot be blank.";
              _formKey.currentState.validate();
              return;
            } else {
              _titleValidator = null;
            }
            if (_formKey.currentState.validate()) {
              Map<String, dynamic> playlistRequest = _createPlaylistRequest();
              String request = json.encode(playlistRequest);
              showLoadingDialog(context);
              // todo check if spotify account is synced!
              Response response = await post(
                "https://api.spotify.com/v1/me/playlists",
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer ${widget.user.accessToken}'
                },
                body: request,
              );
              Map playlistObject = json.decode(response.body);
              String id = playlistObject['id'];
              String uris = getUrisString();
              Response r = await post(
                "https://api.spotify.com/v1/playlists/$id/tracks",
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer ${widget.user.accessToken}'
                },
                body: '{"uris":$uris}',
              );
              print(json.encode({
                'uris': uris,
              }));
              print(r.body);
              Navigator.pop(context);
            }
            Navigator.pop(context);
//            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Map<String, dynamic> _createPlaylistRequest() {
    Map<String, dynamic> playlistRequest = new Map();
    playlistRequest['name'] = _newTitle;
    // todo private
    // todo description?
    return playlistRequest;
  }

  String getUrisString() {
    String result = "[";
    widget._partyInfo.songs.forEach((song) {
      result += '"${song.uri}"';
      if (song != widget._partyInfo.songs.last) {
        result += ',';
      }
    });
    result += ']';
    return result;
  }
}
