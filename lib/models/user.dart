class User {
  int? id;
  String? name;
  String? image;
  String? email;
  String? token;
  String? password;

  User({this.id, this.name, this.image, this.email, this.token, this.password});

  // function to convert json data to user model
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['user']['id'],
        name: json['user']['name'],
        image: json['user']['image'],
        email: json['user']['email'],
        password: json['user']['password'],
        token: json['token']);
  }
}
