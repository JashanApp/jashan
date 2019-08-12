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