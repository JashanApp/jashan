import 'dart:async';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:jashan/data/track.dart';
import 'package:jashan/data/user.dart';

class SpotifyPlayer {
  final JashanUser user;
  Function onSongChange;
  String timerSongUri;
  Timer timer;
  final SocketIOManager manager = SocketIOManager();
  SocketIO socket;

  SpotifyPlayer({this.user}) {
    initSocket();
  }

  void initSocket() async {
    socket = await manager.createInstance(SocketOptions(
      'https://spotify-connect-ws.herokuapp.com/connect', // todo host our own
    ));
    socket.on("track_end", (message) {
      timer = new Timer(Duration(seconds: 1), () {
        onSongChange();
      });
    });
    socket.on("track_change", (message) {
      print('changed');
    });
    socket.on("playback_paused", (message) {
      print('paused');
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

  void setOnSongChange(Function onSongChange) {
    this.onSongChange = onSongChange;
  }

  void playSong(Track song) {
    socket.emit('play', [
      {
        'uris': ['${song.uri}']
      }
    ]);
  }

  void dispose() async {
    await manager.clearInstance(socket);
  }
}
