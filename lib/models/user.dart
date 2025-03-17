class User {
  String id;
  String? firstName;
  String? lastName;
  String email;
  String password;
  String? avatar;
  String? height;
  String? weight;

  User(
      {required this.id,
      this.firstName,
      this.lastName,
      required this.email,
      required this.password,
      this.avatar,
      this.height,
      this.weight});

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        email = json['email'],
        password = json['password'],
        avatar = json['avatar'],
        height = json['height'],
        weight = json['weight'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'avatar': avatar,
        'height': height,
        'weight': weight
      };
}
