import 'dart:core';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:cbl/cbl.dart';
import 'package:cbl_flutter/cbl_flutter.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'user_data.dart';

class CouchbaseLiteManager {
  CouchbaseLiteManager._();

  static const _debugLogging = false;

  static const _userProfileDbName = 'userprofile';
  static const _universitiesDbName = 'universities';

  // Specify your Sync Gateway URL to enable synchronization.
  static const _syncGatewayUrl = '';

  static Future<void> init() async {
    await CouchbaseLiteFlutter.init();

    if (_debugLogging) {
      if (Platform.isAndroid) {
        Database.log.custom!.level = LogLevel.verbose;
      } else {
        Database.log.console.level = LogLevel.verbose;
      }
    }
  }

  static final CouchbaseLiteManager instance = CouchbaseLiteManager._();

  String? currentUser;

  Database? userprofileDatabase;
  Database? universitiesDatabase;

  late ListenerToken _databaseListenerToken;
  Replicator? _replicator;
  ListenerToken? _replicatorListenerToken;

  String get currentUserDocId => 'user::${currentUser!}';

  Future<void> openUserprofileDatabase(
    String username,
    String password,
  ) async {
    currentUser = username;

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final config = DatabaseConfiguration(directory: documentsDirectory.path);
    userprofileDatabase = await Database.openAsync(_userProfileDbName, config);
    await _startWatchingUserprofileDatabase();

    if (_syncGatewayUrl.isNotEmpty) {
      await _startUserprofileReplication(username, password);
    }
  }

  Future<void> closeUserprofileDatabase() async {
    if (!userprofileDatabase!.isClosed) {
      await _stopUserprofileReplication();
      await _stopWatchingUserprofileDatabase();
      await userprofileDatabase!.close();
    }
  }

  Future<void> _startWatchingUserprofileDatabase() async {
    _databaseListenerToken =
        await userprofileDatabase!.addChangeListener((change) async {
      for (final documentId in change.documentIds) {
        final document = await userprofileDatabase!.document(documentId);
        if (document != null) {
          print('Document "$documentId" was updated.');

          if (documentId == currentUserDocId) {
            await UserData.instance.syncWithDocument(document);
          }
        } else {
          print('Document "$documentId" was deleted.');
        }
      }
    });
  }

  Future<void> _stopWatchingUserprofileDatabase() async {
    await userprofileDatabase!.removeChangeListener(_databaseListenerToken);
  }

  Future<void> _startUserprofileReplication(
    String username,
    String password,
  ) async {
    _replicator = await Replicator.create(
      ReplicatorConfiguration(
        database: userprofileDatabase!,
        target: UrlEndpoint(Uri.parse(_syncGatewayUrl)),
        replicatorType: ReplicatorType.pushAndPull,
        continuous: true,
        authenticator: BasicAuthenticator(
          username: username,
          password: password,
        ),
        channels: ['user.$username'],
        // The Couchbase Lite C SDK does not send a User-Agent header as of
        // version 3.0.2. Capella App Services on AWS expect the User-Agent to
        // be present. This is a workaround until the C SDK is fixed.
        headers: {'User-Agent': 'CouchbaseLite/3.0.2'},
      ),
    );

    await _replicator!.start();
  }

  Future<void> _stopUserprofileReplication() async {
    final replicatorListenerToken = _replicatorListenerToken;
    if (replicatorListenerToken != null) {
      await _replicator?.removeChangeListener(replicatorListenerToken);
    }
    await _replicator?.stop();
  }

  Future<void> openUniversitiesDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    await _unpackPrebuiltDatabase(
      name: _universitiesDbName,
      directory: documentsDirectory.path,
      loadArchiveData: () async {
        final archiveData = await rootBundle.load('assets/universities.zip');
        return Uint8List.sublistView(archiveData);
      },
    );
    final config = DatabaseConfiguration(directory: documentsDirectory.path);
    universitiesDatabase = Database.openSync(_universitiesDbName, config);
    await _createUniversitiesDatabaseIndexes();
  }

  Future<void> closeUniversitiesDatabase() async {
    if (!universitiesDatabase!.isClosed) {
      await universitiesDatabase!.close();
    }
  }

  Future<void> _createUniversitiesDatabaseIndexes() async {
    await universitiesDatabase!.createIndex(
      'nameLocationIndex',
      IndexBuilder.valueIndex([
        ValueIndexItem.expression(Function_.lower(Expression.property('name'))),
        ValueIndexItem.expression(
          Function_.lower(Expression.property('location')),
        )
      ]),
    );
  }
}

Future<void> _unpackPrebuiltDatabase({
  required String name,
  required String directory,
  required Future<Uint8List> Function() loadArchiveData,
}) async {
  final databasePath = path.join(directory, '$name.cblite2');
  final file = File(databasePath);

  if (!file.existsSync()) {
    final inputStream = InputStream(await loadArchiveData());
    final archive = ZipDecoder().decodeBuffer(inputStream);
    for (final file in archive) {
      final fileName = path.join(directory, file.name);
      if (file.isFile) {
        final fileData = file.content as List<int>;
        File(fileName)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileData);
      } else {
        Directory(fileName).createSync(recursive: true);
      }
    }
  }
}
