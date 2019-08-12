import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jashan/data/playlist_item.dart';

class PlaylistItemCard extends StatelessWidget {
  final PlaylistItem data;
  final GestureTapCallback onClick;

  PlaylistItemCard({@required this.data, this.onClick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick == null ? () {} : onClick,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              child: data.thumbnail,
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    data.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    data.artist,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PlaylistQueueItemCard extends StatelessWidget {
  final PlaylistQueueItem data;
  final GestureTapCallback onUpvoteChange;

  PlaylistQueueItemCard({@required this.data, this.onUpvoteChange});

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
            child: data.thumbnail,
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
