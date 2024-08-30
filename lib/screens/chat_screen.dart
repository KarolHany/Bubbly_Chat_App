import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:new_chat_app/provider/chat_provider.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chatId, required this.receiverId});
  final String? chatId;
  final String receiverId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User? loggedInUser;
  String? chatId;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    chatId = widget.chatId;
    getCurrentUser();
    if (chatId != null && chatId!.isNotEmpty) {
      markMessagesAsRead(
          chatId!); // Mark messages as read when the chat screen is opened
    }
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  // Future<void> _showNotification(String message) async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     'your_channel_id',
  //     'your_channel_name',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     playSound: true,
  //   );
  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);

  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     'New Message',
  //     message,
  //     platformChannelSpecifics,
  //     payload: 'item x',
  //   );
  // }

  Future<void> markMessagesAsRead(String chatId) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.markMessagesAsRead(chatId);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(widget.receiverId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final receiverData = snapshot.data!.data() as Map<String, dynamic>;
            return Scaffold(
              backgroundColor: Color.fromARGB(255, 250, 229, 253),
              appBar: AppBar(
                backgroundColor: const Color.fromARGB(255, 174, 156, 255),
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(receiverData['imageUrl']),
                    ),
                    const SizedBox(width: 20),
                    Text(receiverData['name']),
                  ],
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: chatId != null && chatId!.isNotEmpty
                        ? MessagesStream(chatId: chatId!)
                        : const Center(
                            child: Text('No Messages Yet!'),
                          ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _textController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your message..',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (_textController.text.isNotEmpty) {
                              final text = _textController.text;
                              _textController.clear();
                              if (chatId == null || chatId!.isEmpty) {
                                chatId = await chatProvider
                                    .createChatRoom(widget.receiverId);
                              }
                              if (chatId != null) {
                                await chatProvider.sendMessage(
                                  chatId!,
                                  text,
                                  widget.receiverId,
                                );
                                //  _showNotification('You sent: ${_textController.text}');
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Color.fromARGB(255, 174, 156, 255),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: Text('User not found!'),
              ),
            );
          }
        }
        return Scaffold(
          appBar: AppBar(),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class MessagesStream extends StatelessWidget {
  final String chatId;
  const MessagesStream({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final messages = snapshot.data!.docs;
        List<MessageBubble> messageWidgets = [];
        for (var message in messages) {
          final messageData = message.data() as Map<String, dynamic>;
          final messageText = messageData['message'];
          final messageSender = messageData['senderId'];
          final timeStamp = messageData['timestamp'] != null
              ? messageData['timestamp'] as Timestamp
              : Timestamp.now();
          final isRead =
              messageData['isRead'] ?? false; // Fetch the isRead status
          final currentUser = FirebaseAuth.instance.currentUser!.uid;
          final messageWidget = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
            time: timeStamp,
            isRead: isRead, // Pass the read status to MessageBubble
          );
          messageWidgets.add(messageWidget);
        }
        return ListView(
          reverse: true,
          children: messageWidgets,
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final Timestamp time;
  final bool isMe;
  final bool isRead; // New parameter

  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.time,
    required this.isMe,
    required this.isRead, // Initialize new parameter
  });

  @override
  Widget build(BuildContext context) {
    final DateTime messageTime = time.toDate();
    final formattedTime =
        "${messageTime.hour}:${messageTime.minute.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 4,
                ),
              ],
              borderRadius: isMe
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    )
                  : const BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
              color: isMe
                  ? (isRead ? Colors.purple.shade200 : Colors.purple.shade300)
                  : (isRead ? Colors.pink.shade200 : Colors.pink.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formattedTime,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
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
