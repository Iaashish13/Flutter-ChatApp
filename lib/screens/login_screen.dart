import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat/components/constants.dart';
import 'package:simple_chat/components/my_widgets.dart';
import 'package:simple_chat/screens/chat_2room.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:simple_chat/services/auth.dart';
import 'package:simple_chat/services/database_methods.dart';
import 'package:simple_chat/services/helperfunction.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showSpinner = false;

  AuthenticationMethods authenticationMethods = AuthenticationMethods();
  DataBaseMethods dataBaseMethods = DataBaseMethods();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  QuerySnapshot? snapShotUserInfo;
  final formGlobalKey = GlobalKey<FormState>();

  signIn() async {
    if (formGlobalKey.currentState!.validate()) {
      setState(() {
        showSpinner = true;
      });
      authenticationMethods.signInWithEmailAndPassword(
          emailTextEditingController.text, passwordTextEditingController.text);
      HelperFunction.saveEmailSharedPreference(
        emailTextEditingController.text,
      );
      dataBaseMethods
          .getUserByUserEmail(emailTextEditingController.text)
          .then((value) {
        snapShotUserInfo = value;
        print(snapShotUserInfo);
        HelperFunction.saveUserNameSharedPreference(
            snapShotUserInfo!.docs[0]["name"]);
      });
      HelperFunction.getUserNameSharedPreference()
          .then((value) => print('$value Name initialised'));
      HelperFunction.saveUserLoggedInSharedPreference(true);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ChatRoom()));
      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        child: Hero(
                          tag: 'logo',
                          child: Container(
                            child: new Image.asset('images/logo.png'),
                            height: 100.0,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Form(
                        key: formGlobalKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              validator: (value) {
                                return RegExp(
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(value!)
                                    ? null
                                    : 'Please provide valid email!';
                              },
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.emailAddress,
                              controller: emailTextEditingController,
                              decoration: kTextFieldDecoration.copyWith(
                                  hintText: 'Enter your email'),
                            ),
                            SizedBox(
                              height: 30.0,
                            ),
                            TextFormField(
                              validator: (value) {
                                return value!.length > 6
                                    ? null
                                    : 'Password must contain six characters';
                              },
                              obscureText: true,
                              controller: passwordTextEditingController,
                              textAlign: TextAlign.center,
                              decoration: kTextFieldDecoration.copyWith(
                                  hintText: 'Enter your password'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          const snackBar = SnackBar(
                              content: Text(
                                  'Please check your email for Verification'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          authenticationMethods
                              .resetPassword(emailTextEditingController.text);
                        },
                        child: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 8.0),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.black87,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      MyButton(
                        name: 'Login',
                        colour: Colors.lightBlueAccent,
                        onPressed: () {
                          signIn();
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      // MyButton(
                      //     colour: Colors.redAccent,
                      //     name: 'Sign in with Google',
                      //     onPressed: () {
                      //       const snackBar = SnackBar(
                      //           content: Text('It will be available soon'));
                      //       ScaffoldMessenger.of(context)
                      //           .showSnackBar(snackBar);
                      //     }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
