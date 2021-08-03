import 'package:flutter/material.dart';
import 'package:simple_chat/components/constants.dart';
import 'package:simple_chat/components/my_widgets.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:simple_chat/screens/search_screen.dart';
import 'package:simple_chat/services/auth.dart';
import 'package:simple_chat/services/database_methods.dart';
import 'package:simple_chat/services/helperfunction.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool showSpinner = false;
  AuthenticationMethods authenticationMethods = AuthenticationMethods();
  DataBaseMethods dataBaseMethods = DataBaseMethods();

  final formGlobalKey = GlobalKey<FormState>();
  TextEditingController userNameTextEditingController =
      new TextEditingController();
  TextEditingController emailTextEditingController =
      new TextEditingController();
  TextEditingController passwordTextEditingController =
      new TextEditingController();
  signMeUp() {
    if (formGlobalKey.currentState!.validate()) {
      setState(() {
        showSpinner = true;
      });
      Map<String, String> userInfoMap = {
        'name': userNameTextEditingController.text,
        'email': emailTextEditingController.text,
      };

      authenticationMethods
          .signUpWithEmailAndPassword(emailTextEditingController.text,
              passwordTextEditingController.text)
          .then((value) {
        print("$value");
        HelperFunction.saveEmailSharedPreference(
            emailTextEditingController.text);
        HelperFunction.saveUserNameSharedPreference(
            userNameTextEditingController.text);
        dataBaseMethods.uploadUserInfo(userInfoMap);
        HelperFunction.saveUserLoggedInSharedPreference(true);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SearchScreen()));
        setState(() {
          showSpinner = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Flexible(
                      child: Hero(
                        tag: 'logo',
                        child: Container(
                          child: new Image.asset('images/logo.png'),
                          height: 200.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    Form(
                      key: formGlobalKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            validator: (value) {
                              return value!.isEmpty || value.length < 2
                                  ? 'Please provide valid username!'
                                  : null;
                            },
                            textAlign: TextAlign.center,
                            controller: userNameTextEditingController,
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: 'Enter your name'),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
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
                            height: 20.0,
                          ),
                          TextFormField(
                            validator: (value) {
                              return value!.length > 6
                                  ? null
                                  : 'Password must contain six characters';
                            },
                            obscureText: true,
                            textAlign: TextAlign.center,
                            controller: passwordTextEditingController,
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: 'Enter your password'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    MyButton(
                      name: 'Register',
                      colour: Colors.blue,
                      onPressed: () {
                        signMeUp();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
