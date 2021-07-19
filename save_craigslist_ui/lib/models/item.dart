class Item {
  String? id = 'tbd';
  final String title;
  String? description;
  final String seller_id;
  final double price;
  final String location;
  List<dynamic>? photos;

  final String status = 'For Sale';

  //Constructor with required named parameters
  Item({this.id, 
    required this.title, 
    this.description = 'This item doesn\'t have a description', 
    required this.seller_id, 
    required this.price,
    required this.location,
    this.photos = const [{'caption':'No Image Available','URL':'no_image_available.jpeg'}]
  });
}