import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jashan/data/track_queue_item.dart';
import 'package:jashan/data/user.dart';
import 'package:jashan/util/text_utilities.dart';

class TrackQueueItemCard extends StatelessWidget {
  final TrackQueueItem data;
  final Function(bool) onUpvoteChange;
  final bool isCurrentPlaying;
  final GestureLongPressCallback onLongPress;
  final JashanUser user;

  TrackQueueItemCard(
      {@required this.data,
      this.onUpvoteChange,
      this.onLongPress,
      this.isCurrentPlaying,
      this.user});

  @override
  Widget build(BuildContext context) {
    bool upvotesHasUser = data.userUpvoted(user.username);
    bool downvotesHasUser = data.userDownvoted(user.username);
    return InkWell(
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: Container(
          color: isCurrentPlaying ? Theme.of(context).primaryColor : Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: (MediaQuery.of(context).size.width - 50) * 0.65,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      child: isCurrentPlaying
                          ? Container(
                              width: 50,
                              height: 50,
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
                    Container(
                      height: 45,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            getTextWithCap(data.title, 18),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isCurrentPlaying
                                    ? Theme.of(context).accentColor
                                    : Colors.black,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            getTextWithCap(data.artist, 22),
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: isCurrentPlaying
                                  ? Theme.of(context).accentColor
                                  : Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  width: (MediaQuery.of(context).size.width - 50) * 0.35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "${data.getValue()}",
                        style: TextStyle(
                            fontSize: 22,
                            color: isCurrentPlaying
                                ? Theme.of(context).accentColor
                                : upvotesHasUser || downvotesHasUser
                                ? Theme.of(context).primaryColor
                                : Colors.black,
                            fontWeight: isCurrentPlaying || upvotesHasUser || downvotesHasUser
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      IconButton(
                        iconSize: 24,
                        icon: Icon(
                          Icons.keyboard_arrow_up,
                          color: isCurrentPlaying
                              ? Theme.of(context).accentColor
                              : upvotesHasUser
                              ? Theme.of(context).primaryColor
                              : Colors.black,
                        ),
                        onPressed: () {
                          onUpvoteChange(true);
                        },
                      ),
                      IconButton(
                        iconSize: 24,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: isCurrentPlaying
                              ? Theme.of(context).accentColor
                              : downvotesHasUser
                                  ? Theme.of(context).primaryColor
                                  : Colors.black,
                        ),
                        onPressed: () => onUpvoteChange(false),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
