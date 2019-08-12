import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jashan/data/playlist_queue_item.dart';

class PlaylistQueueItemCard extends StatelessWidget {
  final PlaylistQueueItem data;
  final GestureTapCallback onUpvoteChange;
  final bool isCurrentPlaying;

  PlaylistQueueItemCard(
      {@required this.data, this.onUpvoteChange, this.isCurrentPlaying});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 45,
            height: 45,
            child: isCurrentPlaying
                ? Container(
                    width: 45,
                    height: 45,
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Icon(
                        Icons.audiotrack,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  )
                : null,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(data.thumbnailUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Container(
            width: 120,
            child: Text(
              "${data.title.substring(0, min(data.title.length, 8))}${data.title.length > 8 ? "..." : ""}",
              style: TextStyle(fontSize: 22, color: Colors.orange),
            ),
          ),
          SizedBox(
            width: 50,
          ),
          Text(
            "${data.upvotes}",
            style: TextStyle(fontSize: 22, color: Colors.orange),
          ),
          SizedBox(
            width: 20,
          ),
          IconButton(
            iconSize: 24,
            icon: Icon(
              Icons.keyboard_arrow_up,
              color: Colors.orange,
            ),
            onPressed: () {
              data.upvotes++;
              onUpvoteChange();
            },
          ),
          IconButton(
            iconSize: 24,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.orange,
            ),
            onPressed: () {
              data.upvotes--;
              onUpvoteChange();
            },
          )
        ],
      ),
    );
  }
}
