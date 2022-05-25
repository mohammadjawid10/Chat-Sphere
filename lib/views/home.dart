import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger/services/auth.dart';
import 'package:messenger/services/database.dart';
import 'package:messenger/views/chat_screen.dart';
import 'package:messenger/views/sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSearching = false;
  Stream? usersStream;

  late final TextEditingController searchUserController;

  @override
  void initState() {
    searchUserController = TextEditingController();
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
