import 'package:flutter/material.dart';

import 'package:messenger/helper/shared_prefs_helper.dart';
import 'package:messenger/services/database.dart';
import 'package:messenger/views/chat_screen.dart';

class SearchUserListTile extends StatefulWidget {
  const SearchUserListTile({
    Key? key,
    required this.profileUrl,
    required this.name,
    required this.email,
    required this.username,
  }) : super(key: key);

  final String profileUrl, name, email, username;

  @override
  State<SearchUserListTile> createState() => _SearchUserListTileState();
}

class _SearchUserListTileState extends State<SearchUserListTile> {
  getChatRoomIdByUserNames(String me, String you) {
    if (me == you) {
      return '';
    } else if (me.substring(0, 1).codeUnitAt(0) >
        you.substring(0, 1).codeUnitAt(0)) {
      // ignore: unnecessary_string_escapes
      return '$me\_$you';
    } else {
      // ignore: unnecessary_string_escapes
      return '$you\_$me';
    }
  }

  String? myName, myProfilePic, myUserName, myEmail;

  getMyInfoFromSharedPreferences() async {
    myName = await SharedPreferencesHelper().getDisplayName();
    myEmail = await SharedPreferencesHelper().getUserEmail();
    myUserName = await SharedPreferencesHelper().getUserName();
    myProfilePic = await SharedPreferencesHelper().getUserProfileUrl();
  }

  loadOnLaunch() async {
    await getMyInfoFromSharedPreferences();
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
        var chatRoomId = getChatRoomIdByUserNames(myUserName!, widget.username);

        Map<String, dynamic> chatRoomInfoMap = {
          'users': [myUserName, widget.username],
        };

        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              name: widget.name,
              username: widget.username,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        backgroundImage: NetworkImage(widget.profileUrl),
      ),
      title: Text(widget.name),
      subtitle: Text(widget.email),
    );
  }
}
