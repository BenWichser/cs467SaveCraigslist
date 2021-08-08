class User {
  final String id;
  final String email;
  String photo;
  String defaultPhoto;
  final String zip;

  String rating_buyer = '5.0';
  String rating_seller = '5.0';
  List<String> current_listings = [];

  //Constructor with named parameters
  User(
      {required this.id,
      required this.email,
      this.photo =
          'https://savecraigslistusers.s3.us-east-2.amazonaws.com/blank_profile_picture.png',
        this.defaultPhoto = 
          'https://savecraigslistusers.s3.us-east-2.amazonaws.com/blank_profile_picture.png',
      required this.zip});

  User.nullUser()
      : id = 'Null',
        email = 'Null',
        photo = 'Null',
        defaultPhoto = 'Null',
        zip = 'Null';
}
