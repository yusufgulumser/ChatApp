import 'package:chatting_app/widgets/chat_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final autUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chatMessages')
            .orderBy('created_time', descending: true)
            .snapshots(),
        builder: (ctx, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
            const Center(
              child: Text('no messages'),
            );
          }
          if (snapshots.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          final theMessages = snapshots.data!.docs;
          return ListView.builder(
              padding: const EdgeInsets.only(bottom: 45, left: 15, right: 15),
              reverse: true,
              itemCount: theMessages.length,
              itemBuilder: (ctx, index) {
                final chatMessage = theMessages[index].data();
                final nextMessage = index + 1 < theMessages.length
                    ? theMessages[index + 1].data()
                    : null;
                final currentUserId = chatMessage['userId'];
                final nextUserId =
                    nextMessage != null ? nextMessage['userId'] : null;
                final areUsersSame = currentUserId == nextUserId;
                if (areUsersSame) {
                  return MessageBubble.next(
                      message: chatMessage['message'],
                      isMe: autUser.uid == currentUserId);
                }
                return MessageBubble.first(
                    userImage: chatMessage['userImg'],
                    username: chatMessage['username'],
                    message: chatMessage['message'],
                    isMe: autUser.uid == currentUserId);
              });
        });
  }
}
