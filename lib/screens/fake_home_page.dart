/**
 * This page is for showing current signed in user
 * TODO: remove this page and add test
 */
import 'package:flutter/material.dart';
import 'package:badiup/sign_in.dart';
import 'login_page.dart';

class FakeHomePage extends StatefulWidget {
  @override
  _FakeHomePageState createState() => _FakeHomePageState();
}

class _FakeHomePageState extends State<FakeHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( currentUserEmail ),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            signOutGoogle();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) {
                  return LoginPage();
                }
              ),
              ModalRoute.withName('/')
            );
          },
          color: Colors.deepPurple,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Sign Out',
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
          ),
          elevation: 5,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40)),
        )
      ),
    );
  }
}