import '../../providers.dart';

class TwitterProvider extends AuthProvider {
  TwitterProvider() : super(providerId: "twitter");

  @override
  Map<String, dynamic> getMap() {
    return {
      'providerId': providerId,
    };
  }
}
