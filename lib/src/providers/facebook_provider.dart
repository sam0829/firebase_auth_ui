import '../../providers.dart';

class FacebookProvider extends AuthProvider {
  FacebookProvider() : super(providerId: "facebook");

  @override
  Map<String, dynamic> getMap() {
    return {
      'providerId': providerId,
    };
  }
}
