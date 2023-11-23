import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger/helper/shared_prefs_helper.dart';
import 'package:messenger/services/database.dart';
import 'package:messenger/widgets/message_tile.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({
    Key? key,
    required this.messageController,
    required this.username,
  }) : super(key: key);

  final TextEditingController messageController;
  final String username;

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  Stream? messageStream;

  late String chatRoomId;
  
  String? myUserName;

  getMyInfoFromSharedPreferences() async {
    myUserName = await SharedPreferencesHelper().getUserName();

    chatRoomId = getChatRoomIdByUserNames(myUserName!, widget.username);
  }

  getChatRoomIdByUserNames(String me, String you) {
    if (me.substring(0, 1).codeUnitAt(0) > you.substring(0, 1).codeUnitAt(0)) {
      // ignore: unnecessary_string_escapes
      return '$me\_$you';
    } else {
      // ignore: unnecessary_string_escapes
      return '$you\_$me';
    }
  }

  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  doThisOnLaunch() async {
    await getMyInfoFromSharedPreferences();
    getAndSetMessages();
  }

  @override
  void initState() {
    doThisOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: messageStream,
      builder: (cotext, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            reverse: true,
            padding: const EdgeInsets.only(bottom: 70, top: 15),
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              return MessageTile(ds['message'], myUserName == ds['sender']);
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
