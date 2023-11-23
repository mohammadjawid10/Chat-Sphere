import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:messenger/helper/shared_prefs_helper.dart';
import 'package:messenger/services/database.dart';
import 'package:messenger/widgets/chat_messages.dart';
import 'package:random_string/random_string.dart';

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
  late final TextEditingController _messageController;

  late String chatRoomId;

  String messageId = '';
  String? myName;
  String? myProfilePic;
  String? myUserName;
  String? myEmail;

  getChatRoomIdByUserNames(String me, String you) {
    if (me.substring(0, 1).codeUnitAt(0) > you.substring(0, 1).codeUnitAt(0)) {
      // ignore: unnecessary_string_escapes
      log('$me\_$you  -- Chat Screen');
      // ignore: unnecessary_string_escapes
      return '$me\_$you';
    } else {
      // ignore: unnecessary_string_escapes
      log('$you\_$me  -- Chat Screen');
      // ignore: unnecessary_string_escapes
      return '$you\_$me';
    }
  }

  getMyInfoFromSharedPreferences() async {
    myName = await SharedPreferencesHelper().getDisplayName();
    myEmail = await SharedPreferencesHelper().getUserEmail();
    myUserName = await SharedPreferencesHelper().getUserName();
    myProfilePic = await SharedPreferencesHelper().getUserProfileUrl();

    chatRoomId = getChatRoomIdByUserNames(myUserName!, widget.username);
    log('chat room id: $chatRoomId');
  }

  addMessage(bool sendClicked) {
    if (_messageController.text.trim().isNotEmpty) {
      String message = _messageController.text.trim().isEmpty
          ? 'Empty String'
          : _messageController.text.trim();

      var lastMessageTs = DateTime.now();

      Map<String, dynamic> messageInfoMap = {
        'message': message,
        'sender': myUserName,
        'timestamp': lastMessageTs,
        'imageUrl': myProfilePic,
      };

      // let's generate a message id
      if (messageId == '') {
        messageId = randomAlphaNumeric(12);
      }

      DatabaseMethods().addMessage(chatRoomId, messageId, messageInfoMap).then(
        (value) {
          Map<String, dynamic> lastMessageInfoMap = {
            'lastMessage': message,
            'lastMessageSendTs': lastMessageTs,
            'lastMessageSender': myUserName,
          };

          DatabaseMethods()
              .updateLastMessageSend(chatRoomId, lastMessageInfoMap);

          if (sendClicked) {
            // if you have clicked the send method then clean the text field
            _messageController.text = '';

            // reset message id to get regenerated on the next message
            messageId = '';
          }
        },
      );
    }
  }

  loadOnLaunch() async {
    await getMyInfoFromSharedPreferences();
  }

  @override
  void initState() {
    _messageController = TextEditingController();
    loadOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Stack(
        children: [
          ChatMessages(
            messageController: _messageController,
            username: widget.username,
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type your message',
                      ),
                      onChanged: (value) {
                        addMessage(false);
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      addMessage(true);
                    },
                    child: const Icon(
                      Icons.send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
