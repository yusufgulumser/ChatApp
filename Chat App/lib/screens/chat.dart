import 'package:chatting_app/widgets/chat_messages.dart';
import 'package:chatting_app/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;
final _fireBaseMessaging = FirebaseMessaging.instance;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupNoti() async {
    await _fireBaseMessaging.requestPermission();
    _fireBaseMessaging.subscribeToTopic('chatMessages');
  }

  @override
  void initState() {
    super.initState();
    setupNoti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chat App'),
          actions: [
            IconButton(
                onPressed: () {
                  _firebase.signOut();
                },
                icon: const Icon(Icons.logout))
          ],
        ),
        body: const Column(
          children: [
            Expanded(child: ChatMessages()),
            NewMessage(),
          ],
        ));
  }
}
