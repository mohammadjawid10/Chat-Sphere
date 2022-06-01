import 'dart:developer';

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

  getChatRoomIdByUserNames(String me, String you) {
    if (me == you) {
      log('Empty -- Chat List Tile');
      return '';
    } else if (me.substring(0, 1).codeUnitAt(0) >
        you.substring(0, 1).codeUnitAt(0)) {
      // ignore: unnecessary_string_escapes
      log('$me\_$you -- Chat List Tile');
      // ignore: unnecessary_string_escapes
      return '$me\_$you';
    } else {
      // ignore: unnecessary_string_escapes
      log('$you\_$me -- Chat List Tile');
      // ignore: unnecessary_string_escapes
      return '$you\_$me';
    }
  }

  getThisUserInfo() async {
    userName =
        widget.chatRoomId.replaceAll(widget.myUserName, '').replaceAll('_', '');

    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(userName);

    name = '${querySnapshot.docs[0]['name']}';
    profilePicUrl = '${querySnapshot.docs[0]['imageUrl']}';
    setState(() {});
  }

  loadOnLaunch() async {
    await getThisUserInfo();
  }

  @override
  void initState() {
    loadOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        var chatRoomId = getChatRoomIdByUserNames(widget.myUserName, userName);

        Map<String, dynamic> chatRoomInfoMap = {
          'users': [widget.myUserName, userName],
        };

        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              name: name,
              username: userName,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        backgroundImage: profilePicUrl.isNotEmpty ? NetworkImage(profilePicUrl) : const NetworkImage('http://picsum.photos/seed/1/300/300'),
      ),
      title: Text(name),
      subtitle: Text(widget.lastMessage),
    );
  }
}
