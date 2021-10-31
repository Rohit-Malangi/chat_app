import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/database/database_method.dart';
import 'package:whatsapp_clone/widgets/image_picker.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key, required this.currUser}) : super(key: key);

  final String currUser;

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String imageUrl = '', userName = '';
  final _controller = TextEditingController();
  File? newImage;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      DocumentSnapshot<Map<String, dynamic>> qs =
          await DataBase().getUserInfo(FirebaseAuth.instance.currentUser!.uid);
      userName = qs['username'];
      imageUrl = qs['image_url'];
    }).then((_) {
      setState(() {});
    });
  }

  void getImageFile(File image) {
    newImage = image;
  }

  void saveImage() async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_image')
        .child(widget.currUser + '.jpg');

    await ref.putFile(newImage!).whenComplete(() => null);

    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currUser)
        .update({
      'username': userName,
      'image_url': url,
      'userId': widget.currUser,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        backgroundColor: Colors.black,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: imageUrl == ''
                      ? const Text('Loading...')
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Text(userName == '' ? 'Loading...' : userName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(color: Colors.white)),
              const Divider(color: Colors.white),
              InkWell(
                onTap: () => {
                  Navigator.of(context).pop(),
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('UpDate UserName'),
                      content: TextFormField(
                        controller: _controller,
                        keyboardType: TextInputType.name,
                        decoration:
                            const InputDecoration(labelText: 'Username'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            if (_controller.text.trim() == '') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Enter A valid User Name')));
                            } else if (_controller.text.trim().length > 30) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Name length should be less than 30')));
                            } else {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.currUser)
                                  .update({
                                'image_url': imageUrl,
                                'username': _controller.text.trim(),
                                'userId': widget.currUser,
                              });
                              Navigator.of(context).pop();
                              setState(() {});
                            }
                          },
                          child: const Text('UpDate'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cencel'),
                        )
                      ],
                    ),
                  ),
                },
                child: const ListTile(
                  title: Text(
                    'Update Your UserName',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const Divider(color: Colors.white),
              InkWell(
                onTap: () => {
                  Navigator.of(context).pop(),
                  showDialog(
                    context: context,
                    builder: (context) => Center(
                      child: AlertDialog(
                        insetPadding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.height * 0.06,
                          vertical: MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                              ? MediaQuery.of(context).size.height * 0.10
                              : MediaQuery.of(context).size.height * 0.25,
                        ),
                        title: const Text('Update Your Image'),
                        content: ImageInput(pickedImage: getImageFile),
                        actions: [
                          TextButton(
                            onPressed: () {
                              if (newImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Please Pick A Image.')));
                              } else {
                                Navigator.of(context).pop();
                                saveImage();
                                setState(() {});
                              }
                            },
                            child: const Text('UpDate'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cencel'),
                          )
                        ],
                      ),
                    ),
                  ),
                },
                child: const ListTile(
                    title: Text(
                  'UpDate Your Profile Pic',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: Colors.white),
                )),
              ),
              const Divider(color: Colors.white),
              InkWell(
                onTap: () => FirebaseAuth.instance.signOut(),
                child: const ListTile(
                    title: Text(
                  'Exit',
                  style: TextStyle(color: Colors.white),
                )),
              ),
              const Divider(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
