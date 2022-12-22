import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../common.dart';
import '../data/couchbase_lite_manager.dart';
import '../data/user_data.dart';
import '../widgets/big_button.dart';
import '../widgets/navigation_button.dart';
import 'university_picker_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  static String id = 'user_profile_screen';

  @override
  State createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    runActionGuarded(context, UserData.instance.load);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _logOut,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Profile'),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 64),
                Center(
                  child: InkWell(
                    onTap: _pickProfileImage,
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: UserData.instance,
                          builder: (context, _) {
                            return SizedBox.square(
                              dimension: 200,
                              child: UserData.instance.profileImage,
                            );
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Click on image to change it'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _UserDataField(
                          label: 'Name',
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.name],
                          getter: () => UserData.instance.name,
                          setter: (value) => UserData.instance.name = value,
                        ),
                        _UserDataField(
                          label: 'Username',
                          getter: () => UserData.instance.username,
                        ),
                        _UserDataField(
                          label: 'Address',
                          multiline: true,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [
                            AutofillHints.fullStreetAddress
                          ],
                          getter: () => UserData.instance.address,
                          setter: (value) => UserData.instance.address = value,
                        ),
                        _UserDataField(
                          label: 'University',
                          getter: () => UserData.instance.university,
                          onTap: () => Navigator.pushNamed(
                            context,
                            UniversityPickerScreen.id,
                          ),
                        ),
                        const SizedBox(height: 8),
                        BigButton(
                          label: 'Save',
                          onPressed: _saveProfile,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 52),
                NavigationButton(
                  label: 'Log out',
                  onPressed: () => Navigator.maybePop(context),
                  direction: NavigationButtonDirection.backward,
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _logOut() async {
    await runActionGuarded(context, () async {
      await CouchbaseLiteManager.instance.closeUserprofileDatabase();
      await CouchbaseLiteManager.instance.closeUniversitiesDatabase();
      UserData.instance.clear();
    });

    return true;
  }

  Future<void> _pickProfileImage() async {
    await runActionGuarded(context, () async {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }
      final imageData = await image.readAsBytes();
      setState(() {
        UserData.instance.profileImageData = imageData;
      });
    });
  }

  void _saveProfile() async {
    await runActionGuarded(context, () async {
      await UserData.instance.save();

      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('User profile saved successfully.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }
}

class _UserDataField extends StatefulWidget {
  const _UserDataField({
    Key? key,
    required this.label,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.multiline = false,
    required this.getter,
    this.setter,
    this.onTap,
  }) : super(key: key);

  final String label;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<String>? autofillHints;
  final bool multiline;
  final ValueGetter<String?> getter;
  final ValueChanged<String>? setter;
  final VoidCallback? onTap;

  @override
  State createState() => _UserDataFieldState();
}

class _UserDataFieldState extends State<_UserDataField> {
  final _controller = TextEditingController();

  void _updateController() {
    final value = widget.getter() ?? '';
    if (value != _controller.text) {
      _controller.text = value;
    }
  }

  @override
  void initState() {
    super.initState();
    _updateController();
    UserData.instance.addListener(_updateController);
  }

  @override
  void dispose() {
    UserData.instance.removeListener(_updateController);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _controller,
        readOnly: widget.setter == null,
        maxLines: widget.multiline ? null : 1,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        autofillHints: widget.autofillHints,
        decoration: AppTheme.inputDecoration(label: widget.label),
        onChanged: widget.setter,
        onTap: widget.onTap,
      ),
    );
  }
}
