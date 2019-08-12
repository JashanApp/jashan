import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:jashan/pages/party/party_page.dart';
import 'package:jashan/data/playlist_item.dart';
import 'package:jashan/views/playlist_item_view.dart';

class PartyPageView extends StatefulWidget {
  final PartyPageState partyPageState;
  final String playlistName;
  final QueueList<PlaylistQueueItem> queue;

  PartyPageView(this.partyPageState, this.playlistName, this.queue);

  @override
  State<StatefulWidget> createState() {
    return _PartyPageViewState();
  }
}

class _PartyPageViewState extends State<PartyPageView> {
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