enum MessageType { user, api }

class MessageModel {
  final String text;
  final MessageType messageType;

  MessageModel({
    required this.text,
    required this.messageType,
  });
}
