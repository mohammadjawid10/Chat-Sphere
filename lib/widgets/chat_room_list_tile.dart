import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:messenger/services/database.dart';
import 'package:messenger/views/chat_screen.dart';

class ChatRoomListTile extends StatefulWidget {
  const ChatRoomListTile({
    Key? key,
    required this.lastMessage,
    required this.chatRoomId,
    required this.myUserName,
  }) : super(key: key);

  final String lastMessage;
  final String chatRoomId;
  final String myUserName;

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = '';
  String userName = '';
  String name = '';

  getThisUserInfo() async {
    userName =
        widget.chatRoomId.replaceAll(widget.myUserName, '').replaceAll('_', '');

    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(userName);

    name = '${querySnapshot.docs[0]['name']}';
    profilePicUrl = '${querySnapshot.docs[0]['imageUrl']}';
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              name: name,
              username: widget.myUserName,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        backgroundImage: NetworkImage(profilePicUrl),
      ),
      title: Text(name),
      subtitle: Text(widget.lastMessage),
    );
  }
}