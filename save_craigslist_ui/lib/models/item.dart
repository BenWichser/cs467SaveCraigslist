class Item {
  String? id = 'tbd';
  String title;
  String? description;
  final String seller_id;
  double price;
  final String location;
  final DateTime date_added;
  List<dynamic>? photos;
  List<dynamic>? defaultPhotos;

  final String status = 'For Sale';

  //Constructor with required named parameters
  Item({this.id,
    required this.title,
    this.description = 'This item doesn\'t have a description',
    required this.seller_id,
    required this.price,
    required this.location,
    required this.date_added,
    this.photos = const [
      {'caption': 'No Image Available', 'URL': 'no_image_available.jpeg'}
    ],
    this.defaultPhotos = const [
      {'caption': 'No Image Available', 'URL': 'no_image_available.jpeg'}
    ]
  });
}
