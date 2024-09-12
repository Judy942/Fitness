

class User {
  String? firstName;
  String? lastName;
  String email;
  String password;

  User({ this.firstName, this.lastName,required this.email,required this.password});

  User.fromJson(Map<String, dynamic> json)
      :firstName = json['firstName'],
        lastName = json['lastName'],
        email = json['email'],
        password = json['password'];

}