import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_chat_app/provider/chat_provider.dart';
import 'package:new_chat_app/screens/chat_screen.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  void handleSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      // backgroundColor: Color.fromARGB(255, 110, 75, 122),
      appBar: AppBar(
        title: Text(
          'Search',
          style: TextStyle(fontSize: 25),
        ),
        backgroundColor: Color.fromARGB(255, 187, 172, 252),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextFormField(
              onChanged: handleSearch,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search users...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: searchQuery.isEmpty
                ? Center(child: Text('Enter a search query'))
                : StreamBuilder<QuerySnapshot>(
                    // real time data
                    stream: chatProvider.searchUser(searchQuery),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      final users = snapshot.data!.docs;
                      if (users.isEmpty) {
                        return Center(child: Text('No users found.'));
                      }
                      List<UserTile> userWidgets = users.map((user) {
                        final userData = user.data() as Map<String, dynamic>;
                        return UserTile(
                          userId: userData['uid'],
                          name: userData['name'],
                          email: userData['email'],
                          imageUrl: userData['imageUrl'],
                        );
                      }).toList();
                      return ListView(children: userWidgets);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final String userId;
  final String name;
  final String email;
  final String imageUrl;

  const UserTile({
    super.key,
    required this.userId, // receverId
    required this.name,
    required this.email,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 3),
      child: ListTile(
        tileColor: Color.fromARGB(255, 210, 200, 252),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(
          name,
          style: TextStyle(fontSize: 19),
        ),
        subtitle: Text(email),
        onTap: () async {
          final chatId = await chatProvider.getChatRoom(userId) ??
              await chatProvider.createChatRoom(userId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatId: chatId,
                receiverId: userId,
              ),
            ),
          );
        },
      ),
    );
  }
}
