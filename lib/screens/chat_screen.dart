import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat/components/constants.dart';
import 'package:simple_chat/screens/chat_2room.dart';
import 'package:simple_chat/services/auth.dart';
import 'package:simple_chat/services/database_methods.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  ChatScreen({required this.chatRoomId});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  DataBaseMethods dataBaseMethods = DataBaseMethods();
  AuthenticationMethods authenticationMethods = AuthenticationMethods();
  TextEditingController messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  Stream? chatMessageStream;

  @override
  void initState() {
    super.initState();
    dataBaseMethods.getConversationMessages(widget.chatRoomId).then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageController.text,
        "sendBy": Constants.myName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      setState(() {
        dataBaseMethods.addMessages(widget.chatRoomId, messageMap);
        messageController.text = "";
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    }
  }

  Widget chatMessageList() {
    return StreamBuilder(
        stream: chatMessageStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Expanded(
                  child: ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          (snapshot.data! as QuerySnapshot).docs.length + 1,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if (index ==
                            (snapshot.data! as QuerySnapshot).docs.length) {
                          return Container(
                            height: 60.0,
                          );
                        }
                        return MessageTile(
                          message: (snapshot.data! as QuerySnapshot).docs[index]
                              ["message"],
                          isSendByMe: (snapshot.data! as QuerySnapshot)
                                  .docs[index]["sendBy"] ==
                              Constants.myName,
                        );
                      }),
                )
              : Center(child: CircularProgressIndicator());
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ChatRoom()));
          },
        ),
        title: Text(
          'GuffGaff',
          style: TextStyle(
            color: Colors.black,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              chatMessageList(),
              Container(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          onTap: () {},
                          controller: messageController,
                          decoration: kTextFieldDecoration.copyWith(
                              hintText: 'Type your message here'),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          sendMessage();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 17.0, vertical: 4.0),
                          child: Container(
                            width: 75.0,
                            padding: EdgeInsets.all(17.0),
                            decoration: BoxDecoration(
                              color: Colors.lightBlueAccent,
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Text(
                              'Send',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  MessageTile({required this.message, required this.isSendByMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: isSendByMe ? 0 : 24.0, right: isSendByMe ? 24.0 : 0),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      width: MediaQuery.of(context).size.width,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
          borderRadius: isSendByMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(23.0),
                  topRight: Radius.circular(23.0),
                  bottomLeft: Radius.circular(23.0))
              : BorderRadius.only(
                  topLeft: Radius.circular(23.0),
                  topRight: Radius.circular(23.0),
                  bottomRight: Radius.circular(23.0)),
          color: isSendByMe ? Color(0xFF52b7e9) : Color(0xFFE4E6EB),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isSendByMe ? Colors.white : Color(0xFF050505),
            fontSize: 17.0,
          ),
        ),
      ),
    );
  }
}
