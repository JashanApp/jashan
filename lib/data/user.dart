import 'package:flutter/material.dart';

class JashanUser {
  String username;
  String spotifyUserId;
  String accessToken;

  JashanUser({@required this.username});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JashanUser &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          spotifyUserId == other.spotifyUserId &&
          accessToken == other.accessToken;

  @override
  int get hashCode =>
      username.hashCode ^ spotifyUserId.hashCode ^ accessToken.hashCode;
}
