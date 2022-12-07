# Quickstart in Couchbase Lite Data Sync with Android and Java
#### Build an App in Flutter with Couchbase Lite

Find info on Couchbase Flutter plugin [here](https://cbl-dart.dev/)

Couchbase Sync Gateway is a key component of the Couchbase Mobile stack. It is an internet-facing synchronization mechanism that securely syncs data across devices as well as between devices and the cloud. Couchbase Mobile is built upon a websocket based [replication protocol](https://blog.couchbase.com/data-replication-couchbase-mobile/).

The core functions of the Sync Gateway includes:

- Data Synchronization across devices and the cloud
- Authorization
- Access Control
- Data Validation

> This repo is designed to show you an app that allows users to log in and make changes to their user profile information.  User profile information is persisted as a Document in the local Couchbase Lite Database. When the user logs out and logs back in again, the profile information is loaded from the Database.

Full documentation can be found on the [Couchbase Developer Portal](https://developer.couchbase.com/tutorial-quickstart-android-java-sync/).


## Prerequisites
To run this prebuilt project, you will need flutter installed on your machine, please refere to: https://docs.flutter.dev/get-started/install and install flutter SDks and all required dependencies (e.g. XCode on iOS).


## Try it out

The project supports both iOS and Android.
Open the editor of your choice (I suggest Visual studio Code with Flutter plugin) and modify the string syncGateway in the class CbLiteManager.dart pointing to the correct App services enpoint (should be something like "wss://xxxx.apps.cloud.couchbase.com").
To run the project on your preferred emulator or device symply type "flutter run" from the project root folder.

## Conclusion

This code is an example of how to use a Sync Gateway to synchronize data between Couchbase Lite enabled clients. The [Couchbase Developer Portal](https://developer.couchbase.com/tutorial-quickstart-android-java-sync/) tutorial will discuss how to configure your Sync Gateway to enforce relevant access control, authorization and data routing between Couchbase Lite enabled clients.
