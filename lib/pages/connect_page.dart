import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jashan/data/party_info.dart';
import 'package:jashan/data/user.dart';
import 'package:jashan/pages/party/party_page.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

class ConnectPage extends StatelessWidget {
  final JashanUser user;

  ConnectPage(this.user);

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      iconTheme: Theme.of(context).iconTheme,
      title: Text('Join Party'),
      backgroundColor: Theme.of(context).primaryColor,
    );
    double height = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top -
        kToolbarHeight;
    return Scaffold(
        appBar: appBar,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: height * 0.3,
                child: Center(
                  child: Text(
                    "Enter 5-Digit Code:",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 36
                    ),
                  ),
                ),
              ),
              _PinAndJoinWidgets(height, user),
            ],
          ),
        )
    );
  }
}

class _PinAndJoinWidgets extends StatefulWidget {
  final double height;
  final JashanUser user;

  _PinAndJoinWidgets(this.height, this.user);

  @override
  State<StatefulWidget> createState() {
    return _PinAndJoinWidgetsState();
  }
}

class _PinAndJoinWidgetsState extends State<_PinAndJoinWidgets> {
  String pin;
  static const int KEY_LENGTH = 5;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
            height: widget.height * 0.35,
            child: Center(
              child: PinCodeTextField(
                autofocus: true,
                highlight: true,
                highlightColor: Theme.of(context).primaryColor,
                pinTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.black
                ),
                defaultBorderColor: Colors.black,
                maxLength: KEY_LENGTH,
                onTextChanged: (string) {
                  if (string.length < KEY_LENGTH) {
                    pin = null;
                  } else if (string.length == KEY_LENGTH) {
                    pin = string;
                  }
                  print('changed: $string (len: ${string.length}) | $pin');
                },
                onDone: (text) {
                  pin = text;
                  print('done: $text | $pin');
                },
              ),
            )
        ),
        Container(
            height: widget.height * 0.45,
            child: Center(
              child: SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width * 0.8,
                child: RaisedButton(
                  child: Text(
                    "Join Party",
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 20,
                    ),
                  ),
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(75),
                  ),
                  onPressed: () => _joinParty(context),
                ),
              ),
            )
        )
      ],
    );
  }

  void _joinParty(BuildContext context) async {
    print('try: $pin');
    if (pin == null) {
      _showSnackBar('Failed to join! Invalid pin!');
    } else {
      DocumentReference reference = Firestore.instance.collection('parties').document(pin);
      DocumentSnapshot snapshot = await reference.get();
      if (snapshot.exists) {
        JashanUser owner = new JashanUser(
            username: snapshot.data['owner_username'],
            accessToken: snapshot.data['owner_access_token']
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PartyPage(
              partyInfo: PartyInfo(
                id: int.parse(pin),
                title: snapshot.data['party_name'],
                owner: owner,
              ),
              user: widget.user,
            ),
          ),
        );
      } else {
        _showSnackBar('Failed to join! That pin does not exist!');
      }
    }
  }

  void _showSnackBar(String message) {
    print(message);
    /*ScaffoldState scaffoldState = scaffoldKey.currentState;
    scaffoldState.showSnackBar(SnackBar(
      content: Text(message),
    ));*/
  }
}