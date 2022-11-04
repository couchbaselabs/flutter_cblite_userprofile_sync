import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:cbl/cbl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../CbLiteManager.dart';
import 'Login.dart';

// This class handles the Page to dispaly the user's info on the "Edit Profile" Screen
class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
  static String id = 'user_profile_screen';
}

class _UserProfileState extends State<UserProfile> {
  var systemTemp = Directory.systemTemp;
  Image imageDefault = Image.asset("assets/profile_placeholder.png");
  File currentImage = File("${Directory.systemTemp.path}/tmpImage");

  String? name = "";
  String? email = "";
  String? address = "";

  @override
  Widget build(BuildContext context) {
    if (email == "") fetchProfile();
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
                      setState(() => imageTemp.copySync(currentImage.path));
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
            buildUserInfoDisplay(name, "Name"),
            buildUserInfoDisplay(email, "Email"),
            buildUserInfoDisplay(address, "Address"),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xffff0000),
                child: IconButton(
                    color: Colors.white,
                    onPressed: () {
                      CbLiteManager.getSharedInstance().closeDatabaseForUser();

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
                      profile["name"] = name ?? "";
                      profile["email"] = email ?? "";
                      profile["address"] = address ?? "";
                      if(currentImage.existsSync()) {
                        final bytes = currentImage.readAsBytesSync();
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
            key: Key(getValue ?? ""),
            style: TextStyle(fontSize: 16, height: 1.4),
            initialValue: getValue,
            onChanged: (value) {
              if (title == "Name") name = value;
              if (title == "Email") email = value;
              if (title == "Address") address = value;
            },
          ),
        ),
      ]));

  Image getImage() {
    if (currentImage.existsSync()) {
      return Image.file(currentImage);
    } else {
      return imageDefault;
    }
  }

  void fetchProfile() async {

      Database database = CbLiteManager.getSharedInstance().userprofileDatabase!;
      String docId = CbLiteManager.getSharedInstance().getCurrentUserDocId();

      Query query = QueryBuilder()
          .select(SelectResult.all())
          .from(DataSource.database(database))
          .where(Meta.id.equalTo(Expression.string(docId)));

      query.addChangeListener((change) { // <1>
        ResultSet rows = change.results;
        rows.asStream().forEach((element) {
          Dictionary dictionary = element.dictionary("userprofile")!; // <3>
          if (dictionary != null) {
            setState(() {
              name = dictionary.string("name"); // <4>
              address = dictionary.string("address"); // <4>
              String? imageString = dictionary.string("imageData");
              if (imageString != null) {
                if (!currentImage.existsSync()) {
                  currentImage.createSync();
                }
                currentImage.writeAsBytesSync(base64.decode(imageString));
              } else {
                if (currentImage.existsSync()) {
                  currentImage.deleteSync();
                }
              }
              email = dictionary.string("email");
            });
          } else {
            setState(() {
              email = CbLiteManager
                  .getSharedInstance()
                  .currentUser!;
              if (currentImage.existsSync()) {
                currentImage.deleteSync();
              }
            });
          }
        }
        );
      }

      );

      try {
        query.execute();
      } on CouchbaseLiteException catch(e) {
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
