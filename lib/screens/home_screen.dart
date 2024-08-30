import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_chat_app/provider/chat_provider.dart';
import 'package:new_chat_app/screens/login_screen.dart';
import 'package:new_chat_app/screens/search_screen.dart';
import 'package:new_chat_app/widgets/chat_tile.dart';
import 'package:new_chat_app/widgets/my_drawer.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  User? LoggedInUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        LoggedInUser = user;
      });
    }
  }

  // Future<Map<String, dynamic>> _fetchChatData(String chatId) async {
  //   final chatDoc =
  //       await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
  //   final chatData = chatDoc.data();
  //   final users = chatData!['users'] as List<dynamic>;
  //   final receverId = users.firstWhere(
  //     (id) => id != LoggedInUser!.uid,
  //   );
  //   final userDoc = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(receverId)
  //       .get();
  //   final userData = userDoc.data()!;
  //   return {
  //     'chatId': chatId,
  //     'lastMessage': chatData['lastMessage'] ?? '',
  //     'timestamp': chatData['timestamp']?.toDate() ?? DateTime.now(),
  //     'userData': userData,
  //   };
  // }

  Future<Map<String, dynamic>> _fetchChatData(String chatId) async {
    final chatDoc =
        await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
    final chatData = chatDoc.data()!;
    final users = chatData['users'] as List<dynamic>;
    final receiverId = users.firstWhere(
      (id) => id != LoggedInUser!.uid,
    );
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .get();
    final userData = userDoc.data()!;

    // Count unread messages
    final unreadMessages = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: LoggedInUser!.uid)
        .where('isRead', isEqualTo: false)
        .get();

    final unreadCount = unreadMessages.docs.length;

    return {
      'chatId': chatId,
      'lastMessage': chatData['lastMessage'] ?? '',
      'timestamp': chatData['timestamp']?.toDate() ?? DateTime.now(),
      'userData': userData,
      'unreadCount': unreadCount, // Add unread count to the result
    };
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      // backgroundColor: Color.fromARGB(255, 169, 150, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 187, 172, 252),
        title: const Text(
          'Chats',
          style: TextStyle(fontSize: 30),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _auth.signOut();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      drawer: MyDrawer(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              Color.fromARGB(255, 243, 204, 217),
              Color(0xFFB39DDB),
            ])),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: chatProvider.getChats(LoggedInUser!.uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final chatDocs = snapshot.data!.docs;
                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: Future.wait(chatDocs.map(
                      (chatDoc) => _fetchChatData(chatDoc.id),
                    )),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final chatDataList = snapshot.data!;
                      return ListView.builder(
                        itemCount: chatDataList.length,
                        itemBuilder: (context, index) {
                          final chatData = chatDataList[index];
                          return ChatTile(
                            chatId: chatData['chatId'],
                            lastMessage: chatData['lastMessage'],
                            time: chatData['timestamp'],
                            receiverData: chatData['userData'],
                            unreadCount: chatData[
                                'unreadCount'], // Pass the unread count
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(),
            ),
          );
        },
        backgroundColor: Color.fromARGB(255, 187, 172, 252),
        child: Icon(Icons.search),
      ),
    );
  }
}
