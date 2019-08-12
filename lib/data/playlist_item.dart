import 'package:flutter/material.dart';

class PlaylistItem {
  final Image thumbnail;
  final String thumbnailUrl;
  final String title;
  final String artist;
  final String uri;
  final int durationMs;

  PlaylistItem(
      {@required this.thumbnail,
      @required this.thumbnailUrl,
      @required this.title,
      @required this.artist,
      @required this.uri,
      @required this.durationMs});
}