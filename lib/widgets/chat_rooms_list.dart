import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger/services/database.dart';
import 'package:messenger/widgets/chat_room_list_tile.dart';
import 'package:messenger/widgets/search_user_list_tile.dart';

Stream? chatRoomStream;

class ChatRoomsList extends StatefulWidget {
  const ChatRoomsList({Key? key}) : super(key: key);

  @override
  State<ChatRoomsList> createState() => _ChatRoomsListState();
}

class _ChatRoomsListState extends State<ChatRoomsList> {

  getChatRooms() async {
    chatRoomStream = await DatabaseMethods().getChatRooms();
  }

  loadOnLaunch() async {
    await getChatRooms();
  }

  @override
  void initState() {
    loadOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
}
