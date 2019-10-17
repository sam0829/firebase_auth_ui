import '../../providers.dart';

class EmailProvider extends AuthProvider {
  EmailProvider({this.permissions}) : super(providerId: "password");

  List<String> permissions;

  @override
  Map<String, dynamic> getMap() {
    return {
      'providerId': providerId,
    };
  }
}
