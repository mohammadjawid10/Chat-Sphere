import 'package:flutter/material.dart';
import 'package:messenger/helper/shared_prefs_helper.dart';
import 'package:messenger/services/database.dart';
import 'package:messenger/widgets/chat_messages.dart';
import 'package:messenger/widgets/search_user_list_tile.dart';
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

  getMyInfoFromSharedPreferences() async {
    myName = await SharedPreferencesHelper().getDisplayName();
    myEmail = await SharedPreferencesHelper().getUserEmail();
    myUserName = await SharedPreferencesHelper().getUserName();
    myProfilePic = await SharedPreferencesHelper().getUserProfileUrl();

    chatRoomId = getChatRoomIdByUserNames(myUserName!, widget.username);
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

  @override
  void initState() {
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
