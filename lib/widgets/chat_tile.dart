import 'package:flutter/material.dart';
import 'package:new_chat_app/screens/chat_screen.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({
    super.key,
    required this.chatId,
    required this.lastMessage,
    required this.time,
    required this.receiverData,
    required this.unreadCount, // Add unreadCount parameter
  });

  final String chatId;
  final String lastMessage;
  final DateTime time;
  final Map<String, dynamic> receiverData;
  final int unreadCount; // Add unreadCount parameter

  @override
  Widget build(BuildContext context) {
    return lastMessage != ''
        ? ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(receiverData['imageUrl']),
            ),
            title: Text(
              receiverData['name'],
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            subtitle: Text(
              lastMessage,
              maxLines: 2,
              style: TextStyle(
                  fontSize: 18, color: Color.fromARGB(255, 86, 83, 83)),
            ),
            trailing: unreadCount > 0
                ? Column(
                    children: [
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        "${time.hour.toString().padLeft(2, '0')} : ${time.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: Text(
                          unreadCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    "${time.hour.toString().padLeft(2, '0')} : ${time.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatId: chatId,
                  receiverId: receiverData['uid'],
                ),
              ),
            ),
          )
        : Container();
  }
}
