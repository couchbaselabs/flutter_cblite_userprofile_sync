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
To run this prebuilt project, you will need:

- [Android Studio Arctic Fox or above](https://developer.android.com/studio)
- Android device or emulator running API level 22 or above
- Android SDK installed and setup (> v.31.0.0)
- Android Build Tools (> v.31.0.0)
- JDK 8 (now embedded into Android Studio 4+)

## App Architecture

The sample app follows the [MVP pattern](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93presenter), separating the internal data model, from a passive view through a presenter that handles the logic of our application and acts as the conduit between the model and the view

## Try it out

* Install Flutter plugin in Android Studio
* Open flutter_cblite_userprofile_sync using Android Studio.
* Build and run the project.
* Verify that you see the login screen.

## Conclusion

This code is an example of how to use a Sync Gateway to synchronize data between Couchbase Lite enabled clients. The [Couchbase Developer Portal](https://developer.couchbase.com/tutorial-quickstart-android-java-sync/) tutorial will discuss how to configure your Sync Gateway to enforce relevant access control, authorization and data routing between Couchbase Lite enabled clients.