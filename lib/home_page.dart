import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatelessWidget {
  FirebaseUser user;

  HomePage(this.user);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Welcome ${user.email}!'),
    );
  }
}
