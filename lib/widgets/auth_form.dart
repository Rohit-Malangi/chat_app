import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/verify.dart';
import './image_picker.dart';

class AuthForm extends StatefulWidget {
  const AuthForm(this.submitAuthForm, this._isLoading, {Key? key})
      : super(key: key);

  final void Function({
    required BuildContext ctx,
    required String email,
    required String password,
  }) submitAuthForm;
  final bool _isLoading;
  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _userName = '';
  String _userEmail = '';
  String _passWord = '';
  File? _userImage;

  void _pickedImage(File image) {
    _userImage = image;
  }

  void _trySummit() async {
    final isvalid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_isLogin) {
      if (isvalid) {
        _formKey.currentState!.save();
        widget.submitAuthForm(
          email: _userEmail.trim(),
          password: _passWord.trim(),
          ctx: context,
        );
      }
    } else {
      if (_userImage == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Please Pick a Image')));
      } else if (isvalid) {
        _formKey.currentState!.save();
        try {
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: _userEmail.toString().trim(),
                  password: _passWord.toString().trim())
              .then(
                (value) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Verify(
                      userName: _userName.toString().trim(),
                      userImage: _userImage,
                    ),
                  ),
                ),
              );
        } on PlatformException catch (error) {
          var message = 'An Error ocurred, please cheak your credentials.';
          if (error.message != null) {
            message = error.message!;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
            ),
          );
        } catch (error) {
          var message = 'Email is already exixts .';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
      margin: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isLogin)
                  ImageInput(
                    pickedImage: _pickedImage,
                  ),
                TextFormField(
                  key: const ValueKey('email'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Enter a Email';
                    } else if (!value.endsWith('@gmail.com')) {
                      return 'Invalid Email';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                  onSaved: (value) {
                    _userEmail = value!;
                  },
                ),
                if (!_isLogin)
                  TextFormField(
                    key: const ValueKey('userName'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter a Name';
                      }
                      if (value.length > 30) {
                        return 'Name length should be less than 30';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(labelText: 'Username'),
                    onSaved: (value) {
                      _userName = value!;
                    },
                  ),
                TextFormField(
                    key: const ValueKey('password'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter Password';
                      }
                      if (value.length < 6) {
                        return 'Please Enter at least 6 digit password';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onSaved: (value) {
                      _passWord = value!;
                    }),
                const SizedBox(height: 12),
                widget._isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                        onPressed: _trySummit,
                        child: Text(_isLogin ? 'Login' : 'SignUp')),
                TextButton(
                  onPressed: widget._isLoading
                      ? null
                      : () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                  child: Text(
                    _isLogin
                        ? 'Create New Account'
                        : 'I have already an Account',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
