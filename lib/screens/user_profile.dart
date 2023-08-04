import 'package:kalamazoo_app_dashboard/constants/constants.dart';
import 'package:kalamazoo_app_dashboard/datas/user.dart';
import 'package:kalamazoo_app_dashboard/dialogs/common_dialogs.dart';
import 'package:kalamazoo_app_dashboard/models/app_model.dart';
import 'package:kalamazoo_app_dashboard/widgets/show_scaffold_msg.dart';
import 'package:kalamazoo_app_dashboard/widgets/user_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfileScreen extends StatelessWidget {
  // Variables
  final User user;

  // Constructor
  ProfileScreen({Key? key, required this.user}) : super(key: key);

  // Local variables
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Get user profile gallery
  List<String> get _getUserGallery {
    List<String> images = [];
    // loop user gallery
    debugPrint('_getUserGallery() -> length: ${images.length}');
    return images;
  }

  // Copy text to Clipboard
  void _copyText(BuildContext context,
      {required String text, required String message}) {
    // Copy text
    Clipboard.setData(ClipboardData(text: text));
    // Show success message
    showScaffoldMessage(
        context: context,
        scaffoldkey: _scaffoldKey,
        message: "$message Copied Successfully!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("User profile"),
        elevation: 0,
        actions: <Widget>[
          /// Actions list
          PopupMenuButton<String>(
            initialValue: "",
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              /// Copy User ID
              const PopupMenuItem(
                  value: "copy_user_id",
                  child: ListTile(
                    leading: Text("Copy User ID"),
                    trailing: Icon(Icons.copy_outlined),
                  )),

              /// Copy Phone Number
              const PopupMenuItem(
                  value: "copy_phone_number",
                  child: ListTile(
                    leading: Text("Copy Phone Number"),
                    trailing: Icon(Icons.copy_outlined),
                  )),

              /// Update user status ex: Block/Active
              PopupMenuItem(
                  value: "update_user_status",
                  child: ListTile(
                    leading: Text(user.userStatus == 'active'
                        ? 'Block User'
                        : 'Activate User'),
                    trailing: Icon(user.userStatus == 'active'
                        ? Icons.lock_outline
                        : Icons.check_circle_outline_rounded),
                  )),
            ],
            onSelected: (val) {
              /// Control selected value
              switch (val) {
                case 'copy_user_id':
                  // Copy user ID
                  _copyText(context, text: user.userId, message: 'User ID');
                  break;

                case 'copy_phone_number':
                  // Copy user phone number
                  _copyText(context,
                      text: user.userPhoneNumber, message: 'User Phone Number');
                  break;

                case 'update_user_status':

                  // Update user status
                  // Show confirm dialog
                  String newStatus;
                  String message;
                  String positiveText;

                  // Check current user status
                  if (user.userStatus == 'active') {
                    newStatus = 'blocked';
                    positiveText = 'BLOCK';
                    message = 'User account will be Blocked!';
                  } else {
                    newStatus = 'active';
                    positiveText = 'ACTIVATE';
                    message = 'User account will be Activated!';
                  }

                  // Show dialog
                  confirmDialog(context,
                      message: message,
                      negativeText: 'CANCEL',
                      negativeAction: () => Navigator.of(context).pop(),
                      positiveText: positiveText,
                      positiveAction: () async {
                        // Update user status
                        await AppModel().updateUserData(
                            userId: user.userId,
                            data: {USER_STATUS: newStatus}).then((_) {
                          // Show success message
                          showScaffoldMessage(
                              context: context,
                              scaffoldkey: _scaffoldKey,
                              message: "Profile status updated successfully!");
                        }).catchError((e) {
                          // Show error message
                          showScaffoldMessage(
                              context: context,
                              scaffoldkey: _scaffoldKey,
                              message:
                                  "Error while updating profile status.\nPlease try again later!");
                        });

                        // Close dialog
                        Navigator.of(context).pop();
                      });
                  break;
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Profile Photo and statistics
          Container(
              padding: const EdgeInsets.only(top: 20),
              height: 445,
              color: Theme.of(context).primaryColor,
              child: Column(
                children: [
                  // Profile photo
                  CircleAvatar(
                      radius: 120,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(user.userProfilePhoto)),
                  // Full name
                  const SizedBox(height: 10),
                  Text(user.userFullname,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold)),

                  const SizedBox(height: 10),

                  // Profile location
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on_outlined, color: Colors.white),
                      ]),
                  const SizedBox(height: 5),
                ],
              )),

          /// Profile Galery
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Profile Gallery",
                style: TextStyle(color: Colors.grey, fontSize: 18)),
          ),

          /// Show gallery
          _getUserGallery.isEmpty
              ? Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        children: [
                          Icon(Icons.photo_library_outlined,
                              color: Theme.of(context).primaryColor, size: 100),
                          const SizedBox(height: 10),
                          const Text("Gallery empty",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: _getUserGallery.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.grey.withAlpha(70),
                      clipBehavior: Clip.antiAlias,
                      semanticContainer: true,
                      child: Image.network(_getUserGallery[index],
                          fit: BoxFit.fill),
                    );
                  }),
          const Divider(thickness: 1),

          /// Profile Galery
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Profile information",
                style: TextStyle(color: Colors.grey, fontSize: 18)),
          ),
          const Divider(thickness: 1),

          // User full name
          ListTile(
              leading: Icon(Icons.person_outline,
                  color: Theme.of(context).primaryColor),
              title: const Text('Full name'),
              trailing: Text(user.userFullname)),
          const Divider(thickness: 1),

          // User gender
          ListTile(
              leading: Icon(Icons.wc_outlined,
                  color: Theme.of(context).primaryColor),
              title: const Text('Gender'),
              trailing: Text(user.userGender)),
          const Divider(thickness: 1),

          // User Birthday
          ListTile(
            leading: Icon(Icons.calendar_today_outlined,
                color: Theme.of(context).primaryColor),
            title: const Text('Birthday'),
            subtitle: Text('Current age: '
                '${AppModel().calculateUserAge(int.parse(user.userBirthYear))}'),
            trailing: Text('${user.userBirthYear}/'
                '${user.userBirthMonth}/'
                '${user.userBirthDay}'), // Date Format: year/month/day
          ),
          const Divider(thickness: 1),

          // User Phone number
          ListTile(
              leading: Icon(Icons.call_outlined,
                  color: Theme.of(context).primaryColor),
              title: const Text('Phone number'),
              trailing: Text(user.userPhoneNumber)),
          const Divider(thickness: 1),

          // User Email
          ListTile(
              leading: Icon(Icons.email_outlined,
                  color: Theme.of(context).primaryColor),
              title: const Text('Email'),
              trailing: Text(user.userEmail)),
          const Divider(thickness: 1),

          // // User Registration date
          // ListTile(
          //   leading: Icon(Icons.create_outlined,
          //       color: Theme.of(context).primaryColor),
          //   title: const Text('Registration date'),
          //   trailing: Text(AppModel()
          //       .formatDate(user.userRegDate)), // Date Format: year/month/day
          // ),
          // const Divider(thickness: 1),

          // // User Last active
          // ListTile(
          //   leading: Icon(Icons.access_time_outlined,
          //       color: Theme.of(context).primaryColor),
          //   title: const Text('Last active'),
          //   trailing: Text(timeago.format(user.userLastLogin)),
          // ),
          // const Divider(thickness: 1),

          // User ID
          ListTile(
              leading: Icon(Icons.person_outline,
                  color: Theme.of(context).primaryColor),
              title: const Text('User ID'),
              subtitle: Text(user.userId, style: const TextStyle(fontSize: 17)),
              trailing: IconButton(
                icon: const Icon(Icons.copy, color: Colors.grey),
                onPressed: () {
                  // Copy user ID
                  _copyText(context, text: user.userId, message: 'User ID');
                },
              )),
          const Divider(thickness: 1),

          // User Status
          ListTile(
              leading: Icon(Icons.info_outline,
                  color: Theme.of(context).primaryColor),
              title: const Text('User Status'),
              trailing: UserStatus(status: user.userStatus)),
          const Divider(thickness: 1),

          // User Verified
          ListTile(
            leading: Icon(Icons.verified_outlined,
                color: Theme.of(context).primaryColor),
            title: const Text('User Verified'),
            subtitle: const Text(
                'User is verified automatically when subscribe to VIP account'),
            trailing: UserStatus(
                status: user.userIsVerified ? 'verified' : 'Not verified'),
          ),
          const Divider(thickness: 1),
          const SizedBox(height: 30),
        ],
      )),
    );
  }
}
