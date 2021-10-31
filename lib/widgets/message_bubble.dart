import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/database/database_method.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.time,
    required this.currUser,
    required this.otherUser,
    required this.id,
  }) : super(key: key);

  final String message;
  final bool isMe;
  final Timestamp time;
  final String currUser, otherUser, id;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.80),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft:
                    isMe ? const Radius.circular(16) : const Radius.circular(0),
                bottomRight:
                    isMe ? const Radius.circular(0) : const Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            child: InkWell(
              onLongPress: () => isMe
                  ? {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete',
                              style: TextStyle(color: Colors.red)),
                          content:
                              const Text('Do you want to delete this sms.'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  String roomId = DataBase()
                                      .getChatRoomId(currUser, otherUser);
                                  FirebaseFirestore.instance
                                      .collection('chats')
                                      .doc(roomId)
                                      .collection('chatlist')
                                      .doc(id)
                                      .delete();
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Delete')),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cencel'),
                            )
                          ],
                        ),
                      ),
                    }
                  : null,
              child: Text(
                message,
                softWrap: true,
                style: Theme.of(context).textTheme.bodyText2!.merge(
                      const TextStyle(
                        color: Colors.white,
                      ),
                    ),
              ),
            )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            DateFormat('hh:mm a').format(time.toDate()),
            style: const TextStyle(color: Colors.black, fontSize: 8),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
