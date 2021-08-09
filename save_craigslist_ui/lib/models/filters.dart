class Filters {
  String searchTerms;
  String searchLocation;
  int radius;
  double minPrice;
  double maxPrice;
  String sortBy;

  //Constructor with named parameters
  Filters({this.searchTerms = '', 
    required this.searchLocation, 
    this.radius = 5,
    this.minPrice = 0.0,
    this.maxPrice = double.infinity,
    this.sortBy = 'RELEVANCE'});
}
