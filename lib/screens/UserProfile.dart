import 'dart:convert';
import 'dart:io';

import 'package:cbl/cbl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../CbLiteManager.dart';
import '../CurrentData.dart';
import 'Login.dart';
import 'UniversitySelect.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
  static String id = 'user_profile_screen';
}

class _UserProfileState extends State<UserProfile> {
  var systemTemp = Directory.systemTemp;

  @override
  Widget build(BuildContext context) {
    if (CurrentData.sharedData.email == null) fetchProfile();
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                  onTap: () async {
                    try {
                      final image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (image == null) return;
                      final imageTemp = File(image.path);
                      setState(() => imageTemp
                          .copySync(CurrentData.sharedData.currentImage.path));
                    } on PlatformException catch (e) {
                      print('Failed to pick image: $e');
                    }
                  },
                  child: Column(
                    children: [
                      SizedBox(width: 200, height: 200, child: getImage()),
                      SizedBox(height: 10),
                      Text("Click on image to change it")
                    ],
                  )),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Column(children: [
            buildUserInfoDisplay(CurrentData.sharedData.name, "Name"),
            buildUserInfoDisplay(CurrentData.sharedData.email, "Email"),
            buildUserInfoDisplay(CurrentData.sharedData.address, "Address"),
            buildUserInfoDisplayUniversity(
                CurrentData.sharedData.university, "University"),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xffff0000),
                child: IconButton(
                    color: Colors.white,
                    onPressed: () {
                      CbLiteManager.getSharedInstance().closeDatabaseForUser();
                      if (CurrentData.sharedData.currentImage.existsSync()) {
                        CurrentData.sharedData.currentImage.deleteSync();
                      }
                      CurrentData.sharedData = CurrentData();

                      Navigator.pushNamed(context, Login.id);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                    )),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                'Log out',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 60),
              CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xffff0000),
                child: TextButton(
                    onPressed: () {
                      Map<String, Object> profile = {};
                      profile["name"] = CurrentData.sharedData.name ?? "";
                      profile["email"] = CurrentData.sharedData.email ?? "";
                      profile["address"] = CurrentData.sharedData.address ?? "";
                      profile["university"] =
                          CurrentData.sharedData.university ?? "";
                      if (CurrentData.sharedData.currentImage.existsSync()) {
                        final bytes = CurrentData.sharedData.currentImage
                            .readAsBytesSync();
                        profile["imageData"] = base64.encode(bytes);
                      }
                      saveProfile(profile);
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Success'),
                          content: const Text('Save was successful'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'OK'),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(
                          fontSize: 27,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    )),
              ),
            ])
          ]),
        ],
      ),
    );
  }

  Widget buildUserInfoDisplay(String? getValue, String title) => Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        SizedBox(
          height: 1,
        ),
        Container(
          width: 350,
          height: 40,
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ))),
          child: TextFormField(
            readOnly: title == "Email" ? true : false,
            key: Key(getValue ?? ""),
            style: TextStyle(fontSize: 16, height: 1.4),
            initialValue: getValue,
            onChanged: (value) {
              if (title == "Name") CurrentData.sharedData.name = value;
              if (title == "Email") CurrentData.sharedData.email = value;
              if (title == "Address") CurrentData.sharedData.address = value;
            },
          ),
        ),
      ]));

  Widget buildUserInfoDisplayUniversity(String? getValue, String title) =>
      Padding(
          padding: EdgeInsets.only(bottom: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(
              height: 1,
            ),
            Container(
              width: 350,
              height: 40,
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                color: Colors.grey,
                width: 1,
              ))),
              child: TextFormField(
                readOnly: true,
                onTap: () {
                  Navigator.pushNamed(context, UniversitySelect.id);
                },
                key: Key(getValue ?? ""),
                style: TextStyle(fontSize: 16, height: 1.4),
                initialValue: getValue,
              ),
            ),
          ]));

  Image getImage() {
    if (CurrentData.sharedData.currentImage.existsSync()) {
      return Image.file(CurrentData.sharedData.currentImage);
    } else {
      return CurrentData.sharedData.imageDefault;
    }
  }

  void fetchProfile() async {
    Database database = CbLiteManager.getSharedInstance().userprofileDatabase!;
    String docId = CbLiteManager.getSharedInstance().getCurrentUserDocId();

    Query query = QueryBuilder()
        .select(SelectResult.all())
        .from(DataSource.database(database))
        .where(Meta.id.equalTo(Expression.string(docId)));

    query.addChangeListener((change) {
      ResultSet rows = change.results;
      rows.asStream().forEach((element) {
        Dictionary dictionary = element.dictionary("userprofile")!;
        if (dictionary != null) {
          setState(() {
            CurrentData.sharedData.name = dictionary.string("name");
            CurrentData.sharedData.address = dictionary.string("address");
            CurrentData.sharedData.university = dictionary.string("university");
            String? imageString = dictionary.string("imageData");
            if (imageString != null) {
              if (!CurrentData.sharedData.currentImage.existsSync()) {
                CurrentData.sharedData.currentImage.createSync();
              }
              CurrentData.sharedData.currentImage
                  .writeAsBytesSync(base64.decode(imageString));
            } else {
              if (CurrentData.sharedData.currentImage.existsSync()) {
                CurrentData.sharedData.currentImage.deleteSync();
              }
            }
            CurrentData.sharedData.email = dictionary.string("email");
          });
        } else {
          setState(() {
            CurrentData.sharedData.email =
                CbLiteManager.getSharedInstance().currentUser!;
            if (CurrentData.sharedData.currentImage.existsSync()) {
              CurrentData.sharedData.currentImage.deleteSync();
            }
          });
        }
      });
    });

    setState(() {
      CurrentData.sharedData.email =
          CbLiteManager.getSharedInstance().currentUser!;
    });

    try {
      query.execute();
    } on CouchbaseLiteException catch (e) {
      print(e);
    }
  }

  void saveProfile(Map<String, Object> profile) {
    Database database = CbLiteManager.getSharedInstance().userprofileDatabase!;
    String docId = CbLiteManager.getSharedInstance().getCurrentUserDocId();
    MutableDocument mutableDocument = MutableDocument.withId(docId, profile);
    try {
      database.saveDocument(mutableDocument);
    } on CouchbaseLiteException catch (e) {
      print(e);
    }
  }
}
