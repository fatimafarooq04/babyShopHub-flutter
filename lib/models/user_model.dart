class UserModel {
  final String id;
  final String username;
  final String email;
  final String? password;
  final String profileimg;
  final String? role;
  final String userDeviceToken;
  final dynamic createdOn;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.password,
    required this.profileimg,
    this.role,
    required this.userDeviceToken,
    required this.createdOn,
  });
  factory UserModel.fromMap(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      profileimg: json['profileimg'],
      role: json['role'] ?? 'user',
      userDeviceToken: json['userDeviceToken'],
      createdOn: json['createdOn'].toString(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password  ,
      'profileimg': profileimg,
      'role': role,
      'userDeviceToken': userDeviceToken,
      'createdOn': createdOn,
    };
  }
}
