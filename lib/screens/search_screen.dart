import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat/components/constants.dart';
import 'package:simple_chat/screens/chat_screen.dart';
import 'package:simple_chat/services/database_methods.dart';
import 'package:simple_chat/services/helperfunction.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  DataBaseMethods dataBaseMethods = DataBaseMethods();
  TextEditingController _searchTextEditingController =
      new TextEditingController();
  bool isExecuted = false;
  QuerySnapshot? snapShotData;
  initiateSearch() {
    dataBaseMethods
        .getUserByUserName(_searchTextEditingController.text)
        .then((value) {
      setState(() {
        snapShotData = value;
      });
    });
  }

  getUserInfo() async {
    Constants.myName = await HelperFunction.getUserNameSharedPreference();
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  createChatRoomAndStartConversation({required String userName}) {
    if (userName != Constants.myName) {
      String chatRoomId = getChatRoomId(userName, Constants.myName);
      List<String> users = [userName, Constants.myName];
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatRoomId": chatRoomId,
      };
      dataBaseMethods.createChatRoom(chatRoomId, chatRoomMap);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ChatScreen(chatRoomId: chatRoomId)));
    } else {
      print('You cannot send message to yourself');
    }
  }

  Widget searchTile({required String userName, required String userEmail}) {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    userName,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20.0,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                createChatRoomAndStartConversation(userName: userName);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget searchList() {
    if (snapShotData != null) {
      return ListView.builder(
          itemCount: snapShotData!.docs.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return searchTile(
              userName: snapShotData!.docs[index]["name"],
              userEmail: snapShotData!.docs[index]["email"],
            );
          });
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Find New Friends',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _searchTextEditingController,
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Search by name'),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      initiateSearch();
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.search_rounded,
                        color: Colors.pinkAccent,
                        size: 45.0,
                      ),
                    ),
                  ),
                ],
              ),
              searchList(),
            ],
          ),
        ),
      ),
    );
  }
}

getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) >
      Constants.myName.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
