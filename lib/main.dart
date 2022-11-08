import 'package:flutter/material.dart';
import 'package:flutter_cblite_userprofile_sync/screens/Login.dart';
import 'package:flutter_cblite_userprofile_sync/screens/UniversitySelect.dart';
import 'package:flutter_cblite_userprofile_sync/screens/UserProfile.dart';

import 'CbLiteManager.dart';

Future<void> main() async {
  await CbLiteManager.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Couchbase Profile Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
              secondary: Color(0xffff4081), primary: Color(0xffff0000)),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: 'login_screen',
        routes: {
          Login.id: (context) => Login(),
          UserProfile.id: (context) => UserProfile(),
          UniversitySelect.id: (context) => UniversitySelect()
        });
  }
}
