import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:jashan/data/track.dart';
import 'package:jashan/data/track_queue_item.dart';
import 'package:jashan/data/user.dart';
import 'package:jashan/util/text_utilities.dart';
import 'package:jashan/widgets/track_card.dart';

class PartyPageSearching extends StatefulWidget {
  final JashanUser user;
  final QueueList<TrackQueueItem> queue;
  final Function(TrackQueueItem trackQueueItem) onAddSong;

  PartyPageSearching(this.user, this.queue, this.onAddSong);

  @override
  State<StatefulWidget> createState() {
    return _PartyPageSearchingState();
  }
}

class _PartyPageSearchingState extends State<PartyPageSearching> {
  List<Track> _searchItems = List<Track>();
  TextEditingController _searchQueryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('call');
    post('https://us-central1-jashan.cloudfunctions.net/recommendations_updated',
      headers: {
        'Content-Type': 'application/json',
      },
      body: '''
      {
        "token": "${widget.user.accessToken}",
        "upvotes_for_user": {
          "5": ["spotify:track:5xS9hkTGfxqXyxX6wWWTt4", "spotify:track:70cTMpcgWMcR18t9MRJFjB"],
          "167": ["spotify:track:6U8EShYiwNNrGogCxTeFm2", "spotify:track:5LxQohFfm9A4V1VSTS1RDG", "spotify:track:1dD1aarWotVIiFo5gGdMc2"],
          "192": ["spotify:track:0ESJlaM8CE1jRWaNtwSNj8", "spotify:track:5w1vhNA2OEWUQ371QzyMmM", "spotify:track:2ZBfTcQM9S3yTLKhHrvCnQ", "spotify:track:2Fe6gDE0mCZz0g98i5QpVL", "spotify:track:3a1lNhkSLSkpJE4MSHpDu9"],
          "306": ["spotify:track:7wGoVu4Dady5GV0Sv4UIsx", "spotify:track:77IAeEz8LEchPN8UNjaTJ2", "spotify:track:1vvnYpYEMVB4aq9I6tHIEB", "spotify:track:16qYlQ6koFxYVbiJbGHblz", "spotify:track:2fQrGHiQOvpL9UgPvtYy6G"],
          "467": ["spotify:track:1ffRRgFiA0uVMHsjR8Ksuf"],
          "472": ["spotify:track:6XK6Zw6JkFsHXzAcMWNiIr", "spotify:track:00DYRuYJQzfI6dH4Adkimo", "spotify:track:748pETtPvRIotGU9N3FgXH"],
          "516": ["spotify:track:4htbAEZWr53J08x3dUv00W", "spotify:track:455HSLQfOn9vxG6UjzoTWw", "spotify:track:0WqIKmW4BTrj3eJFmnCKMv"],
          "648": ["spotify:track:24cKN8P2uGWypxTw5WaNlq", "spotify:track:6miou5rcSI3TqJWTKizJJI", "spotify:track:69uJi5QsBtqlYkGURTBli8", "spotify:track:3Pr70knS8uTSiKbwf4rGav", "spotify:track:5Q30xdABnojqN3wBIhrsQp"],
          "731": ["spotify:track:26NQzsYvTbSutlj2i4ILXW", "spotify:track:4iMwTDfXQDdEWyI1dtx9K8"],
          "797": ["spotify:track:6875MeXyCW0wLyT72Eetmo", "spotify:track:1n8ZUpQ0iVY6gVBgEUdA2Q", "spotify:track:1UZOjK1BwmwWU14Erba9CZ", "spotify:track:5WSdMcWTKRdN1QYVJHJWxz"]
        }
      }
      ''').then((response) {
        print(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).primaryColor,
        title: TextField(
          autocorrect: false,
          controller: _searchQueryController,
          onSubmitted: (searchQuery) {
            if (searchQuery.length > 2) {
              _searchItems.clear();
              _repopulateSearchList(searchQuery);
            }
          },
          style: TextStyle(
            color: Theme.of(context).accentColor,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Theme.of(context).accentColor),
            hintText: "Search...",
            hintStyle: TextStyle(color: Theme.of(context).accentColor),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _searchItems.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return SizedBox(
              height: 10,
            );
          }
          final Track data = _searchItems[index - 1];
          return TrackCard(
            data: data,
            onClick: () => _addTrackToQueue(data),
          );
        },
      ),
    );
  }

  void _addTrackToQueue(Track track) {
    final TrackQueueItem queueItem = TrackQueueItem.fromTrack(track, addedBy: widget.user.username);
    widget.onAddSong(queueItem);
  }

  Future _repopulateSearchList(String searchQuery) async {
    Response queryResponse = await get(
        'https://api.spotify.com/v1/search?q="$searchQuery"&type=track',
        headers: {'Authorization': 'Bearer ${widget.user.accessToken}'});
    List items = json.decode(queryResponse.body)['tracks']['items'];
    if (mounted) {
      return setState(() {
        items.forEach((result) {
          String imageUrl = result['album']['images'][0]['url'];
          String uri = result['uri'];
          String name = result['name'];
          int durationMs = result['duration_ms'];
          name = getTextWithCap(name, 34);
          List artists = result['artists'];
          String artistsString = artists[0]['name'];
          for (int i = 1; i < artists.length; i++) {
            artistsString += ', ${artists[i]['name']}';
          }
          artistsString = getTextWithCap(artistsString, 37);
          _searchItems.add(
            Track(
                thumbnail: Image.network(imageUrl),
                thumbnailUrl: imageUrl,
                title: name,
                artist: artistsString,
                uri: uri,
                durationMs: durationMs),
          );
        });
      });
    }
  }
}
