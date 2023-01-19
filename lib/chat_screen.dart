import 'dart:async';
import 'dart:convert';
import 'dart:ui';

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

  void _scrollDown() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  Future<String> _getAnswer(String question) async {
    String apiKey = "Api key";
    String url = "https://api.openai.com/v1/completions";

    Map<String, String> header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey'
    };

    final response = await http.post(
      Uri.parse(url),
      headers: header,
      body: jsonEncode({
        "model": "text-davinci-003",
        "prompt": question,
        "temperature": 0,
        "max_tokens": 5,
        "top_p": 1,
        "frequency_penalty": 0.0,
        "presence_penalty": 0.0,
        "stop": ["Human:", "AI:"],
      }),
    );

    var data = jsonDecode(response.body.toString());
    if (response.statusCode == 200) {
      return data['choices'][0]['text'];
    } else {
      var error = data['error'];
      return error!["message"];
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
      body: Stack(fit: StackFit.expand, children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 20),
          child: Image.asset(
            "assets/images/4954390_2599646.jpg",
            fit: BoxFit.fill,
          ),
        ),
        SafeArea(
          child: Column(
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
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _inputTextController,
                        decoration: InputDecoration(
                          labelText: 'Ask Anything',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        if (_inputTextController.text.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "Enter some text",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.deepOrange,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            _messages.add(MessageModel(
                              text: _inputTextController.text,
                              messageType: MessageType.user,
                            ));
                            isLoading = true;
                            _scrollDown();
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
                            Timer(const Duration(milliseconds: 50), () {
                              _scrollDown();
                            });
                          });
                        }
                      },
                      elevation: 0,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 18,
                            ),
                    ),
                  ],
                ),
              ),
              const Text(
                "Made by Kratikpal",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
