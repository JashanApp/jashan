import 'package:flutter/material.dart';

class PlaylistItem extends StatelessWidget {
  final Image thumbnail;
  final String title;
  final String artist;

  PlaylistItem({@required this.thumbnail, @required this.title, @required this.artist});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              child: thumbnail,
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    artist,
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
