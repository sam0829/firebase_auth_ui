import 'dart:async';

import 'package:flutter/services.dart';

import '../providers/auth_provider.dart';
import 'firebase_user.dart';

class FirebaseAuthUi {
  static FirebaseAuthUi _instance;

  FirebaseAuthUi._internal();

  static FirebaseAuthUi instance() {
    if (_instance == null) _instance = FirebaseAuthUi._internal();
    return _instance;
  }

  static const MethodChannel _channel = const MethodChannel('firebase_auth_ui');

  /// Indicates that user cancelled the sign-in process via back or cancel button
  static const String kUserCancelledError = "ERROR_USER_CANCELLED";

  /// Indicates the firebase error. The error should have message and detail showing
  /// the firebase error code which can be used to handle error more precisely.
  static const String kFirebaseError = "ERROR_FIREBASE";

  /// Indicates an unknown error occurred during sign-in process
  static const String kUnknownError = "ERROR_UNKNOWN";

  /// Presents a new screen to user to sign in with various src.providers passed in [authProviders].
  /// Pass [tosUrl] & [privacyPolicyUrl] optionally to have your TOS and Privacy Policy URLs in
  /// sign in screen.
  Future<FirebaseUser> launchAuth(List<AuthProvider> authProviders,
      {String tosUrl, String privacyPolicyUrl}) async {
    var user = await _channel.invokeMethod('launchFlow', {
      "providers": _getProviders(authProviders),
      "tos": tosUrl,
      "privacyPolicy": privacyPolicyUrl
    });
    if (user is Exception) return Future<FirebaseUser>.error(user);
    return _getFirebaseUser(user);
  }

  /// Logout user. This will NOT present the sign in screen. Please call
  /// [launchAuth] as per your app's flow.
  Future<bool> logout() async {
    bool result = await _channel.invokeMethod('logout');
    return Future.value(result);
  }

  FirebaseUser _getFirebaseUser(Map<dynamic, dynamic> userMap) {
    MetaData metaData;
    if (userMap?.containsKey("metadata") ?? false) {
      metaData = MetaData(creationTimestamp: userMap["metadata"]["creation_timestamp"],
      lastSignInTimestamp: userMap["metadata"]["last_sign_in_timestamp"]);
    }
    return FirebaseUser(
        userMap["uid"] ?? "",
        userMap["display_name"] ?? "",
        userMap["email"] ?? "",
        userMap["phone_number"] ?? "",
        userMap["photo_url"] ?? "",
        userMap["provider_id"] ?? "",
        metaData,
        isAnonymous: userMap["is_anonymous"] ?? false,
        isNewUser: userMap["is_new_user"]);
  }

  List<String> _getProviders(List<AuthProvider> providers) {
    List<String> authProviders = List();
    providers.forEach((provider) {
      authProviders.add(provider.providerId);
    });
    return authProviders;
  }
}
