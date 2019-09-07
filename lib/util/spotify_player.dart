import 'dart:async';
import 'dart:convert';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart';
import 'package:jashan/data/track.dart';
import 'package:jashan/data/user.dart';

class SpotifyPlayer {
  final JashanUser user;
  final Function onSongStart;
  final Function onSongEnd;
  final Function onSongPause;
  final Function onSongChange;
  IO.Socket socket;

  SpotifyPlayer({this.user,
    this.onSongEnd,
    this.onSongStart,
    this.onSongPause,
    this.onSongChange}) {
    initSocket();
  }

  void initSocket() async {
    socket = IO.io('https://spotify-connect-ws.herokuapp.com/connect',
      <String, dynamic>{
        'transports': ['websocket']
      },
    );
    socket.on('connect', (_) {
      socket.emitWithAck('initiate', [
        {'accessToken': "${user.accessToken}"}
      ]);
    });
    socket.on('reconnect', (_) {
      print('reconnect');
    });
    socket.on('error', (data) {
      print('error from socket: $data');
    });
    socket.on("track_end", (message) {
      new Timer(Duration(seconds: 1), () {
        if (onSongEnd != null) {
          onSongEnd();
        }
      });
    });
    socket.on("track_change", (message) {
      if (onSongChange != null) {
        onSongChange();
      }
    });
    socket.on("playback_paused", (message) {
      if (onSongPause != null) {
        onSongPause();
      }
    });
    socket.on("playback_started", (message) {
      if (onSongStart != null) {
        onSongStart();
      }
    });
    socket.connect();
  }

  void playSong(Track song) async {
    Track currentSongPlaying;
    while ((currentSongPlaying = await getCurrentSongPlaying()) != null &&
        currentSongPlaying.uri != song.uri) {
      put('https://api.spotify.com/v1/me/player/play',
          headers: {'Authorization': 'Bearer ${user.accessToken}'}, body: '''
        {
          "uris": ["${song.uri}"]
        }
        ''');
      await Future.delayed(Duration(milliseconds: 200));
    }
    // todo add a capacity for requests, don't want to keep on doing it forever
  }

  Future<Track> getCurrentSongPlaying() async {
    Response playerResponse = await get('https://api.spotify.com/v1/me/player',
        headers: {'Authorization': 'Bearer ${user.accessToken}'});
    if (playerResponse.body != null) {
      Map trackInfo = json.decode(playerResponse.body)['item'];
      String imageUrl = trackInfo['album']['images'][0]['url'];
      String uri = trackInfo['uri'];
      String name = trackInfo['name'];
      int durationMs = trackInfo['duration_ms'];
      List artists = trackInfo['artists'];
      String artistsString = artists[0]['name'];
      for (int i = 1; i < artists.length; i++) {
        artistsString += ', ${artists[i]['name']}';
      }
      return Track(
          thumbnailUrl: imageUrl,
          title: name,
          artist: artistsString,
          uri: uri,
          durationMs: durationMs);
    }
    return null;
  }

  void dispose() async {
    socket.disconnect();
  }
}
