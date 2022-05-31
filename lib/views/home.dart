import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:messenger/services/auth.dart';
import 'package:messenger/views/sign_in.dart';
import 'package:messenger/services/database.dart';
import 'package:messenger/views/chat_screen.dart';
import 'package:messenger/helper/shared_prefs_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSearching = false;

  String? myName;
  String? myProfilePic;
  String? myUserName;
  String? myEmail;

  Stream? usersStream;
  Stream? chatRoomStream;

  late final TextEditingController searchUserController;

  getMyInfoFromSharedPreferences() async {
    myName = await SharedPreferencesHelper().getDisplayName();
    myEmail = await SharedPreferencesHelper().getUserEmail();
    myUserName = await SharedPreferencesHelper().getUserName();
    myProfilePic = await SharedPreferencesHelper().getUserProfileUrl();
  }

  loadOnLaunch() async {
    await getMyInfoFromSharedPreferences();
    await getChatRoos();
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

  getChatRoos() async {
    chatRoomStream = await DatabaseMethods().getChatRooms();
  }

  @override
  void initState() {
    searchUserController = TextEditingController();
    loadOnLaunch();
    super.initState();
  }

  Widget searchUsersList() {
    return StreamBuilder(
      stream: usersStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              return searchUserListTile(
                profileUrl: ds['imageUrl'],
                name: ds['name'],
                email: ds['email'],
                username: ds['username'],
              );
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

  Widget searchUserListTile(
      {required String profileUrl, name, email, username}) {
    return ListTile(
      onTap: () {
        var chatRoomId = getChatRoomIdByUserNames(myUserName!, username);

        Map<String, dynamic> chatRoomInfoMap = {
          'users': [myUserName, username],
        };

        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              name: name,
              username: username,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        backgroundImage: NetworkImage(profileUrl),
      ),
      title: Text(name),
      subtitle: Text(email),
    );
  }

  onSearch() async {
    setState(() {
      isSearching = true;
    });
    usersStream = await DatabaseMethods().getUserByUserName(
      searchUserController.text,
    );
  }

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRoomStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];

              return ChatRoomListTile(
                lastMessage: ds['lastMessage'],
                chatRoomId: ds.id,
                myUserName: myUserName!,
              );
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              AuthMethods().signOut(context).then(
                (_) {
                  Navigator.of(context)
                      .pushReplacementNamed(SignInScreen.routeName);
                },
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              children: [
                isSearching
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            isSearching = false;
                            searchUserController.text = '';
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.arrow_back),
                        ),
                      )
                    : const SizedBox.shrink(),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchUserController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search',
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (searchUserController.text.isNotEmpty) {
                              onSearch();
                            }
                          },
                          child: const Icon(Icons.search),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isSearching ? searchUsersList() : chatRoomsList(),
          ],
        ),
      ),
    );
  }
}

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
