import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger/constants/colors.dart';
import 'package:messenger/helper/shared_prefs_helper.dart';
import 'package:messenger/services/database.dart';
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

  Stream? messageStream;

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

  Widget messageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment: sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: sendByMe ? messageBlueColor : messageGrayColor,
              borderRadius: BorderRadius.only(
                topLeft: sendByMe ? const Radius.circular(15) : Radius.zero,
                topRight: sendByMe ? Radius.zero : const Radius.circular(15),
                bottomLeft: const Radius.circular(15),
                bottomRight: const Radius.circular(15),
              )
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget chatMessages() {
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
              return messageTile(ds['message'], myUserName == ds['sender']);
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

  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  addMessage(bool sendClicked) {
    if (_messageController.text.isNotEmpty) {
      String message = _messageController.text;

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

      DatabaseMethods()
          .addMessage(chatRoomId, messageId, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          'lastMessage': message,
          'lastMessageSendTs': lastMessageTs,
          'lastMessageSender': myUserName,
        };

        DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfoMap);

        if (sendClicked) {
          // if you have clicked the send method then clean the text field
          _messageController.text = '';

          // reset message id to get regenerated on the next message
          messageId = '';
        }
      });
    }
  }

  doThisOnLaunch() async {
    await getMyInfoFromSharedPreferences();
    getAndSetMessages();
  }

  @override
  void initState() {
    doThisOnLaunch();
    _messageController = TextEditingController();
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
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
