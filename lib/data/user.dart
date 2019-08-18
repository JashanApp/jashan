import 'package:flutter/material.dart';

class JashanUser {
  String username;
  String accessToken;

  JashanUser({@required this.username, this.accessToken});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JashanUser &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          accessToken == other.accessToken;

  @override
  int get hashCode =>
      username.hashCode ^ accessToken.hashCode;
}
