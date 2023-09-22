import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kalamazoo_app_dashboard/screens/restaurant.dart';
import 'package:kalamazoo_app_dashboard/screens/restaurant_edit.dart';
import 'package:kalamazoo_app_dashboard/utils/globals.dart' as globals;
import 'package:kalamazoo_app_dashboard/constants/constants.dart';
import 'package:kalamazoo_app_dashboard/models/app_model.dart';
import 'package:kalamazoo_app_dashboard/widgets/my_navigation_drawer.dart';
import 'package:kalamazoo_app_dashboard/widgets/processing.dart';
import 'package:kalamazoo_app_dashboard/widgets/default_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Variables
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _appInfo;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _users;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _restaurants;

  bool isDisabled = false;
  String searchKeyword = '';

  /// Get AppInfo Stream to update UI after changes
  void _getAppInfoUpdates() {
    _appInfo = AppModel().getAppInfoStream();
    // Listen updates
    _appInfo.listen((appEvent) {
      // Update AppInfo object
      AppModel().updateAppObject(appEvent.data()!);
    });
  }

  /// Get Users Stream to listen updates
  void _getUsersUpdates() {
    _users = AppModel().getUsers();
    // Listen updates
    _users!.listen((usersEvent) {
      // Update users
      AppModel().updateUsers(usersEvent.docs);
    });
  }

  /// Get Restaurants Stream to listen updates
  void _getRestaurantsUpdates(String type) {
    globals.restaurantType = type;
    _restaurants = AppModel().getRestaurants();
    // Listen updates
    _restaurants!.listen((event) {
      // Update restaurants
      AppModel().updateRestaurants(event.docs);
    });
    setState(() {});
  }

  // /// Count User Statistics
  // int _countUsers(
  //     List<DocumentSnapshot<Map<String, dynamic>>> users, String userStatus) {
  //   // Variables
  //   String field = USER_STATUS;
  //   dynamic status = userStatus;
  //   // Check status
  //   if (userStatus == 'verified') {
  //     field = USER_IS_VERIFIED;
  //     status = true;
  //   }
  //   return users.where((user) => user.data()![field] == status).toList().length;
  // }

  @override
  void initState() {
    super.initState();
    // Remove the splash screen
    FlutterNativeSplash.remove();

    // Get updates
    _getUsersUpdates();
    _getAppInfoUpdates();
    _getRestaurantsUpdates(globals.restaurantType);
  }

  @override
  void dispose() {
    _appInfo.drain();
    _users?.drain();
    _restaurants?.drain();
    super.dispose();
  }

  void _onPressed() {
    setState(() {
      isDisabled = !isDisabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text(APP_NAME)),
        drawer: const MyNavigationDrawer(),
        backgroundColor: Colors.grey.withAlpha(70),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _restaurants,
            builder: (context, snapshot) {
              // Check data
              if (!snapshot.hasData) {
                return const Processing();
              } else {
                // Variables
                final List<DocumentSnapshot<Map<String, dynamic>>> restaurants =
                    snapshot.data!.docs;
                List<DocumentSnapshot<Map<String, dynamic>>> filters = [];
                if (searchKeyword.isEmpty) {
                  filters = restaurants;
                } else {
                  for (var restaurant in restaurants) {
                    if (restaurant
                            .data()![RESTAURANT_BUSINESSNAME]
                            .toString()
                            .toLowerCase()
                            .contains(searchKeyword) ||
                        restaurant
                            .data()![RESTAURANT_ZIP]
                            .toString()
                            .contains(searchKeyword)) {
                      filters.add(restaurant);
                    }
                  }
                }
                final List<Widget> restaurantViews = filters
                    .map((restaurant) => Center(
                          child: Container(
                              width: double.maxFinite,
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 30),
                              child: ListTile(
                                leading: const Icon(Icons.business),
                                title: Text(
                                    "${restaurant.data()?[RESTAURANT_BUSINESSNAME]} (${restaurant.data()?[RESTAURANT_URL]})"),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 12,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "${restaurant.data()?[RESTAURANT_ADDRESS]}",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.location_city,
                                          size: 12,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5, right: 10),
                                          child: Text(
                                            "${restaurant.data()?[RESTAURANT_CITY]}, ${restaurant.data()?[RESTAURANT_STATE]}",
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.phone,
                                          size: 12,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5, right: 10),
                                          child: Text(
                                            "${restaurant.data()?[RESTAURANT_PHONE]}",
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.email,
                                          size: 12,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5, right: 10),
                                          child: Text(
                                            "${restaurant.data()?[RESTAURANT_EMAIL]}",
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.fax,
                                          size: 12,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5, right: 10),
                                          child: Text(
                                            "${restaurant.data()?[RESTAURANT_ZIP]}",
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                    onPressed: () {
                                      globals.restaurantID =
                                          restaurant.data()?[RESTAURANT_ID];
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  RestaurantEdit(
                                                      id: restaurant.data()?[
                                                          RESTAURANT_ID])));
                                    },
                                    icon: const Icon(Icons.edit)),
                                onTap: () {
                                  globals.restaurantID =
                                      restaurant.data()?[RESTAURANT_ID];
                                  // Go to restaurant screen
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const Restaurant()));
                                },
                              )),
                        ))
                    .toList();
                final List<Widget> topView = [
                  Center(
                    child: Container(
                      width: double.maxFinite,
                      color: Colors.white,
                      padding: const EdgeInsets.all(10.0),
                      child: const Column(
                        children: [
                          Text("Control Panel",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  DefaultButton(
                                    child: Text(C_RESTAURANTS,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: globals.restaurantType ==
                                                    C_RESTAURANTS
                                                ? Theme.of(context).primaryColor
                                                : Colors.white)),
                                    level: 1,
                                    type: C_RESTAURANTS,
                                    onPressed: () {
                                      _getRestaurantsUpdates(C_RESTAURANTS);
                                    },
                                  ),
                                  DefaultButton(
                                    child: Text(C_WINERIES,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: globals.restaurantType ==
                                                    C_WINERIES
                                                ? Theme.of(context).primaryColor
                                                : Colors.white)),
                                    level: 1,
                                    type: C_WINERIES,
                                    onPressed: () {
                                      _getRestaurantsUpdates(C_WINERIES);
                                    },
                                  ),
                                  DefaultButton(
                                    child: Text(C_BREWERIES,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: globals.restaurantType ==
                                                    C_BREWERIES
                                                ? Theme.of(context).primaryColor
                                                : Colors.white)),
                                    level: 1,
                                    type: C_BREWERIES,
                                    onPressed: () {
                                      _getRestaurantsUpdates(C_BREWERIES);
                                    },
                                  ),
                                ]))),
                  ),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                              hintText: 'Search for the restaurants',
                              prefixIcon: Icon(Icons.search, size: 24)),
                          onFieldSubmitted: (value) {
                            setState(() {
                              searchKeyword = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              DefaultButton(
                                child: Text(
                                    isDisabled
                                        ? "Hold on..."
                                        : "Create a Template",
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white)),
                                onPressed: () {
                                  if (isDisabled) return;
                                  _onPressed();
                                  AppModel().createTemplateForRestaurant(
                                      filepath:
                                          'assets/resources/template_restaurant.xlsx',
                                      onSuccess: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('Success.')),
                                        );
                                        _onPressed();
                                      },
                                      onError: () {});
                                },
                              ),
                              const SizedBox(width: 5),
                              DefaultButton(
                                child: Text(
                                    isDisabled ? "Hold on..." : "Export",
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white)),
                                onPressed: () {
                                  if (isDisabled) return;
                                  _onPressed();
                                  AppModel().exportExcelForRestaurant(
                                      filepath:
                                          'assets/resources/template_restaurant.xlsx',
                                      onSuccess: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('Success.')),
                                        );
                                        _onPressed();
                                      },
                                      onError: () {});
                                },
                              ),
                              const SizedBox(width: 5),
                              DefaultButton(
                                child: Text(
                                    isDisabled ? "Hold on..." : "Import",
                                    style: const TextStyle(fontSize: 18)),
                                onPressed: () {
                                  if (isDisabled) return;
                                  _onPressed();
                                  AppModel().importExcelForRestaurant(
                                      onSuccess: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Success.')),
                                    );
                                    _onPressed();
                                  }, onError: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Failed.')),
                                    );
                                    _onPressed();
                                  });
                                },
                              ),
                            ],
                          )),
                    ),
                  ),
                ];
                final List<Widget> mainView = [...topView, ...restaurantViews];

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: mainView,
                  ),
                );
              }
            }));
  }
}
