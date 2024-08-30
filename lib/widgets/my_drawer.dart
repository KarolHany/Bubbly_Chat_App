import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_chat_app/screens/search_screen.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Drawer(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Drawer(
            child: Center(
              child: Text('Error loading user data'),
            ),
          );
        }

        final userData = snapshot.data;

        return Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 187, 172, 252), // Background color
                ),
                accountName: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    userData?['name'] ?? 'Loading...',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 41, 40, 40)),
                  ),
                ),
                accountEmail: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    userData?['email'] ?? 'Loading...',
                    style: TextStyle(color: Color.fromARGB(255, 87, 85, 85)),
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(userData?['imageUrl'] ?? ''),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home Page'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.search),
                title: Text('Search page'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(),
                      ));
                  // Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
