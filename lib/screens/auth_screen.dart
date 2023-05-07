import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../database/database_method.dart';
import '../utils/constants.dart';
import '../widgets/auth_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  void _submitAuthForm({
    required String email,
    required String password,
    required BuildContext ctx,
  }) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((credential) async {
            DocumentSnapshot<Map<String, dynamic>> qs =
          await DataBase().getUserInfo(FirebaseAuth.instance.currentUser!.uid);
        await ZegoUIKitPrebuiltCallInvitationService().init(
          appID: Constants.appId,
          appSign: Constants.appSign,
          userID: credential.user!.uid,
          userName: qs['username'],
          plugins: [ZegoUIKitSignalingPlugin()],
        );
      });
    } on PlatformException catch (error) {
      var message = 'An Error ocurred, please cheak your credentials';
      if (error.message != null) {
        message = error.message!;
      }
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      var message = 'An Error ocurred, please cheak your credentials';
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Text(
                'CHAT APP',
                softWrap: true,
                style: Theme.of(context).textTheme.bodyLarge!.merge(
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
              const SizedBox(height: 30),
              AuthForm(_submitAuthForm, _isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
