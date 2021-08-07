import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:save_craigslist_ui/server_url.dart';
import '../models/item.dart';
import '../screens/item_screen.dart';
import '../functions/readable_date.dart';

class ItemDisplay extends StatelessWidget {
  final Item item;
  final void Function() updateItems;

  const ItemDisplay({ Key? key, required this.item, required this.updateItems}) : super(key: key);

  //Individual Display for each item
  //An item has id, title, description, seller_id, price, location, status, photos

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {  
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => ItemScreen(item: item, updateItems: updateItems),
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
            Image(
              image: NetworkImage('${s3ItemPrefix}${item.photos![0]['URL']}'),
              height: 50,
              width: 50,
              fit: BoxFit.cover
            ),
            Padding(
              padding: EdgeInsets.all(10), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title),
                  Text(readableDate(item.date_added)),
                  Text('\$${item.price.toStringAsFixed(2)}')
                ])
            )
          ])
      )
    );
  }
}