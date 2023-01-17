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
  static const backgroundColor = Color(0xff343541);
  static const botBackgroundColor = Color(0xff444654);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(16),
      color:
          messageType == MessageType.api ? botBackgroundColor : backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          messageType == MessageType.api
              ? Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: const CircleAvatar(
                    backgroundColor: Color.fromRGBO(16, 163, 127, 1),
                    child: Icon(
                      Icons.abc,
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: const CircleAvatar(
                    child: Icon(
                      Icons.person,
                    ),
                  ),
                ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
