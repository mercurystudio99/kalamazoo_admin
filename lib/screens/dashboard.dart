import 'package:cloud_firestore/cloud_firestore.dart';
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
  }

  @override
  void dispose() {
    _appInfo.drain();
    _users?.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text(APP_NAME)),
        drawer: const MyNavigationDrawer(),
        backgroundColor: Colors.grey.withAlpha(70),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _users,
            builder: (context, snapshot) {
              // Check data
              if (!snapshot.hasData) {
                return const Processing();
              } else {
                // Variables
                final List<DocumentSnapshot<Map<String, dynamic>>> users =
                    snapshot.data!.docs;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Dashboard Header
                      Center(
                        child: Container(
                          width: double.maxFinite,
                          color: Colors.white,
                          padding: const EdgeInsets.all(10.0),
                          child: const Column(
                            children: [
                              Text("Control Panel",
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: 300,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: DefaultButton(
                              child: const Text("Import Excel to Firebase",
                                  style: TextStyle(fontSize: 18)),
                              onPressed: () {
                                AppModel().importExcel(
                                    filepath: 'assets/resources/data.xlsx',
                                    onSuccess: () {},
                                    onError: () {});
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            }));
  }
}
