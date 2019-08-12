import 'package:jashan/data/playlist_item.dart';

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
      return other.upvotes - upvotes;
    }
    return 0;
  }
}
