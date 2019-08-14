import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:jashan/data/track.dart';
import 'package:jashan/data/user.dart';

class TrackQueueItem extends Track implements Comparable {
  final Set<JashanUser> upvotes = new HashSet();
  final Set<JashanUser> downvotes = new HashSet();
  final String addedBy;

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

  @override
  int compareTo(other) {
    if (other is TrackQueueItem) {
      return other.getValue() - getValue();
    }
    return 0;
  }
}
