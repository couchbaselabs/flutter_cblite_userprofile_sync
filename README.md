# Quickstart for Couchbase Lite Data Sync with Flutter

#### Build a Flutter App with Couchbase Lite

You can find more information about the Couchbase Lite for Dart/Flutter SDK
[here](https://cbl-dart.dev/)

Couchbase Sync Gateway is a key component of the Couchbase Mobile stack. It is
an internet-facing synchronization mechanism that securely syncs data across
devices as well as between devices and the cloud. Couchbase Mobile is built upon
a websocket based
[replication protocol](https://blog.couchbase.com/data-replication-couchbase-mobile/).

The core functions of the Sync Gateway includes:

- Data Synchronization across devices and the cloud
- Authorization
- Access Control
- Data Validation

> This repo is designed to show you an app that allows users to log in and make
> changes to their user profile information. User profile information is
> persisted as a Document in the local Couchbase Lite Database. When the user
> logs out and logs back in again, the profile information is loaded from the
> Database.

Full documentation can be found on the
[Couchbase Developer Portal](https://developer.couchbase.com/tutorial-quickstart-android-java-sync/).

## Prerequisites

To run this prebuilt project, you will need flutter installed on your machine,
please refer to: https://docs.flutter.dev/get-started/install and install the
Flutter SDk and all required dependencies (e.g. XCode on iOS).

## Try it out

The project supports iOS, Android and macOS.

The easiest way to get started with Data Sync is to use a free
[Couchbase Capella](https://www.couchbase.com/products/capella) trial cluster.

After you have created a cluster, create a bucket and setup an App Service
endpoint that uses that bucket.

Also configure the App Service endpoint with the following sync function:

```javascript
function (doc, oldDoc, meta) {
  requireUser(doc.username);
  var userChannel = 'user.' + doc.username;
  channel(userChannel);
  access(doc.username, userChannel);
}
```

Create an app user and note the username and password so you can log in with
that user later.

Open the editor of your choice (I suggest VS Code with Flutter plugin) and
modify the string `CouchbaseLiteManager._syncGatewayUrl` in the
`lib/data/couchbase_lite_manager.dart`, pointing it to the App Services endpoint
(should be something like "wss://xxxx.apps.cloud.couchbase.com/userprofile").

To run the project on your preferred emulator or device simply type
`flutter run` from the project root folder.

## Conclusion

This code is an example of how to use a Sync Gateway to synchronize data between
Couchbase Lite enabled clients. The
[Couchbase Developer Portal](https://developer.couchbase.com/tutorial-quickstart-android-java-sync/)
tutorial will discuss how to configure your Sync Gateway to enforce relevant
access control, authorization and data routing between Couchbase Lite enabled
clients.
