import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common.dart';
import '../data/couchbase_lite_manager.dart';
import '../data/user_data.dart';
import '../widgets/navigation_button.dart';
import 'user_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static String id = 'login_screen';

  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  var _username = '';
  var _password = '';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                Center(
                  child: SizedBox.square(
                    dimension: 300,
                    child: Image.asset('assets/logo.png'),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _LoginFormField(
                            label: 'Username',
                            onChanged: (value) => _username = value,
                          ),
                          const SizedBox(height: 16),
                          _LoginFormField(
                            label: 'Password',
                            obscureText: true,
                            onChanged: (value) => _password = value,
                          ),
                          const SizedBox(height: 32),
                          NavigationButton(
                            direction: NavigationButtonDirection.forward,
                            label: 'Sign in',
                            onPressed: _signIn,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    runActionGuarded(context, () async {
      await CouchbaseLiteManager.instance
          .openUserprofileDatabase(_username, _password);
      await CouchbaseLiteManager.instance.openUniversitiesDatabase();
      await UserData.instance.init();

      _formKey.currentState!.reset();

      // ignore: use_build_context_synchronously
      await Navigator.pushNamed(context, UserProfileScreen.id);
    });
  }
}

class _LoginFormField extends StatelessWidget {
  const _LoginFormField({
    required this.label,
    this.obscureText = false,
    required this.onChanged,
  });

  final String label;
  final bool obscureText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.next,
      obscureText: obscureText,
      decoration: AppTheme.inputDecoration(label: label),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value.';
        }
        return null;
      },
    );
  }
}
