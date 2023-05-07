import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_method.dart';
import '../screens/chat_screen.dart';

class ChatRoomTile extends StatefulWidget {
  const ChatRoomTile(
      {Key? key,
      required this.currUser,
      required this.otherUser,
      required this.time,
      required this.lastmessage,
      required this.sendBy})
      : super(key: key);
  final String currUser, otherUser, lastmessage, sendBy;
  final Timestamp time;

  @override
  State<ChatRoomTile> createState() => _ChatRoomTileState();
}

class _ChatRoomTileState extends State<ChatRoomTile> {
  String name = '', imageUrl = '', sendBy = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      DocumentSnapshot<Map<String, dynamic>> qs =
          await DataBase().getUserInfo(widget.otherUser);
      name = qs['username'];
      imageUrl = qs['image_url'];
    }).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    sendBy = widget.currUser == widget.sendBy ? 'You : ' : '$name : ';
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => ChatScreen(
              otherUser: widget.otherUser,
              imageUrl: imageUrl,
              username: name,
            ),
          ),
        );
      },
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: SizedBox(
              height: 50,
              width: 50,
              child: imageUrl == ''
                  ? const SizedBox()
                  : CachedNetworkImage(
                      placeholder: (context, imageUrl) =>
                          const CircularProgressIndicator(),
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                    )),
        ),
        title: Text(
          name == '' ? 'Loading...' : name,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .merge(const TextStyle(fontSize: 18)),
        ),
        subtitle: Text(
          sendBy + widget.lastmessage,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
        trailing: Text(
          DateFormat('hh:mm a').format(widget.time.toDate()),
          style: const TextStyle(color: Colors.black, fontSize: 8),
        ),
      ),
    );
  }
}
