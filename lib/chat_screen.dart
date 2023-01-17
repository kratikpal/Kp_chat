import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kp_chat/chat_model.dart';
import 'package:kp_chat/chat_widget.dart';
import 'package:http/http.dart' as http;

class MyChat extends StatefulWidget {
  const MyChat({super.key});

  @override
  State<MyChat> createState() => _MyChatState();
}

class _MyChatState extends State<MyChat> {
  final TextEditingController _inputTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<MessageModel> _messages = [];
  late bool isLoading;

  Future<String> _getAnswer(String question) async {
    String apiKey = "API Key";
    String url = "https://api.openai.com/v1/completions";

    Map<String, String> header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey'
    };

    final response = await http.post(
      Uri.parse(url),
      headers: header,
      body: jsonEncode({
        "model": "text-ada-001",
        "prompt": question,
        "temperature": 0,
        "max_tokens": 10,
        "top_p": 1,
        "frequency_penalty": 0.0,
        "presence_penalty": 0.0,
        "stop": ["Human:", "AI:"],
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body.toString());
      var msg = data['choices'][0]['text'];
      return msg;
    } else {
      var errorCode = response.statusCode.toString();
      Fluttertoast.showToast(
          msg: "Error code: +$errorCode",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

      return '0';
    }
  }

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                  child: ListView.builder(
                itemCount: _messages.length,
                controller: _scrollController,
                itemBuilder: (context, index) {
                  var message = _messages[index];
                  return MyChatWidget(
                    text: message.text,
                    messageType: message.messageType,
                  );
                },
              )),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _inputTextController,
                      decoration: const InputDecoration(
                        labelText: 'Ask Anything',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _messages.add(MessageModel(
                          text: _inputTextController.text,
                          messageType: MessageType.user,
                        ));
                        isLoading = true;
                      });
                      var question = _inputTextController.text;
                      _inputTextController.clear();
                      _getAnswer(question).then((value) {
                        setState(() {
                          isLoading = false;
                          _messages.add(MessageModel(
                            text: value,
                            messageType: MessageType.api,
                          ));
                        });
                      });
                    },
                    elevation: 0,
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
