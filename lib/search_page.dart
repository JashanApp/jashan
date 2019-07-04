import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:jashan/user.dart';

class SearchPage extends StatefulWidget {
  JashanUser user;

  SearchPage(this.user);

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  Widget _appBarTitle = Container();
  bool _searching = false;

  List<_SearchItem> _searchItems = List<_SearchItem>();
  TextEditingController _searchQueryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchItems.add(_SearchItem(
        thumbnail: Image.asset('assets/images/jashan_black.png'),
        title: 'Jashan',
        artist: 'Rhythm Garg, Arham Siddiqui'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: _appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: _searching ? Icon(Icons.close) : Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              setState(() {
                _searching = !_searching;
                if (_searching) {
                  _appBarTitle = TextField(
                    autocorrect: false,
                    controller: _searchQueryController,
                    onSubmitted: (searchQuery) {
                      if (searchQuery.length > 2) {
                        _searchItems.clear();
                        _repopulateSearchList(searchQuery);
                      }
                    },
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      hintText: "Search...",
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  _appBarTitle = Container();
                }
              });
            },
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _searchItems.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return SizedBox(
              height: 10,
            );
          }
          return _searchItems[index - 1];
        },
      ),
    );
  }

  Future _repopulateSearchList(String searchQuery) async {
    Response queryResponse = await get(
        'https://api.spotify.com/v1/search?q="$searchQuery"&type=track',
        headers: {'Authorization': 'Bearer ${widget.user.accessToken}'});
    List items = json.decode(queryResponse.body)['tracks']['items'];
    return setState(() {
      items.forEach((albums) {
        Map album = albums['album'];
        String id = album['id'];
        String imageUrl = album['images'][0]['url'];
        String name = album['name'];
        const int CAP = 37;
        name =
            '${name.substring(0, min(name.length, CAP))}${name.length > CAP ? '...' : ''}';
        List artists = album['artists'];
        String artistsString = artists[0]['name'];
        for (int i = 1; i < artists.length; i++) {
          artistsString += ', ${artists[i]['name']}';
        }
        _searchItems.add(
          _SearchItem(
              thumbnail: Image.network(imageUrl),
              title: name,
              artist: artistsString),
        );
        print('searched for $searchQuery');
      });
    });
  }
}

class _SearchItem extends StatelessWidget {
  Image thumbnail;
  String title;
  String artist;

  _SearchItem(
      {@required this.thumbnail, @required this.title, @required this.artist});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            child: thumbnail,
          ),
          Container(
            height: 50,
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(artist,
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                        fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
