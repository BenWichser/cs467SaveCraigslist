class User {
  final String id;
  final String email;
  final String password;
  final String photo;
  final String zip;
  
  String rating_buyer = '5.0';
  String rating_seller = '5.0';
  List<String> current_listings = [];

  //Constructor with required named parameters
  User({required this.id, 
    required this.email, 
    required this.password, 
    required this.photo,
    required this.zip,
  });

  User.nullUser() : id = 'Null', email = 'Null', password = 'Null', photo = 'Null', zip = 'Null';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      photo: json['photo'],
      zip: json['zip']
    );
  }
}