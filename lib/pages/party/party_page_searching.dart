import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:jashan/data/playlist_queue_item.dart';
import 'package:jashan/pages/party/party_page.dart';
import 'package:jashan/data/playlist_item.dart';
import 'package:jashan/widgets/playlist_item_card.dart';
import 'package:jashan/data/user.dart';

class PartyPageSearching extends StatefulWidget {
  final PartyPageState partyPageState;
  final JashanUser user;
  final QueueList<PlaylistQueueItem> queue;

  PartyPageSearching(this.partyPageState, this.user, this.queue);

  @override
  State<StatefulWidget> createState() {
    return _PartyPageSearchingState();
  }
}

class _PartyPageSearchingState extends State<PartyPageSearching> {
  List<PlaylistItem> _searchItems = List<PlaylistItem>();
  TextEditingController _searchQueryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.orange,
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
            color: Colors.white,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.white),
            hintText: "Search...",
            hintStyle: TextStyle(color: Colors.white),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            color: Colors.white,
            onPressed: () {
              widget.partyPageState.setState(() {
                widget.partyPageState.searching = false;
              });
            },
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _searchItems.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return SizedBox(
              height: 10,
            );
          }
          final PlaylistItem data = _searchItems[index - 1];
          return PlaylistItemCard(
            data: data,
            onClick: () {
              final PlaylistQueueItem queueItem =
              PlaylistQueueItem.fromPlaylistItem(data);
              widget.queue.add(queueItem);
            },
          );
        },
      ),
    );
  }

  Future _repopulateSearchList(String searchQuery) async {
    Response queryResponse = await get(
        'https://api.spotify.com/v1/search?q="$searchQuery"&type=track',
        headers: {'Authorization': 'Bearer ${widget.user.accessToken}'});
    List items = json.decode(queryResponse.body)['tracks']['items'];
    return setState(() {
      items.forEach((result) {
        String imageUrl = result['album']['images'][0]['url'];
        String uri = result['uri'];
        String name = result['name'];
        int durationMs = result['duration_ms'];
        const int CAP = 37;
        name =
        '${name.substring(0, min(name.length, CAP))}${name.length > CAP ? '...' : ''}';
        List artists = result['artists'];
        String artistsString = artists[0]['name'];
        for (int i = 1; i < artists.length; i++) {
          artistsString += ', ${artists[i]['name']}';
        }
        artistsString =
        '${artistsString.substring(0, min(artistsString.length, CAP))}${artistsString.length > CAP ? '...' : ''}';
        _searchItems.add(
          PlaylistItem(
            thumbnail: Image.network(imageUrl),
            title: name,
            artist: artistsString,
            uri: uri,
            durationMs: durationMs
          ),
        );
      });
    });
  }
}