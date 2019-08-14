import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jashan/data/track.dart';
import 'package:jashan/data/track_queue_item.dart';
import 'package:jashan/data/user.dart';
import 'package:jashan/pages/party/party_page_searching.dart';
import 'package:jashan/pages/party/party_page_view.dart';
import 'package:jashan/util/sorted_queue_list.dart';

class PartyPage extends StatefulWidget {
  final JashanUser user;
  final QueueList<TrackQueueItem> queue = new SortedQueueList();
  final String playlistName;

  PartyPage(this.playlistName, this.user, List<Track> tracks) {
    tracks.forEach((item) {
      var trackQueueItem = new TrackQueueItem.fromTrack(item, addedBy: user.username);
      trackQueueItem.upvotes.add(user);
      queue.add(trackQueueItem);
    });
  }

  @override
  State<StatefulWidget> createState() {
    return PartyPageState(queue);
  }
}

class PartyPageState extends State<PartyPage> {
  final QueueList<TrackQueueItem> queue;
  bool searching = false;

  PartyPageState(this.queue);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return searching
        ? PartyPageSearching(this, widget.user, queue)
        : PartyPageView(widget.user, this, widget.playlistName, queue);
  }
}
