class Item {
  String? id = 'tbd';
  final String title;
  String? description = 'This item doesn\'t have a description';
  final String seller_id;
  final double price;
  final String location;
  List<dynamic>? photos = [];

  final String status = 'For Sale';

  //Constructor with required named parameters
  Item({this.id, 
    required this.title, 
    this.description, 
    required this.seller_id, 
    required this.price,
    required this.location,
    this.photos
  });
}