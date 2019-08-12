import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:jashan/playlist_item.dart';
import 'package:jashan/playlist_item_view.dart';
import 'package:jashan/sorted_queue_list.dart';
import 'package:jashan/user.dart';

class PartyPage extends StatefulWidget {
  final JashanUser user;
  final String playlistName;
  final QueueList<PlaylistQueueItem> queue = new SortedQueueList();

  PartyPage(this.playlistName, this.user);

  @override
  State<StatefulWidget> createState() {
    return _PartyPageState(queue);
  }
}

class _PartyPageState extends State<PartyPage> {
  bool searching = false;
  final QueueList<PlaylistQueueItem> queue;

  _PartyPageState(this.queue);

  @override
  Widget build(BuildContext context) {
    return searching
        ? _PartyPageSearching(this, widget.user, queue)
        : _PartyPageView(this, widget.playlistName, queue);
  }
}

class _PartyPageSearching extends StatefulWidget {
  final _PartyPageState partyPageState;
  final JashanUser user;
  final QueueList<PlaylistQueueItem> queue;

  _PartyPageSearching(this.partyPageState, this.user, this.queue);

  @override
  State<StatefulWidget> createState() {
    return _PartyPageSearchingState();
  }
}

class _PartyPageSearchingState extends State<_PartyPageSearching> {
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
              /* put(
                'https://api.spotify.com/v1/me/player/play',
                headers: {
                  'Authorization': 'Bearer ${widget.user.accessToken}',
                  'Content-Type': 'application/json',
                  'Accept': 'application/json'
                },
                body: '{'
                    '"uris": ["${data.uri}"]'
                    '}',
              ).then((response2) {
                print(response2.body);
              });*/
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
          ),
        );
      });
    });
  }
}

class _PartyPageView extends StatefulWidget {
  final _PartyPageState partyPageState;
  final String playlistName;
  final QueueList<PlaylistQueueItem> queue;

  _PartyPageView(this.partyPageState, this.playlistName, this.queue);

  @override
  State<StatefulWidget> createState() {
    return _PartyPageViewState();
  }
}

class _PartyPageViewState extends State<_PartyPageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: <Widget>[
          InkWell(
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onTap: () {
              widget.partyPageState.setState(() {
                widget.partyPageState.searching = true;
              });
            },
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Text(
                    widget.playlistName,
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.black),
            Container(
              height: 400, /* todo make this dynamic by using screen height */
              child: widget.queue.isNotEmpty
                  ? ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        return PlaylistQueueItemCard(
                          data: widget.queue[index],
                          onUpvoteChange: () {
                            setState(() {
                              widget.queue.sort();
                            });
                          },
                        );
                      },
                      itemCount: widget.queue.length,
                    )
                  : Center(
                      child: Text(
                        'No songs!',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
