import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:jashan/data/track.dart';
import 'package:jashan/data/track_queue_item.dart';
import 'package:jashan/data/user.dart';
import 'package:jashan/util/jashan_queue_list.dart';
import 'package:jashan/widgets/track_card.dart';

class PartyPageSearching extends StatefulWidget {
  final JashanUser partyOwner;
  final QueueList<TrackQueueItem> queue;
  final Function(TrackQueueItem trackQueueItem) onAddSong;
  final Map<String, JashanQueueList<String>> votes;
  final Map<String, JashanQueueList<String>> downvotes;

  PartyPageSearching(this.partyOwner, this.queue, this.votes, this.downvotes, this.onAddSong);

  @override
  State<StatefulWidget> createState() {
    return _PartyPageSearchingState();
  }
}

class _PartyPageSearchingState extends State<PartyPageSearching> {
  String _searchQuery = "";
  List<Track> _searchItems = List<Track>();
  List<Track> _recommendedItems = List<Track>();
  TextEditingController _searchQueryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    int totalVotes = 0;
    final int minimumVotesForRecommendations = 5;
    widget.votes.values.forEach((list) {
      totalVotes += list.length;
    });
    if (totalVotes >= minimumVotesForRecommendations) {
      populateRecommendations();
    }
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
            _searchQuery = searchQuery;
            if (searchQuery.length > 2) {
              _searchItems.clear();
              _repopulateSearchList(searchQuery);
            }
          },
          onChanged: (searchQuery) {
            _searchQuery = searchQuery;
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
        itemCount: _searchQuery.length < 2 ? _recommendedItems.length + 1 : _searchItems.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Text(_searchQuery.length < 2 ? "Recommended Songs" : "Search Results", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),),
            );
          }
          final Track data = _searchQuery.length < 2 ? _recommendedItems[index - 1] : _searchItems[index - 1];
          return TrackCard(
            data: data,
            onClick: () => _addTrackToQueue(data),
            titleChars: 34,
            artistChars: 37,
          );
        },
      ),
    );
  }

  void _addTrackToQueue(Track track) {
    final TrackQueueItem queueItem = TrackQueueItem.fromTrack(track, addedBy: widget.partyOwner.username, addedTimeStamp: new DateTime.now().millisecondsSinceEpoch);
    widget.onAddSong(queueItem);
  }

  Future _repopulateSearchList(String searchQuery) async {
    Response queryResponse = await get(
        'https://api.spotify.com/v1/search?q="$searchQuery"&type=track',
        headers: {'Authorization': 'Bearer ${widget.partyOwner.accessToken}'});
    List items = json.decode(queryResponse.body)['tracks']['items'];
    if (mounted) {
      return setState(() {
        items.forEach((result) {
          String imageUrl = result['album']['images'][0]['url'];
          String uri = result['uri'];
          String name = result['name'];
          int durationMs = result['duration_ms'];
          List artists = result['artists'];
          String artistsString = artists[0]['name'];
          for (int i = 1; i < artists.length; i++) {
            artistsString += ', ${artists[i]['name']}';
          }
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

  void populateRecommendations() async {
    Response recommendationsResponse = await post('https://us-central1-jashan.cloudfunctions.net/recommendations_updated',
        headers: {
          'Content-Type': 'application/json',
        },
        body: '''
      {
        "token": "${widget.partyOwner.accessToken}",
        "upvotes_for_user": ${widget.votes.toString()},
        "downvotes_for_user": ${widget.downvotes.toString()}
      }
      ''');
    List<String> trackUris = recommendationsResponse.body.replaceAll("'", "").split(",");
    trackUris.forEach((String uri) async {
      String id = uri.split(":")[2];
      Response songInfoResponse = await get('https://api.spotify.com/v1/tracks/$id',
          headers: {'Authorization': 'Bearer ${widget.partyOwner.accessToken}'});
      Map songInfo = json.decode(songInfoResponse.body);
      if (songInfo['album'].containsKey('image')) {
        String imageUrl = songInfo['album']['images'][0]['url'];
        String name = songInfo['name'];
        int durationMs = songInfo['duration_ms'];
        List artists = songInfo['artists'];
        String artistsString = artists[0]['name'];
        for (int i = 1; i < artists.length; i++) {
          artistsString += ', ${artists[i]['name']}';
        }
        setState(() {
          _recommendedItems.add(
            Track(
                thumbnail: Image.network(imageUrl),
                thumbnailUrl: imageUrl,
                title: name,
                artist: artistsString,
                uri: uri,
                durationMs: durationMs),
          );
        });
      }
    });
  }
}
