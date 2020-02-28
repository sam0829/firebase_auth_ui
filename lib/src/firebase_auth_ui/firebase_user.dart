class FirebaseUser {
  String uid;
  String displayName;
  String email;
  String phoneNumber;
  String photoUri;
  String providerId;
  bool isAnonymous;
  bool isNewUser;

  FirebaseUser(this.uid, this.displayName, this.email, this.phoneNumber,
      this.photoUri, this.providerId,
      {this.isAnonymous = false, this.isNewUser});

  Map<String, dynamic> toJSON() {
    return {
      "uid": uid,
      "displayName": displayName,
      "email": email,
      "phoneNumber": phoneNumber,
      "photoUri": photoUri,
      "providerId": providerId,
      "isAnonymous": isAnonymous,
      "isNewUser": isNewUser,
    };
  }
}
