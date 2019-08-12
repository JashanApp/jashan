import 'package:flutter/material.dart';

class PlaylistItem {
  final Image thumbnail;
  final String title;
  final String artist;
  final String uri;

  PlaylistItem(
      {@required this.thumbnail,
      @required this.title,
      @required this.artist,
      this.uri});
}

class PlaylistQueueItem extends PlaylistItem implements Comparable {
  int upvotes = 1;

  PlaylistQueueItem.fromPlaylistItem(PlaylistItem playlistItem)
      : super(
            thumbnail: playlistItem.thumbnail,
            title: playlistItem.title,
            artist: playlistItem.artist,
            uri: playlistItem.uri);

  @override
  int compareTo(other) {
    if (other is PlaylistQueueItem) {
      return upvotes - other.upvotes;
    }
    return 0;
  }
}
