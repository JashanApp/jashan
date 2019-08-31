import 'dart:async';
import 'dart:convert';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:http/http.dart';
import 'package:jashan/data/track.dart';
import 'package:jashan/data/user.dart';

class SpotifyPlayer {
  final JashanUser user;
  final Function onSongStart;
  final Function onSongEnd;
  final Function onSongPause;
  final Function onSongChange;
  final SocketIOManager manager = SocketIOManager();
  SocketIO socket;

  SpotifyPlayer(
      {this.user,
      this.onSongEnd,
      this.onSongStart,
      this.onSongPause,
      this.onSongChange}) {
    initSocket();
  }

  void initSocket() async {
    socket = await manager.createInstance(SocketOptions(
      'https://spotify-connect-ws.herokuapp.com/connect', // todo host our own
    ));
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
    socket.onReconnect((data) {
      print('reconnect');
    });
    socket.onReconnecting((data) {
      print('trying to reconnect');
    });
    socket.onReconnectError((data) {
      print('reconnect error $data');
    });
    socket.onReconnectFailed((data) {
      print('reconnect failed');
    });
    socket.onConnect((data) {
      socket.emit('initiate', [
        {"accessToken": '${user.accessToken}'}
      ]);
      print('initiated');
    });
    socket.onDisconnect((data) {
      print('disconnected');
    });
    socket.onError((data) {
      print('got an error: $data');
    });
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
    await manager.clearInstance(socket);
  }
}
