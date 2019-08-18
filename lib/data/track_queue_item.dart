import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jashan/data/track.dart';

class TrackQueueItem extends Track implements Comparable {
  final Set<String> upvotes = new HashSet();
  final Set<String> downvotes = new HashSet();
  String addedBy;

  TrackQueueItem.fromDocumentReference(DocumentSnapshot snapshot) :
      super(thumbnailUrl: snapshot.data['thumbnail_url'],
          title: snapshot.data['title'],
          artist: snapshot.data['artist'],
          uri: snapshot.data['uri'],
          durationMs: snapshot.data['duration_ms']) {
    addedBy = snapshot.data['added_by'];
  }

  TrackQueueItem.fromTrack(Track track, {@required this.addedBy})
      : super(
            thumbnail: track.thumbnail,
            thumbnailUrl: track.thumbnailUrl,
            title: track.title,
            artist: track.artist,
            uri: track.uri,
            durationMs: track.durationMs);

  int getValue() {
    return upvotes.length - downvotes.length;
  }

  bool userUpvoted(String user) {
    return upvotes.contains(user);
  }

  bool userDownvoted(String user) {
    return downvotes.contains(user);
  }

  @override
  int compareTo(other) {
    if (other is TrackQueueItem) {
      return other.getValue() - getValue();
    }
    return 0;
  }
}
