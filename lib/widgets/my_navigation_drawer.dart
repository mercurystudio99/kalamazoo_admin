import 'package:kalamazoo_app_dashboard/constants/constants.dart';
import 'package:kalamazoo_app_dashboard/screens/admin_profile.dart';
import 'package:kalamazoo_app_dashboard/screens/dashboard.dart';
import 'package:kalamazoo_app_dashboard/screens/category.dart';
import 'package:kalamazoo_app_dashboard/screens/food_category.dart';
import 'package:kalamazoo_app_dashboard/screens/push_notifications.dart';
import 'package:kalamazoo_app_dashboard/screens/sign_in_screen.dart';
import 'package:kalamazoo_app_dashboard/screens/users_screen.dart';
import 'package:kalamazoo_app_dashboard/widgets/app_logo.dart';
import 'package:flutter/material.dart';

class MyNavigationDrawer extends StatefulWidget {
  const MyNavigationDrawer({Key? key}) : super(key: key);

  @override
  State<MyNavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<MyNavigationDrawer> {
  // Variables
  final _menuTextStyle = const TextStyle(
    color: Colors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(0),
        children: <Widget>[
          /// DrawerHeader
          _drawerHeader(context),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.score),
            title: Text("Dashboard", style: _menuTextStyle),
            onTap: () {
              // Go to dashboard screen
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Dashboard()));
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.category),
            title: Text("Categories", style: _menuTextStyle),
            onTap: () {
              // Go to categories screen
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Category()));
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: Text("Users", style: _menuTextStyle),
            onTap: () {
              // Go to users screen
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const UsersScreen()));
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.dining_sharp),
            title: Text("Food Category", style: _menuTextStyle),
            onTap: () {
              // Go to users screen
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const FoodCategory()));
            },
          ),
          // const Divider(height: 0),
          // ListTile(
          //   leading: const Icon(Icons.notifications_outlined),
          //   title: Text("Push Notifications", style: _menuTextStyle),
          //   onTap: () {
          //     // Go to push notifications screen
          //     Navigator.of(context).push(MaterialPageRoute(
          //         builder: (context) => const PushNotifications()));
          //   },
          // ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text("Admin Profile", style: _menuTextStyle),
            onTap: () {
              // Go to admin account screen
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AdminProfile()));
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text("Log out", style: _menuTextStyle),
            onTap: () {
              // Go to sign in screen
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const SignInScreen()));
            },
          ),
        ],
      ),
    );
  }
}

/// DrawerHeader
Widget _drawerHeader(BuildContext context) {
  return Container(
    color: Theme.of(context).primaryColor,
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        /// App logo
        AppLogo(),
        SizedBox(height: 10),
        Text(APP_NAME,
            style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
