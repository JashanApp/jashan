import 'dart:collection';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:jashan/data/track.dart';
import 'package:jashan/data/track_queue_item.dart';
import 'package:jashan/data/user.dart';
import 'package:jashan/pages/party/party_page_searching.dart';
import 'package:jashan/util/sorted_queue_list.dart';
import 'package:jashan/util/spotify_player.dart';
import 'package:jashan/util/text_utilities.dart';
import 'package:jashan/widgets/track_info_view.dart';
import 'package:jashan/widgets/track_queue_item_card.dart';

class PartyPage extends StatefulWidget {
  final JashanUser owner;
  final String name;
  DocumentReference partyReference;
  final int id;
  final List<Track> initialTracks;
  final JashanUser user;

  PartyPage(
      {@required this.id,
      @required this.name,
      @required this.owner,
      @required this.user,
      this.initialTracks}) {
    partyReference = Firestore.instance.collection('parties').document('$id');
  }

  @override
  State<StatefulWidget> createState() {
    return PartyPageState();
  }
}

class PartyPageState extends State<PartyPage> {
  final QueueList<TrackQueueItem> queue = new SortedQueueList();
  final Map<String, TrackQueueItem> songs = new HashMap();
  TrackQueueItem currentlyPlayingSong;
  SpotifyPlayer spotifyPlayer;

  void _addSongToQueue(DocumentSnapshot snapshot) {
    TrackQueueItem trackQueueItem =
        TrackQueueItem.fromDocumentReference(snapshot);
    songs[snapshot.data['uri']] = trackQueueItem;
    setState(() => queue.add(trackQueueItem));
    // todo if weird order, enforce async
  }

  void _addSong(TrackQueueItem trackQueueItem) {
    var songDocument =
        widget.partyReference.collection('tracks').document(trackQueueItem.uri);
    songDocument.setData({
      'thumbnail_url': trackQueueItem.thumbnailUrl,
      'title': trackQueueItem.title,
      'artist': trackQueueItem.artist,
      'uri': trackQueueItem.uri,
      'duration_ms': trackQueueItem.durationMs,
      'added_by': trackQueueItem.addedBy,
    });
    songDocument.collection('upvotes').snapshots().listen((data) {
      data.documentChanges.forEach((change) {
        String uri = trackQueueItem.uri;
        JashanUser user = new JashanUser(username: change.document.documentID);
        if (change.type == DocumentChangeType.added) {
          songs[uri].upvotes.add(user);
        } else if (change.type == DocumentChangeType.removed) {
          songs[uri].upvotes.remove(user);
        }
        setState(() => queue.sort());
      });
    });
    songDocument.collection('downvotes').snapshots().listen((data) {
      data.documentChanges.forEach((change) {
        String uri = trackQueueItem.uri;
        JashanUser user = new JashanUser(username: change.document.documentID);
        if (change.type == DocumentChangeType.added) {
          songs[uri].downvotes.add(user);
        } else if (change.type == DocumentChangeType.removed) {
          songs[uri].downvotes.remove(user);
        }
        setState(() => queue.sort());
      });
    });
  }

  @override
  void initState() {
    super.initState();
    spotifyPlayer = new SpotifyPlayer(
      user: widget.owner,
    );
    spotifyPlayer.setOnSongChange(() {
      setState(() {
        currentlyPlayingSong = queue.removeFirst();
        spotifyPlayer.playSong(currentlyPlayingSong);
      });
    });
    widget.partyReference.collection('tracks').snapshots().listen((data) {
      data.documentChanges.forEach((change) {
        var document = change.document;
        if (change.type == DocumentChangeType.added) {
          _addSongToQueue(document);
        }
      });
    });
    widget.initialTracks.forEach((item) {
      var trackQueueItem =
          new TrackQueueItem.fromTrack(item, addedBy: widget.owner.username);
      _addSong(trackQueueItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      iconTheme: Theme.of(context).iconTheme,
      actions: <Widget>[
        InkWell(
          child: Icon(Icons.add),
          onTap: () => _openSearch(),
        ),
        SizedBox(
          width: 20,
        ),
      ],
    );
    return Scaffold(
      appBar: appBar,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    getTextWithCap(widget.name, 16),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  Divider(color: Colors.black),
                ],
              ),
            ),
            Expanded(
              flex: 8,
              child: queue.isNotEmpty
                  ? ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        TrackQueueItem data;
                        if (currentlyPlayingSong == null) {
                          data = queue[index];
                        } else if (index == 0 && currentlyPlayingSong != null) {
                          data = currentlyPlayingSong;
                        } else if (index != 0 && currentlyPlayingSong != null) {
                          data = queue[index - 1];
                        }
                        return TrackQueueItemCard(
                          data: data,
                          onLongPress: () {
                            Color background = Colors.black.withOpacity(0.7);
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: background,
                                  content: TrackInfoView(appBar, data),
                                );
                              },
                            );
                          },
                          onUpvoteChange: (increase) =>
                              _onSongUpvote(index, data, increase),
                          isCurrentPlaying: data == currentlyPlayingSong,
                        );
                      },
                      itemCount:
                          queue.length + (currentlyPlayingSong == null ? 0 : 1),
                    )
                  : Center(
                      child: Text(
                        'No songs!',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2 - 12.5,
                    height: 50,
                    child: RaisedButton(
                      child: Text(
                        "Start Party",
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 20,
                        ),
                      ),
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(75),
                      ),
                      onPressed: _startParty,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onSongUpvote(int songIndex, TrackQueueItem data, bool increase) {
    if (songIndex != 0 || currentlyPlayingSong == null) {
      DocumentReference songDocument =
          widget.partyReference.collection('tracks').document(data.uri);
      CollectionReference vote = increase
          ? songDocument.collection('upvotes')
          : songDocument.collection('downvotes');
      CollectionReference otherVote = increase
          ? songDocument.collection('downvotes')
          : songDocument.collection('upvotes');
      otherVote.document(widget.user.username).delete();
      vote.document(widget.user.username).get().then((snapshot) {
        snapshot.exists
            ? vote.document(widget.user.username).delete()
            : vote.document(widget.user.username).setData({});
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    spotifyPlayer.dispose();
  }

  void _startParty() async {
    Response availableDevicesResponse = await get(
        'https://api.spotify.com/v1/me/player/devices',
        headers: {'Authorization': 'Bearer ${widget.owner.accessToken}'});
    List availableDevices =
        json.decode(availableDevicesResponse.body)['devices'];
    await put('https://api.spotify.com/v1/me/player',
        headers: {
          'Authorization': 'Bearer ${widget.owner.accessToken}',
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: '{'
            '"device_ids": ['
            '"${availableDevices[0]['id']}"'
            ']'
            '}');
    setState(() {
      currentlyPlayingSong = queue.removeFirst();
      spotifyPlayer.playSong(currentlyPlayingSong);
    });
  }

  void _openSearch() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PartyPageSearching(widget.owner, queue, _addSong)));
  }
}
