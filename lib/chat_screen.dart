import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kp_chat/chat_model.dart';
import 'package:kp_chat/widgets/chat_widget.dart';
import 'package:http/http.dart' as http;
import 'package:kp_chat/widgets/drawer_widget.dart';

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
  bool isConnected = false;
  final Connectivity _connectivity = Connectivity();

  void _scrollDown() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  Future<void> _checkConnectivity() async {
    var connectionResult = await _connectivity.checkConnectivity();
    if (connectionResult == ConnectivityResult.none) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: 'No Internet Connection',
        desc: 'Please connect to internet and try again...',
        btnOkOnPress: () => _checkConnectivity(),
      ).show();
      setState(() => isConnected = false);
    } else {
      setState(() => isConnected = true);
    }
  }

  // Api call
  Future<String> _getAnswer(String question) async {
    String apiKey = "Api Key";
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
        "max_tokens": 20,
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
    _checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(builder: (context) {
          return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu));
        }),
        actions: [
          IconButton(
            onPressed: () {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.warning,
                animType: AnimType.scale,
                title: 'Delete Conversation',
                desc: 'Are you sure to delete conversation permanently...',
                btnOkOnPress: () {
                  if (_messages.isNotEmpty) {
                    _messages.clear();
                    setState(() {});
                  }
                },
                btnCancelOnPress: () {},
              ).show();
            },
            icon: const Icon(Icons.delete_outline_rounded),
          )
        ],
      ),
      drawer: const MyAppDrawer(),
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
                      onPressed: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        await _checkConnectivity();
                        if (isConnected) {
                          if (_inputTextController.text.isEmpty) {
                            Fluttertoast.showToast(
                                msg: "Enter some text",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.deepOrange,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          } else if (isLoading) {
                          } else {
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
                              Timer(const Duration(seconds: 3), () {
                                _scrollDown();
                              });
                            });
                          }
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
