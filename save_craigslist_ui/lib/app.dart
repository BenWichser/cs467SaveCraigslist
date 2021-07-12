import 'package:flutter/material.dart';
import 'screens/listings_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/list_item_screen.dart';
import 'screens/my_listings_screen.dart';

class App extends StatelessWidget{

  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gurt\'s List',
      theme: ThemeData(primaryColor: Colors.white),
      home: MainTabController()
    );
  }
}

class MainTabController extends StatefulWidget {
    static final tabs = [
    forSaleTab(),
    messagesTab()
  ];

  @override
  _MainTabControllerState createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  int _currentIndex = 0;
  final screens = [ListingsScreen(), MessagesScreen()];

  //Right now AppBar is just being passed this _title string. Eventually this will likely be a widget to 
  //display a search bar. 
  String _title = 'Listings';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: screens.length,
      initialIndex: _currentIndex,
      child: Scaffold(
        appBar: AppBar(title: Text(_title)),
        bottomNavigationBar: TabBar(
          tabs: MainTabController.tabs,
          onTap: onTabTapped),
        body: TabBarView(children: screens),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              profilePicture(),
              listAnItemButton(context),
              myListingsButton(context)
             ]
          )
        )
      )
    );
  }

  //Changes the header from Listings/Messages depending on index every time the tab is tapped
  void onTabTapped(int index) {
    setState((){
      _currentIndex = index;
      if (index == 0){
        _title = 'Listings';
      } else {
        _title = 'Messages';
      }
    });
  }

}

Widget profilePicture() {
  return Container(
    height: 350,
    child: UserAccountsDrawerHeader(
      currentAccountPicture: CircleAvatar(
          backgroundColor: Colors.black,
          //when you have an image URL:
          //backgroundImage: NetworkImage(photoURL),
          child: const Text('UN')

      ),
      accountName: Text('Username'),
      accountEmail: Text('username@email.com'),
      currentAccountPictureSize: Size.fromRadius(100)
    )
  );
}

Widget listAnItemButton(BuildContext context) {
  return ListTile(
    title: Text('List an Item'),
    onTap: () {  
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const ListItemScreen(),
        ),
      );
    }
  );
}

Widget myListingsButton(BuildContext context) {
  return ListTile(
    title: Text('My Listings'),
    onTap: () {  
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const MyListingsScreen(),
        ),
      );
    }
  );
}

Widget forSaleTab(){
  return Container(
      height: 60,
      child: Column(children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5), 
          child: Icon(Icons.shopping_bag_outlined, size: 30)
        ),
        Text('For Sale')
      ])
    );
}

Widget messagesTab(){
  return Container(
      height: 60,
      child: Column(children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5), 
          child: Icon(Icons.mail_outlined, size: 30)
        ),
        Text('Messages')
      ])
    );
}

//Changing something here to make sure git is tracking this.
