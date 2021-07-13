class User {
  final String id;
  final String email;
  final String username;
  final String password;
  final String photo;
  final String zip;
  
  String rating_buyer = '5.0';
  String rating_seller = '5.0';
  List<String> current_listings = [];

  //Constructor with required named parameters
  User({required this.id, 
    required this.email, 
    required this.username, 
    required this.password, 
    required this.photo,
    required this.zip,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      password: json['password'],
      photo: json['photo'],
      zip: json['zip']
    );
  }
}