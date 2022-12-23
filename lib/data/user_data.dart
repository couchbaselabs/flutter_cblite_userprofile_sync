import 'package:cbl/cbl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'couchbase_lite_manager.dart';

class UserData extends ChangeNotifier {
  static final instance = UserData();

  static final defaultProfileImage =
      Image.asset('assets/profile_placeholder.png');

  String? get username => _username;
  String? _username;

  String? get name => _name;
  String? _name;

  set name(String? value) {
    if (_name == value) {
      return;
    }
    _name = value;
    notifyListeners();
  }

  String? get address => _address;
  String? _address;

  set address(String? value) {
    if (_address == value) {
      return;
    }
    _address = value;
    notifyListeners();
  }

  String? get university => _university;
  String? _university;

  set university(String? value) {
    if (_university == value) {
      return;
    }
    _university = value;
    notifyListeners();
  }

  Uint8List? get profileImageData => _profileImageData;
  Uint8List? _profileImageData;

  set profileImageData(Uint8List? value) {
    if (_profileImageData == value) {
      return;
    }
    _profileImageData = value;
    notifyListeners();
  }

  Image get profileImage {
    if (profileImageData == null) {
      return defaultProfileImage;
    }

    return Image.memory(profileImageData!);
  }

  Future<void> init() async {
    assert(username == null);

    await load();

    if (username != null) {
      return;
    }

    _username = CouchbaseLiteManager.instance.currentUser;
    await save();
  }

  Future<void> load() async {
    final databaseManager = CouchbaseLiteManager.instance;
    final database = databaseManager.userprofileDatabase!;
    final document = await database.document(databaseManager.currentUserDocId);

    if (document == null) {
      return;
    }

    await syncWithDocument(document);
  }

  Future<void> syncWithDocument(Document document) async {
    _username = document.string('username')!;
    _name = document.string('name');
    _address = document.string('address');
    _university = document.string('university');

    final profileImageBlob = document.blob('profileImage');
    if (profileImageBlob != null) {
      _profileImageData = await profileImageBlob.content();
    } else {
      _profileImageData = null;
    }

    notifyListeners();
  }

  Future<void> save() async {
    final databaseManager = CouchbaseLiteManager.instance;
    final database = databaseManager.userprofileDatabase!;

    var document = (await database.document(databaseManager.currentUserDocId))
        ?.toMutable();
    document ??= MutableDocument.withId(databaseManager.currentUserDocId);

    document
      ..setString(username!, key: 'username')
      ..setString(name, key: 'name')
      ..setString(address, key: 'address')
      ..setString(university, key: 'university');

    final profileImageData = this.profileImageData;
    if (profileImageData != null) {
      document.setBlob(
        Blob.fromData('image', profileImageData),
        key: 'profileImage',
      );
    }

    await database.saveDocument(document);
  }

  void clear() {
    _username = null;
    _name = null;
    _address = null;
    _university = null;
    _profileImageData = null;
    notifyListeners();
  }
}
