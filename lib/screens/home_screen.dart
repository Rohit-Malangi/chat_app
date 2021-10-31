import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/screens/chat_screen.dart';
import 'package:whatsapp_clone/widgets/chat_room_tile.dart';
import 'package:whatsapp_clone/widgets/drawer.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  Stream<QuerySnapshot<Map<String, dynamic>>> searchStream =
      const Stream.empty();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searched = '';
  bool _searchClicked = false;
  final String currUser = FirebaseAuth.instance.currentUser!.uid;

  TextEditingController search = TextEditingController();

  void searchQuery() {
    searched = search.text.trim();
    widget.searchStream = FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: searched)
        .snapshots();
    setState(() {});
  }

  Widget searchUserList() {
    return StreamBuilder<QuerySnapshot>(
        stream: widget.searchStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Match Found !'));
          }
          if (snapshot.data!.docs.length == 1 &&
              snapshot.data!.docs[0]['userId'] == currUser) {
            return const Center(child: Text('No Match Found !'));
          }
          return snapshot.hasData
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (ctx, index) {
                    DocumentSnapshot ds = snapshot.data!.docs[index];
                    return InkWell(
                      onTap: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => ChatScreen(
                              otherUser: ds['userId'],
                              imageUrl: ds['image_url'],
                              username: ds['username'],
                            ),
                          ),
                        )
                      },
                      child: ds['userId'] == currUser
                          ? const SizedBox()
                          : ListTile(
                              title: Text(
                                ds['username'] == ''
                                    ? 'Loading...'
                                    : ds['username'],
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: ds['image_url'] == ''
                                      ? const SizedBox()
                                      : Image.network(
                                          ds['image_url'],
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                    );
                  })
              : const Center(child: Text('An Error Ocurred!'));
        });
  }

  Widget userList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("chats")
          .orderBy('Time', descending: true)
          .where('users', arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text(
            'Chat with Users by serching their Username',
            softWrap: true,
          ));
        }
        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (ctx, index) {
                  DocumentSnapshot ds = snapshot.data!.docs[index];
                  String otherUser =
                      ds.id.replaceAll(currUser, "").replaceAll("_", "");
                  return ChatRoomTile(
                    currUser: currUser,
                    otherUser: otherUser,
                    time: ds['Time'],
                    lastmessage: ds['lastMessage'],
                    sendBy: ds['lastMessageSendBy'],
                  );
                })
            : const Center(child: Text('An Error Ocurred !'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'CHAT APP',
          style: Theme.of(context).textTheme.bodyText1!.merge(
                const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
        ),
        elevation: 0.0,
      ),
      backgroundColor: Colors.black,
      drawer: MyDrawer(currUser: currUser),
      body: Column(
        children: [
          Wrap(
            children: [
              _searchClicked
                  ? Container(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      margin: const EdgeInsets.only(left: 2, top: 4, bottom: 4),
                      child: IconButton(
                        color: Colors.white,
                        onPressed: () {
                          _searchClicked = false;
                          search.text = '';
                          search.clear;
                          setState(() {});
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                    )
                  : const SizedBox(),
              Container(
                width: _searchClicked
                    ? MediaQuery.of(context).size.width * 0.82
                    : MediaQuery.of(context).size.width,
                margin: _searchClicked
                    ? const EdgeInsets.only(right: 6, top: 4, bottom: 4)
                    : const EdgeInsets.all(6),
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        controller: search,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'search username',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: IconButton(
                        onPressed: () => {
                          _searchClicked = true,
                          search.text.trim().isEmpty ? null : searchQuery()
                        },
                        icon: const Icon(Icons.search),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(
                top: 4,
                left: 6,
                right: 6,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: _searchClicked ? searchUserList() : userList(),
            ),
          ),
        ],
      ),
    );
  }
}
