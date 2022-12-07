import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:cbl/cbl.dart';
import 'package:cbl_flutter/cbl_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;

class CbLiteManager {
  Replicator? replicator;
  ListenerToken? replicatorListenerToken;
  Database? userprofileDatabase;
  Database? universityDatabase;

  static String userProfileDbName = "userprofile";
  static String universityDbName = "universities";

  static String syncGateway =
      "wss://rcrhu-gsg1x6uqw.apps.cloud.couchbase.com";

  String? currentUser;

  late ListenerToken listenerToken;

  static CbLiteManager? instance;

  static CbLiteManager getSharedInstance() {
    return instance ??= CbLiteManager();
  }

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await CouchbaseLiteFlutter.init();
  }

  String getCurrentUserDocId() {
    return "user::" + (currentUser ?? "");
  }

  void deregisterForDatabaseChanges() {
    userprofileDatabase!.removeChangeListener(listenerToken);
  }

  Future<void> openOrCreateDatabaseForUser(
      String username, String password) async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String path = appDocDirectory.path + '/' + 'username';

    DatabaseConfiguration config = DatabaseConfiguration();
    config.directory = path;
    currentUser = username;
    try {
      userprofileDatabase = await Database.openAsync('userprofile', config);
      registerForDatabaseChanges();

      startPushAndPullReplicationForCurrentUser(username, password);
    } on CouchbaseLiteException catch (e) {
      print(e);
    }
  }

  Future<void> openPrebuiltDatabase() async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String path = appDocDirectory.path + '/' + 'universities.cblite2';
    File file = File(path);
    DatabaseConfiguration config = DatabaseConfiguration(directory: path);

    if (!file.existsSync()) {
      await rootBundle.load("assets/universities.zip").then((ByteData value) {
        Uint8List wzzip =
            value.buffer.asUint8List(value.offsetInBytes, value.lengthInBytes);
        InputStream ifs = InputStream(wzzip);
        final archive = ZipDecoder().decodeBuffer(ifs);
        for (final file in archive) {
          final fileName = path + '/' + file.name;
          if (file.isFile) {
            final fileData = file.content as List<int>;
            File(fileName)
              ..createSync(recursive: true)
              ..writeAsBytesSync(fileData);
          } else {
            Directory(fileName).createSync(recursive: true);
          }
        }
      });

      universityDatabase = Database.openSync(universityDbName, config);
      createUniversityDatabaseIndexes();
    }
  }

  void createUniversityDatabaseIndexes() {
    try {
      universityDatabase!.createIndex(
          "nameLocationIndex",
          IndexBuilder.valueIndex([
            ValueIndexItem.expression(Expression.property("name")),
            ValueIndexItem.expression(Expression.property("location"))
          ]));
    } on CouchbaseLiteException catch (e) {
      print(e);
    }
  }

  void registerForDatabaseChanges() async {
    FutureOr<Document?> doc;
    FutureOr<ListenerToken> listenerTokenOr =
        userprofileDatabase!.addChangeListener((final DatabaseChange change) {
      change.documentIds.forEach((document) {
        for (String docId in change.documentIds) {
          doc = userprofileDatabase!.document(docId);
          if (doc != null) {
            print("Document was added/updated");
          } else {
            print("Document was deleted");
          }
        }
      });
    });

    listenerToken = await listenerTokenOr;
  }

  void closeDatabaseForUser() {
    try {
      if (!userprofileDatabase!.isClosed) {
        deregisterForDatabaseChanges();
        userprofileDatabase!.close();
      }
    } on CouchbaseLiteException catch (e) {
      print(e);
    }
  }

  void closePrebuiltDatabase() {
    try {
      if (!universityDatabase!.isClosed) {
        universityDatabase!.close();
      }
    } on CouchbaseLiteException catch (e) {
      print(e);
    }
  }

  void startPushAndPullReplicationForCurrentUser(
      String username, String password) async {
    // Database.log.custom!.level = LogLevel.verbose;
    // ByteData bytes = await rootBundle
    //     .load("assets/certificate.der"); //load certificate from assets
    // Uint8List certificate =
    //     bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    replicator = await Replicator.create(ReplicatorConfiguration(
        database: userprofileDatabase!,
        target: UrlEndpoint(Uri.parse("$syncGateway/$userProfileDbName")),
        replicatorType: ReplicatorType.pushAndPull,
        continuous: true,
        authenticator:
            BasicAuthenticator(username: username, password: password),
        channels: ["channel." + username],
        // there was an issue with missing User-Agent with AWS. This code is left as reference
        // headers: {
        //   "User-Agent":
        //       "CouchbaseLite/3.0.0-192 (Java; Android 13; sdk_gphone64_x86_64) EE/release, Commit/4769f18387@7451a45c924d Core/3.0.0 (192)"
        // },

       // pinnedServerCertificate: certificate

    ));

    await replicator!.start();
  }

  void stopAllReplicationForCurrentUser() {
    replicator!.removeChangeListener(replicatorListenerToken!);
    replicator!.stop();
  }
}
