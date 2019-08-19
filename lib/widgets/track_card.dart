import 'package:flutter/material.dart';
import 'package:jashan/data/track.dart';
import 'package:jashan/util/text_utilities.dart';

class TrackCard extends StatelessWidget {
  final Track data;
  final GestureTapCallback onClick;
  final int titleChars;
  final int artistChars;

  TrackCard({@required this.data, this.onClick, this.titleChars, this.artistChars});

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
                    getTextWithCap(data.title, titleChars),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    getTextWithCap(data.artist, artistChars),
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
