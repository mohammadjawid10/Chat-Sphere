import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messenger/helper/shared_prefs_helper.dart';

class DatabaseMethods {
  Future addUserInfoToDatabase(
      String userId, Map<String, dynamic> userInfoMap) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getUserByUserName(String username) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .snapshots();
  }

  Future addMessage(
    String chatRoomId,
    String messageId,
    Map<String, dynamic> messageInfoMap,
  ) async {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('chats')
        .doc(messageId)
        .set(messageInfoMap);
  }

  updateLastMessageSend(
      String chatRoomId, Map<String, dynamic> lastMessageInfoMap) {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }

  createChatRoom(
      String chatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .get();

    if (snapshot.exists) {
      // chatroom already exists
      return true;
    } else {
      // chatroom doesn't exist, so let's create it
      if(chatRoomId.isNotEmpty) {
        return FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
      }
    }
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String? myUserName = await SharedPreferencesHelper().getUserName();
    return FirebaseFirestore.instance
        .collection('chatrooms')
        // .orderBy('lastMessageSendTs')
        .where('users', arrayContains: myUserName)
        .snapshots();
  }

  Future<QuerySnapshot> getUserInfo(String userName) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: userName)
        .get();
  }
}
