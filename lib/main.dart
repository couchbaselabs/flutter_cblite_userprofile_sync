import 'package:flutter/material.dart';

import 'data/couchbase_lite_manager.dart';
import 'screens/login_screen.dart';
import 'screens/university_picker_screen.dart';
import 'screens/user_profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CouchbaseLiteManager.init();
  runApp(const CouchbaseProfileManager());
}

class CouchbaseProfileManager extends StatelessWidget {
  const CouchbaseProfileManager({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Couchbase Profile Manager',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          secondary: Color(0xffff4081),
          primary: Color(0xffff0000),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: LoginScreen.id,
      routes: {
        LoginScreen.id: (context) => const LoginScreen(),
        UserProfileScreen.id: (context) => const UserProfileScreen(),
        UniversityPickerScreen.id: (context) => const UniversityPickerScreen()
      },
    );
  }
}
