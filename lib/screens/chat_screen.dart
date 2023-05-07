import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../widgets/new_message.dart';
import '../widgets/messages.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen(
      {Key? key,
      required this.otherUser,
      required this.imageUrl,
      required this.username})
      : super(key: key);

  final String imageUrl, username, otherUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Text(
          username.toUpperCase(),
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .merge(const TextStyle(color: Colors.black, fontSize: 20)),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: SizedBox(
                height: 50,
                width: 50,
                child: CachedNetworkImage(
                  placeholder: (context, imageUrl) =>
                      const CircularProgressIndicator(),
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                )),
          ),
        ),
        actions: [
          ZegoSendCallInvitationButton(
            buttonSize: const Size(40, 40),
            iconSize: const Size(40, 40),
              isVideoCall: true,
              resourceID: "zegouikit_call", // For offline call notification
              invitees: [
                ZegoUIKitUser(
                  id: otherUser,
                  name: username,
                ),
              ],
            ),
        ZegoSendCallInvitationButton(
            iconSize: const Size(40, 40),
            buttonSize: const Size(40, 40),
              isVideoCall: false,
              resourceID: "zegouikit_call", // For offline call notification
              invitees: [
                ZegoUIKitUser(
                  id: otherUser,
                  name: username,
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Messages(
                otherUser: otherUser,
                userName: username,
              ),
            ),
          ),
          NewMessage(otherUser: otherUser),
        ],
      ),
    );
  }
}
