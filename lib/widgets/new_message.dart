import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:whatsapp_clone/database/database_method.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({Key? key, required this.otherUser}) : super(key: key);

  final String otherUser;
  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final String currUser = FirebaseAuth.instance.currentUser!.uid;
  String messageId = '';
  final _controller = TextEditingController();

  addMessage(bool sendClicked) {
    if (_controller.text != '') {
      String message = _controller.text;

      if (messageId == '') {
        messageId = randomAlphaNumeric(20);
      }

      DataBase().sendMessage(currUser, widget.otherUser, message, messageId);
      if (sendClicked) {
        messageId = '';
        _controller.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 4),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: const InputDecoration(
              labelText: 'Send a Message',
            ),
            onChanged: (value) {
              addMessage(false);
            },
          ),
        ),
        IconButton(
          onPressed: () =>
              _controller.text.trim().isEmpty ? null : addMessage(true),
          icon: const Icon(
            Icons.send,
            size: 30,
          ),
        ),
      ]),
    );
  }
}
