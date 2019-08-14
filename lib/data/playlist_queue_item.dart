import 'dart:collection';

import 'package:jashan/data/playlist_item.dart';
import 'package:jashan/data/user.dart';

class PlaylistQueueItem extends PlaylistItem implements Comparable {
  final Set<JashanUser> upvotes = new HashSet();
  final Set<JashanUser> downvotes = new HashSet();

  PlaylistQueueItem.fromPlaylistItem(PlaylistItem playlistItem)
      : super(
      thumbnail: playlistItem.thumbnail,
      thumbnailUrl: playlistItem.thumbnailUrl,
      title: playlistItem.title,
      artist: playlistItem.artist,
      uri: playlistItem.uri,
      durationMs: playlistItem.durationMs);

  int getValue() {
    return upvotes.length - downvotes.length;
  }

  @override
  int compareTo(other) {
    if (other is PlaylistQueueItem) {
      return other.getValue() - getValue();
    }
    return 0;
  }
}
