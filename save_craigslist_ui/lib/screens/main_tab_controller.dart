import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'listings_screen.dart';
import 'messages_screen.dart';
import 'list_item_screen.dart';
import 'my_listings_screen.dart';
import '../models/user.dart';
import '../account.dart';
import '../server_url.dart';
import 'package:flutter/services.dart';
import 'profile_screen.dart';

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
  String searchTerms = '';

  void updateItems() {
    setState( (){} );
  }


  late Widget _header = listingsHeader();

  @override
  Widget build(BuildContext context) {
    //Widget _header = listingsHeader();

    final screens = [ListingsScreen(updateItems: updateItems, searchTerms: searchTerms), MessagesScreen()];
    var appBarHeight = AppBar().preferredSize.height * .8;

    return DefaultTabController(
      length: screens.length,                              //Needs to be changed if you add more tabs
      initialIndex: _currentIndex,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: SizedBox(
            height: appBarHeight, 
            child: _header,
          ),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.settings), 
                onPressed: () => Scaffold.of(context).openDrawer()
              );
            })
        ),
        bottomNavigationBar: TabBar(
          tabs: MainTabController.tabs,
          onTap: onTabTapped
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: screens),
        drawer: userDrawer(context, updateItems)
      )
    );
  }

  //Changes the header from Listings/Messages depending on index every time the tab is tapped
  void onTabTapped(int index) {  
    setState((){
      _currentIndex = index;
      if (index == 0){
        _header = listingsHeader();
      } else {
        _header = Align(alignment: Alignment.centerLeft, child: Text('Messages'));
      }
    });
  }

  
  Widget listingsHeader(){
    TextEditingController searchController = TextEditingController();

    return FractionallySizedBox(
      alignment: Alignment.center,
      heightFactor: .8,
      child: TextFormField(
        textInputAction: TextInputAction.search,
        controller: searchController, 
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              setState( (){
                searchTerms = '';
              });

              //Clear search field and close keyboard
              searchController.clear(); 
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            },
            icon: Icon(Icons.clear)),
          border: OutlineInputBorder()
        ),
        onFieldSubmitted: (value) {
          setState( () {
            searchTerms = value;
          });
        }
      )
    );
  }


}

Widget userDrawer(BuildContext context, updateItems){
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        profilePicture(currentUser),
        listAnItemButton(context, currentUser, updateItems),
        myListingsButton(context),
        profileButton(context),
        logoutButton(context)
      ]
    )
  );
}

Widget profilePicture(User currentUser) {
  return Container(
    height: 350,
    child: UserAccountsDrawerHeader(
      currentAccountPicture: CircleAvatar(
          backgroundColor: Colors.black,
          foregroundImage: NetworkImage(currentUser.photo),

      ),
      accountName: Text(currentUser.id),
      accountEmail: Text(currentUser.email),
      currentAccountPictureSize: Size.fromRadius(100)
    )
  );
}

Widget listAnItemButton(BuildContext context, User currentUser, updateItems) {
  return ListTile(
    title: Text('List an Item'),
    onTap: () {  
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => ListItemScreen(updateItems: updateItems),
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

Widget profileButton(BuildContext context){
  return ListTile(
    title: Text('View/Edit Profile'),
    onTap: () {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const ProfileScreen(),
        ),
      );
    }
  );
}

Widget logoutButton(BuildContext context){
  return ListTile(
    title: Text('Log Out'),
    onTap: () {  
      logout();

      //Navigate back to login Screen
      Navigator.pop(context);
      Navigator.pop(context);
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