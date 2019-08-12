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
