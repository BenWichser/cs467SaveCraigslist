import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'listings_screen.dart';
import 'messages_screen.dart';
import 'list_item_screen.dart';
import 'my_listings_screen.dart';
import '../models/user.dart';
import '../account.dart';
import '../server_url.dart';

class MainTabController extends StatefulWidget {
  static final tabs = [forSaleTab(), messagesTab()];

  @override
  _MainTabControllerState createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  int _currentIndex = 0;

  void updateItems() {
    setState(() {});
  }

  //Future allItems = http.get(Uri.parse('${hostURL}:${port}/items'));

  //Right now AppBar is just being passed this _title string. Eventually this will likely be a widget to
  //display a search bar.
  String _title = 'Nearby Listings';

  @override
  Widget build(BuildContext context) {
    final screens = [
      ListingsScreen(updateItems: updateItems),
      MessagesScreen()
    ];

    return DefaultTabController(
        length: screens.length, //Needs to be changed if you add more tabs
        initialIndex: _currentIndex,
        child: Scaffold(
            appBar: AppBar(
                leading: Builder(
                    builder: (context) => GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Image.network(currentUser.photo))),
                title: Text(_title)),
            bottomNavigationBar:
                TabBar(tabs: MainTabController.tabs, onTap: onTabTapped),
            body: TabBarView(
                physics: NeverScrollableScrollPhysics(), children: screens),
            drawer: userDrawer(context, updateItems)));
  }

  //Changes the header from Listings/Messages depending on index every time the tab is tapped
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) {
        _title = 'Nearby Listings';
      } else {
        _title = 'Messages';
      }
    });
  }
}

Widget userDrawer(BuildContext context, updateItems) {
  return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: [
    profilePicture(currentUser),
    listAnItemButton(context, currentUser, updateItems),
    myListingsButton(context),
    logoutButton(context)
  ]));
}

Widget profilePicture(User currentUser) {
  return Container(
      height: 350,
      child: UserAccountsDrawerHeader(
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.black,
            foregroundImage: NetworkImage(currentUser.photo),
            //child: const Text('UN')
          ),
          accountName: Text(currentUser.id),
          accountEmail: Text(currentUser.email),
          currentAccountPictureSize: Size.fromRadius(100)));
}

Widget listAnItemButton(BuildContext context, User currentUser, updateItems) {
  return ListTile(
      title: Text('List an Item'),
      onTap: () {
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                ListItemScreen(updateItems: updateItems),
          ),
        );
      });
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
      });
}

Widget logoutButton(BuildContext context) {
  return ListTile(
      title: Text('Log Out'),
      onTap: () {
        logout();

        //Navigate back to login Screen
        Navigator.pop(context);
        Navigator.pop(context);
      });
}

Widget forSaleTab() {
  return Container(
      height: 60,
      child: Column(children: [
        Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Icon(Icons.shopping_bag_outlined, size: 30)),
        Text('For Sale')
      ]));
}

Widget messagesTab() {
  return Container(
      height: 60,
      child: Column(children: [
        Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Icon(Icons.mail_outlined, size: 30)),
        Text('Messages')
      ]));
}
