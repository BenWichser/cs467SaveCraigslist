import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/item.dart';
import '../screens/item_screen.dart';

class ItemDisplay extends StatelessWidget {
  final Item item;

  const ItemDisplay({ Key? key, required this.item }) : super(key: key);

  //Individual Display for each item
  //An item has id, title, description, seller_id, price, location, status, photos

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {  
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => ItemScreen(item: item),
          ),
        );
      },
      child: Container( 
        padding: EdgeInsets.all(15.0),
        width: double.infinity,
        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1.0, color: Colors.black))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
              Placeholder(
              fallbackHeight: 50,
              fallbackWidth: 50
              ),
            Padding(
              padding: EdgeInsets.all(10), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title),
                  Text('\$${item.price}')
                ])
            )
          ])
      )
    );
  }
}