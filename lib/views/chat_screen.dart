import 'package:flutter/material.dart';
import 'package:messenger/helper/shared_prefs_helper.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key? key,
    required this.name,
    required this.username,
  }) : super(key: key);

  static const routeName = '/chat';

  final String name;
  final String username;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String chatRoomId;
  String messageId = '';
  String? myName;
  String? myProfilePic;
  String? myUserName;
  String? myEmail;

  getMyInfoFromSharedPreferences() async {
    myName = await SharedPreferencesHelper().getDisplayName();
    myEmail = await SharedPreferencesHelper().getUserEmail();
    myUserName = await SharedPreferencesHelper().getUserName();
    myProfilePic = await SharedPreferencesHelper().getUserProfileUrl();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
    );
  }
}
