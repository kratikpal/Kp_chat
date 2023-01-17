import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:kp_chat/chat_model.dart';

class MyChatWidget extends StatelessWidget {
  const MyChatWidget({
    super.key,
    required this.text,
    required this.messageType,
  });

  final String text;
  final MessageType messageType;

  @override
  Widget build(BuildContext context) {
    return Bubble(
      elevation: 5,
      margin: const BubbleEdges.only(top: 10),
      radius: const Radius.circular(10.0),
      alignment: messageType == MessageType.user
          ? Alignment.centerRight
          : Alignment.centerLeft,
      nip: messageType == MessageType.user
          ? BubbleNip.rightTop
          : BubbleNip.leftTop,
      color: messageType == MessageType.user
          ? Colors.deepOrange
          : const Color.fromARGB(220, 10, 3, 78),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }
}
