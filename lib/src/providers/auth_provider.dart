import 'package:firebase_auth_ui/providers.dart';
import 'package:firebase_auth_ui/src/providers/phone_provider.dart';

abstract class AuthProvider {
  AuthProvider({this.providerId});

  final String providerId;

  Map<String, dynamic> getMap();

  factory AuthProvider.email() {
    return EmailProvider();
  }

  factory AuthProvider.google() {
    return GoogleProvider();
  }

  factory AuthProvider.facebook() {
    return FacebookProvider();
  }

  factory AuthProvider.twitter() {
    return TwitterProvider();
  }

  factory AuthProvider.phone() {
    return PhoneProvider();
  }
}
