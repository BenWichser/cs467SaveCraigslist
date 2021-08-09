import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
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
import '../models/filters.dart';

class MainTabController extends StatefulWidget {

  static final tabs = [
    forSaleTab(),
    messagesTab(),
    listItemTab()
  ];

  @override
  _MainTabControllerState createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  int _currentIndex = 0;
  bool search = false;

  Filters filters = Filters(searchLocation: currentUser.zip);

  void updateItems() {
    setState( (){} );
  }

  late Widget _header = listingsHeader();

  @override
  Widget build(BuildContext context) {

    final screens = [
      ListingsScreen(updateItems: updateItems, filters: filters), 
      MessagesScreen(), 
      ListItemScreen(updateItems : updateItems)
    ];

    var appBarHeight = AppBar().preferredSize.height * .8;

    return DefaultTabController(
      length: screens.length,                              
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
              return GestureDetector(
                child: FractionallySizedBox(heightFactor: .7, child: CircleAvatar(
                  backgroundColor: Colors.black,
                  foregroundImage: NetworkImage(currentUser.photo)
                )),
                onTap: () => Scaffold.of(context).openDrawer()
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

  //Changes the header from Listings/Messages/List an item depending on index every time the tab is tapped
  void onTabTapped(int index) {  
    setState((){
      _currentIndex = index;
      if (index == 0){
        _header = listingsHeader();
      } 
      else if (index == 1) {
        _header = Align(alignment: Alignment.centerLeft, child: Text('Messages'));
      }
      else if (index == 2) {
        _header = Align(alignment: Alignment.centerLeft, child: Text('New Item'));
      }
    });
  }

  
  Widget listingsHeader(){
    TextEditingController searchController = TextEditingController();
    searchController.text = filters.searchTerms;

    return search 
      //Search bar if the user has clicked the search icon
      ? FractionallySizedBox(
        alignment: Alignment.center,
        heightFactor: .8,
        child: TextFormField(
          textInputAction: TextInputAction.search,
          controller: searchController, 
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState( (){
                  filters.searchTerms = '';
                  search = !search;
                  _header = listingsHeader();
                });

                //Clear search field and close keyboard
                //FocusScope.of(context).requestFocus(FocusNode());
                searchController.clear(); 
                FocusScope.of(context).unfocus();
                
                //SystemChannels.textInput.invokeMethod('TextInput.hide');

              },
            ),
            border: OutlineInputBorder()
          ),
          onFieldSubmitted: (value) {
            setState( () {
              filters.searchTerms = value;
            });
          }
        )
      )
      //'Listings' header and search icon
      : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Listings'),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState( (){
                  search = !search;
                  _header = listingsHeader();
                });
              }
            )
        ]);
  }


}

Widget userDrawer(BuildContext context, updateItems){
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        profilePicture(currentUser),
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
          foregroundImage: NetworkImage('${currentUser.photo}'),

      ),
      accountName: Text(currentUser.id),
      accountEmail: Text(currentUser.email),
      currentAccountPictureSize: Size.fromRadius(100)
    )
  );
}

Widget myListingsButton(BuildContext context) {
  return ListTile(
    leading: Icon(Icons.store, color: Colors.black),
    title: Text('My Listings'),
    visualDensity: VisualDensity(horizontal: VisualDensity.minimumDensity),
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
    leading: Icon(Icons.person_sharp, color: Colors.black),
    visualDensity: VisualDensity(horizontal: VisualDensity.minimumDensity),
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
    title: Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(border: Border.all(color: Colors.black)), 
      child: Center(child: Text('Log Out'))),
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

Widget listItemTab(){
  return Container(
      height: 60,
      child: Column(children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5), 
          child: Icon(Icons.sell_outlined, size: 30)
        ),
        Text('New Item')
      ])
    );
}