import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jashan/pages/party/party_page_searching.dart';
import 'package:jashan/pages/party/party_page_view.dart';
import 'package:jashan/data/playlist_item.dart';
import 'package:jashan/util/sorted_queue_list.dart';
import 'package:jashan/data/user.dart';

class PartyPage extends StatefulWidget {
  final JashanUser user;
  final String playlistName;
  final QueueList<PlaylistQueueItem> queue = new SortedQueueList();

  PartyPage(this.playlistName, this.user);

  @override
  State<StatefulWidget> createState() {
    return PartyPageState(queue);
  }
}

class PartyPageState extends State<PartyPage> {
  bool searching = false;
  final QueueList<PlaylistQueueItem> queue;

  PartyPageState(this.queue);

  @override
  Widget build(BuildContext context) {
    return searching
        ? PartyPageSearching(this, widget.user, queue)
        : PartyPageView(this, widget.playlistName, queue);
  }
}
