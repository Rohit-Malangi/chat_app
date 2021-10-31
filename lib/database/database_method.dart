import 'package:cloud_firestore/cloud_firestore.dart';

class DataBase {
  getChatRoomId(String a, String b) {
    List<String> list = [a, b];
    list.sort();
    return '${list[0]}_${list[1]}';
  }

  void sendMessage(String currUser, String otherUser, String message,
      String messageId) async {
    String roomId = getChatRoomId(currUser, otherUser);
    Timestamp time = Timestamp.now();
    FirebaseFirestore.instance
        .collection('chats')
        .doc(roomId)
        .collection('chatlist')
        .doc(messageId)
        .set({
      'text': message,
      'createdAt': time,
      'userId': currUser,
      'id': messageId,
    }).then((value) {
      addListOfNewUser(currUser, otherUser, roomId);
      updateLastMessage(currUser, otherUser, time, message, roomId);
    });
  }

  void updateLastMessage(String currUser, String otherUser, Timestamp time,
      String message, String roomId) async {
    FirebaseFirestore.instance.collection('chats').doc(roomId).update({
      'lastMessage': message,
      'lastMessageSendBy': currUser,
      'Time': time,
    });
  }

  void addListOfNewUser(
      String currUser, String otherUser, String roomId) async {
    final snapShot =
        await FirebaseFirestore.instance.collection('chats').doc(roomId).get();
    if (!snapShot.exists) {
      FirebaseFirestore.instance.collection('chats').doc(roomId).set({
        'users': [currUser, otherUser]
      });
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserInfo(String uid) async {
    return await FirebaseFirestore.instance.collection('users').doc(uid).get();
  }
}
