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

  late final TextEditingController searchUserController;

  getMyInfoFromSharedPreferences() async {
    myName = await SharedPreferencesHelper().getDisplayName();
    myEmail = await SharedPreferencesHelper().getUserEmail();
    myUserName = await SharedPreferencesHelper().getUserName();
    myProfilePic = await SharedPreferencesHelper().getUserProfileUrl();
  }

  loadOnLaunch() async {
    await getMyInfoFromSharedPreferences();
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
  void initState() {
    searchUserController = TextEditingController();
    loadOnLaunch();
    super.initState();
  }

  onSearch() async {
    setState(() {
      isSearching = true;
    });
    usersStream = await DatabaseMethods().getUserByUserName(
      searchUserController.text,
    );
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

  Widget searchChatRooms() {
    return Container();
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
            isSearching ? searchUsersList() : searchChatRooms(),
          ],
        ),
      ),
    );
  }
}
