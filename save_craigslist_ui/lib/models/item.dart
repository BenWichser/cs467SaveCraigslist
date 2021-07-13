class Item {
  final String id;
  final String title;
  final String description;
  final String seller_id;
  final double price;
  final String location;
  //List<dynamic> photos = [];

  final String status = 'For Sale';

  //Constructor with required named parameters
  Item({required this.id, 
    required this.title, 
    required this.description, 
    required this.seller_id, 
    required this.price,
    required this.location,
    //required this.photos
  });
}