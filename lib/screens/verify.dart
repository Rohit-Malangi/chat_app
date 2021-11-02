import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Verify extends StatefulWidget {
  const Verify({
    Key? key,
    required this.userImage,
    required this.userName,
  }) : super(key: key);

  final String userName;
  final File? userImage;

  @override
  _VerifyState createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  final _auth = FirebaseAuth.instance;
  Timer? timer;

  @override
  void initState() {
    _auth.currentUser!.sendEmailVerification();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_auth.currentUser!.emailVerified) {
        timer.cancel();
        Navigator.of(context).pop();
      }
      checkEmailVerified();
    });
    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    Future.delayed(Duration.zero).then((value) async => {
          if (_auth.currentUser!.emailVerified)
            {
              await sendDetail(),
            }
        });
    super.dispose();
  }

  Future<void> sendDetail() async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_image')
        .child(_auth.currentUser!.uid + '.jpg');
    await ref.putFile(widget.userImage!).whenComplete(() => null);
    final url = await ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .set({
      'username': widget.userName,
      'image_url': url.toString(),
      'userId': _auth.currentUser!.uid,
    }).then((value) => {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'An verification email sent to ${_auth.currentUser!.email} please verify and do not press back bottom , It automatically will backed than login.',
          textAlign: TextAlign.center,
          softWrap: true,
        ),
      ),
    );
  }

  Future<void> checkEmailVerified() async {
    await _auth.currentUser!.reload();
  }
}
