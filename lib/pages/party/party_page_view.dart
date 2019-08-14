import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:jashan/data/playlist_queue_item.dart';
import 'package:jashan/pages/party/party_page.dart';
import 'package:jashan/util/spotify_player.dart';
import 'package:jashan/widgets/playlist_queue_item_card.dart';

class PartyPageView extends StatefulWidget {
  final PartyPageState partyPageState;
  final String playlistName;
  final QueueList<PlaylistQueueItem> queue;
  SpotifyPlayer spotifyPlayer;

  PartyPageView(this.partyPageState, this.playlistName, this.queue) {
    spotifyPlayer = new SpotifyPlayer(
      user: partyPageState.widget.user,
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _PartyPageViewState();
  }
}

class _PartyPageViewState extends State<PartyPageView> {
  PlaylistQueueItem currentlyPlayingSong;

  @override
  void initState() {
    super.initState();
    widget.spotifyPlayer.setOnSongChange(() {
      setState(() {
        currentlyPlayingSong = widget.queue.removeFirst();
        widget.spotifyPlayer.playSong(currentlyPlayingSong);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
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
                ],
              ),
            ),
            Expanded(
              flex: 8,
              child: widget.queue.isNotEmpty
                  ? ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        PlaylistQueueItem data;
                        if (currentlyPlayingSong == null) {
                          data = widget.queue[index];
                        } else if (index == 0 && currentlyPlayingSong != null) {
                          data = currentlyPlayingSong;
                        } else if (index != 0 && currentlyPlayingSong != null) {
                          data = widget.queue[index - 1];
                        }
                        return PlaylistQueueItemCard(
                          data: data,
                          onUpvoteChange:
                              index != 0 || currentlyPlayingSong == null
                                  ? () {
                                      setState(() {
                                        widget.queue.sort();
                                      });
                                    }
                                  : () {},
                          isCurrentPlaying: data == currentlyPlayingSong,
                        );
                      },
                      itemCount: widget.queue.length +
                          (currentlyPlayingSong == null ? 0 : 1),
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
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      color: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(75),
                      ),
                      onPressed: () {
                        setState(() {
                          currentlyPlayingSong = widget.queue.removeFirst();
                          widget.spotifyPlayer.playSong(currentlyPlayingSong);
                        });
                      },
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

  @override
  void dispose() {
    super.dispose();
    widget.spotifyPlayer.dispose();
  }
}
