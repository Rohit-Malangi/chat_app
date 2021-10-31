import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp_clone/database/database_method.dart';

import '../widgets/message_bubble.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key, required this.otherUser, required this.userName})
      : super(key: key);

  final String otherUser, userName;

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final String currUser = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(DataBase().getChatRoomId(currUser, widget.otherUser))
          .collection('chatlist')
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text(
            'Chat with ${widget.userName} .',
            softWrap: true,
          ));
        }
        final docs = snapshot.data.docs;
        return ListView.builder(
          physics: const ScrollPhysics(),
          shrinkWrap: true,
          itemCount: docs.length,
          itemBuilder: (ctx, index) => MessageBubble(
            id: docs[index]['id'],
            currUser: currUser,
            otherUser: widget.otherUser,
            time: docs[index]['createdAt'],
            message: docs[index]['text'],
            isMe:
                docs[index]['userId'] == FirebaseAuth.instance.currentUser!.uid,
          ),
        );
      },
    );
  }
}
