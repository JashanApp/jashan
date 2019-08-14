import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jashan/data/track_queue_item.dart';
import 'package:jashan/util/text_utilities.dart';

class TrackQueueItemCard extends StatelessWidget {
  final TrackQueueItem data;
  final Function(bool) onUpvoteChange;
  final bool isCurrentPlaying;
  final GestureLongPressCallback onLongPress;

  TrackQueueItemCard(
      {@required this.data,
      this.onUpvoteChange,
      this.onLongPress,
      this.isCurrentPlaying});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                child: Row(
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
                              color: Theme.of(context).accentColor,
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
                    getTextWithCap(data.title, 7),
                    style: TextStyle(fontSize: 22, color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            )),
            Container(
                child: Row(
              children: <Widget>[
                Text(
                  "${data.getValue()}",
                  style: TextStyle(fontSize: 22, color: Theme.of(context).primaryColor),
                ),
                SizedBox(
                  width: 20,
                ),
                IconButton(
                  iconSize: 24,
                  icon: Icon(
                    Icons.keyboard_arrow_up,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    onUpvoteChange(true);
                  },
                ),
                IconButton(
                  iconSize: 24,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () => onUpvoteChange(false),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
