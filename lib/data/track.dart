import 'package:flutter/material.dart';

class Track {
  final Image thumbnail;
  final String thumbnailUrl;
  final String title;
  final String artist;
  final String uri;
  final int durationMs;

  Track(
      {@required this.thumbnail,
      @required this.thumbnailUrl,
      @required this.title,
      @required this.artist,
      @required this.uri,
      @required this.durationMs});
}
