import '../../providers.dart';

class GoogleProvider extends AuthProvider {
  GoogleProvider() : super(providerId: "google");

  @override
  Map<String, dynamic> getMap() {
    return {
      'providerId': providerId,
    };
  }
}
