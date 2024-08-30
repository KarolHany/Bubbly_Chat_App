import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getChats(String userId) {
    return _firestore
        .collection('chats')
        .where('users', arrayContains: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> searchUser(String query) {
    return _firestore
        .collection('users')
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email',
            isLessThanOrEqualTo: query +
                '\uf8ff') //This condition helps define the upper bound for the search.
        .snapshots();
  }

  // Future<void> sendMessage(
  //     String chatId, String message, String recieverId) async {
  //   final currentUser = _auth.currentUser;
  //   if (currentUser != null) {
  //     await _firestore
  //         .collection('chats')
  //         .doc(chatId)
  //         .collection('messages')
  //         .add({
  //       'senderId': currentUser.uid,
  //       'recieverId': recieverId,
  //       'message': message,
  //       'timestamp': Timestamp.now(),

  //     });
  //   }
  //   await _firestore.collection('chats').doc(chatId).set({
  //     'users': [currentUser!.uid, recieverId],
  //     'lastMessage': message,
  //     'timestamp': Timestamp.now(),
  //   }, SetOptions(merge: true));
  // }

  Future<void> sendMessage(
      String chatId, String message, String receiverId) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Add the message to the 'messages' subcollection
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': currentUser.uid,
        'receiverId': receiverId,
        'message': message,
        'timestamp': Timestamp.now(),
        'isRead': false, // Set isRead to false when the message is sent
      });

      // Update the 'chats' collection with the latest message details
      await _firestore.collection('chats').doc(chatId).set({
        'users': [currentUser.uid, receiverId],
        'lastMessage': message,
        'timestamp': Timestamp.now(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> markMessagesAsRead(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      for (var message in unreadMessages.docs) {
        await message.reference.update({'isRead': true});
      }
    }
  }

  Future<String?> getChatRoom(String receiverId) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final chatQuery = await _firestore
          .collection('chats')
          .where('users', arrayContains: currentUser.uid)
          .get();
      final chatId = chatQuery.docs
          .where((chat) => chat['users'].contains(receiverId))
          .toList();

      if (chatId.isNotEmpty) {
        return chatId.first.id;
      }
    }
    return null;
  }

  Future<String> createChatRoom(String receiverId) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final chatRoom = await _firestore.collection('chats').add({
        'users': [currentUser.uid, receiverId],
        'lastMessage': '',
        'timestamp': Timestamp.now(),
      });
      return chatRoom.id;
    }
    throw Exception('Current User is null!');
  }
}



/*

the flow in firestore:

+--------------------+
| users              |
+--------------------+
| userId (document)  |
|  - uid             |
|  - name            |
|  - email           |
|  - imageUrl        |
|  + chats (subcollection) |
|    + chatId (document)   |
|      - users                |
|      - lastMessage          |
|      - timestamp            |
|      + messages (subcollection) |
|        + messageId (document)  |
|          - senderId         |
|          - receiverId       |
|          - message          |
|          - timestamp        |
+--------------------+
*/
