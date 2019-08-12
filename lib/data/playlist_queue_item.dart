import 'package:jashan/data/playlist_item.dart';

class PlaylistQueueItem extends PlaylistItem implements Comparable {
  int upvotes = 1;

  PlaylistQueueItem.fromPlaylistItem(PlaylistItem playlistItem)
      : super(
      thumbnail: playlistItem.thumbnail,
      thumbnailUrl: playlistItem.thumbnailUrl,
      title: playlistItem.title,
      artist: playlistItem.artist,
      uri: playlistItem.uri,
      durationMs: playlistItem.durationMs);

  @override
  int compareTo(other) {
    if (other is PlaylistQueueItem) {
      return other.upvotes - upvotes;
    }
    return 0;
  }
}
