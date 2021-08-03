import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:simple_chat/screens/chat_2room.dart';
import 'package:simple_chat/screens/welcome_screen.dart';
import 'package:simple_chat/services/helperfunction.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(GuffGaff());
}
class GuffGaff extends StatefulWidget {
  @override
  _GuffGaffState createState() => _GuffGaffState();
}

class _GuffGaffState extends State<GuffGaff> {
  bool userIsLoggedIn = false;
  @override
  void initState() {
    super.initState();
    getLoggedInState();
  }

  getLoggedInState() async {
    await HelperFunction.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        userIsLoggedIn = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: userIsLoggedIn ? ChatRoom() : WelcomeScreen(),
    );
  }
}
