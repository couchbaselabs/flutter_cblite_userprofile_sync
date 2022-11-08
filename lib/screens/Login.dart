import 'package:flutter/material.dart';

import '../CbLiteManager.dart';
import 'UserProfile.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  static String id = 'login_screen';

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String username = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: 300,
                                height: 300,
                                child: const Image(
                                    image: AssetImage("assets/logo.png")))
                          ]),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 35, right: 35),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 500,
                              child: TextField(
                                // cursorColor: Colors.black,
                                onChanged: (value) {
                                  username = value;
                                },
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                    fillColor: Colors.grey.shade100,
                                    filled: true,
                                    hintText: "Username",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            BorderSide(color: Colors.black))),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            SizedBox(
                              width: 500,
                              child: TextField(
                                onChanged: (value) {
                                  password = value;
                                },
                                obscureText: true,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                    fillColor: Colors.grey.shade100,
                                    filled: true,
                                    hintText: "Password",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            BorderSide(color: Colors.black))),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sign in',
                                  style: TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Color(0xffff0000),
                                  child: IconButton(
                                      color: Colors.white,
                                      onPressed: () async {
                                        if (username.length > 0 &&
                                            password.length > 0) {
                                          await CbLiteManager
                                                  .getSharedInstance()
                                              .openOrCreateDatabaseForUser(
                                                  username, password);
                                          await CbLiteManager
                                                  .getSharedInstance()
                                              .openPrebuiltDatabase();

                                          Navigator.pushNamed(
                                              context, UserProfile.id);
                                        }
                                      },
                                      icon: Icon(
                                        Icons.arrow_forward,
                                      )),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
