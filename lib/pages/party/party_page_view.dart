import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:jashan/data/track_queue_item.dart';
import 'package:jashan/data/user.dart';
import 'package:jashan/pages/party/party_page.dart';
import 'package:jashan/util/spotify_player.dart';
import 'package:jashan/util/text_utilities.dart';
import 'package:jashan/widgets/track_info_view.dart';
import 'package:jashan/widgets/track_queue_item_card.dart';

class PartyPageView extends StatefulWidget {
  final PartyPageState partyPageState;
  final String playlistName;
  final QueueList<TrackQueueItem> queue;
  final JashanUser user;

  PartyPageView(this.user, this.partyPageState, this.playlistName, this.queue);

  @override
  State<StatefulWidget> createState() {
    return _PartyPageViewState();
  }
}

class _PartyPageViewState extends State<PartyPageView> {
  TrackQueueItem currentlyPlayingSong;
  SpotifyPlayer spotifyPlayer;

  @override
  void initState() {
    super.initState();
    spotifyPlayer = new SpotifyPlayer(
      user: widget.user,
    );
    spotifyPlayer.setOnSongChange(() {
      setState(() {
        currentlyPlayingSong = widget.queue.removeFirst();
        spotifyPlayer.playSong(currentlyPlayingSong);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      iconTheme: Theme.of(context).iconTheme,
      actions: <Widget>[
        InkWell(
          child: Icon(Icons.add),
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
                  Text(
                    getTextWithCap(widget.playlistName, 16),
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
              child: widget.queue.isNotEmpty
                  ? ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        TrackQueueItem data;
                        if (currentlyPlayingSong == null) {
                          data = widget.queue[index];
                        } else if (index == 0 && currentlyPlayingSong != null) {
                          data = currentlyPlayingSong;
                        } else if (index != 0 && currentlyPlayingSong != null) {
                          data = widget.queue[index - 1];
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
                          onUpvoteChange: index != 0 ||
                                  currentlyPlayingSong == null
                              ? (increase) {
                                  Set<JashanUser> variation =
                                      increase ? data.upvotes : data.downvotes;
                                  Set<JashanUser> otherVariation =
                                      increase ? data.downvotes : data.upvotes;
                                  otherVariation.remove(widget.user);
                                  variation.contains(widget.user)
                                      ? variation.remove(widget.user)
                                      : variation.add(widget.user);
                                  setState(() {
                                    widget.queue.sort();
                                  });
                                }
                              : (increase) {},
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
                          color: Theme.of(context).accentColor,
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
                          spotifyPlayer.playSong(currentlyPlayingSong);
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
    spotifyPlayer.dispose();
  }
}
