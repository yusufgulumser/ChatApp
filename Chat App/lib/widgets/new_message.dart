import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});
  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final _textController = TextEditingController();
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final theMessage = _textController.text;
    if (theMessage.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    _textController.clear();

    final userId = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId.uid)
        .get();

    FirebaseFirestore.instance.collection('chatMessages').add({
      'message': theMessage,
      'created_time': Timestamp.now(),
      'userId': userId.uid,
      'userImg': userData.data()!['image'],
      'username': userData.data()!['userName']
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, right: 3, left: 3),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Send a new message',
              ),
              autocorrect: true,
              controller: _textController,
            ),
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
