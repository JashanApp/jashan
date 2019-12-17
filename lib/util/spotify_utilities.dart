import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:jashan/data/user.dart';

void markDeviceAsActive(JashanUser user, ScaffoldState scaffoldState, Function onSuccess) async {
  Response availableDevicesResponse = await get(
      'https://api.spotify.com/v1/me/player/devices',
      headers: {'Authorization': 'Bearer ${user.accessToken}'});
  List availableDevices = json.decode(availableDevicesResponse.body)['devices'];
  if (availableDevices != null && availableDevices.length > 0) {
    await put('https://api.spotify.com/v1/me/player',
        headers: {
        'Authorization': 'Bearer ${user.accessToken}',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
        },
        body:
        '{'
          '"device_ids": ['
            '"${availableDevices[0]['id']}"'
          ']'
        '}');
    onSuccess();
  } else {
    scaffoldState.showSnackBar(
      SnackBar(
        content: Text(
          "No active device with Spotify! Consider opening Spotify, then trying again.",
        ),
      ),
    );
  }
}