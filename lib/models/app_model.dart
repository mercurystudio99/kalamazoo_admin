import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kalamazoo_app_dashboard/constants/constants.dart';
import 'package:kalamazoo_app_dashboard/datas/app_info.dart';
import 'package:kalamazoo_app_dashboard/utils/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:excel/excel.dart';

class AppModel extends Model {
  // Variables
  final _firestore = FirebaseFirestore.instance;
  AppInfo? appInfo;
  List<DocumentSnapshot<Map<String, dynamic>>> users = [];
  List<DocumentSnapshot<Map<String, dynamic>>> restaurants = [];
  int sortColumnIndex = 0;
  bool sortAscending = true;

  /// Create Singleton factory for [AppModel]
  ///
  static final AppModel _appModel = AppModel._internal();
  factory AppModel() {
    return _appModel;
  }
  AppModel._internal();
  // End

  /// Admin sign in method
  void adminSignIn({
    required String username,
    required String password,
    // VoidCallback functions
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    // Get app info
    final DocumentSnapshot<Map<String, dynamic>> appInfo =
        await getAppInfoDoc();
    // Get admin sign in credentials
    final String adminUsername = appInfo.data()![ADMIN_USERNAME];
    final String adminPassword = appInfo.data()![ADMIN_PASSWORD];

    // Check info
    if (adminUsername == username && adminPassword == password) {
      // Enable access
      onSuccess();
    } else {
      // Access denied
      onError();
    }
  }

  /// Get App Settings from database => Stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> getAppInfoStream() {
    return _firestore.collection(C_APP_INFO).doc('settings').snapshots();
  }

  /// Get App Settings from database => DocumentSnapshot<Map<String, dynamic>>>
  Future<DocumentSnapshot<Map<String, dynamic>>> getAppInfoDoc() async {
    final infoDoc =
        await _firestore.collection(C_APP_INFO).doc('settings').get();
    updateAppObject(infoDoc.data()!);
    return infoDoc;
  }

  /// Update AppInfo in database
  Future<void> updateAppData({required Map<String, dynamic> data}) {
    _firestore.collection(C_APP_INFO).doc('settings').update(data);
    return Future.value();
  }

  /// Update user data in database
  Future<void> updateUserData(
      {required String userId, required Map<String, dynamic> data}) async {
    // Update user data
    _firestore.collection(C_USERS).doc(userId).update(data);
  }

  /// Update Admin sign in info
  void updateAdminSignInInfo({
    required String adminUsername,
    required String adminPassword,
    // VoidCallback functions
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) {
    updateAppData(data: {
      ADMIN_USERNAME: adminUsername,
      ADMIN_PASSWORD: adminPassword,
    }).then((_) {
      onSuccess();
      debugPrint('updateAdminSignInInfo() -> success');
    }).catchError((error) {
      onError();
      debugPrint('updateAdminSignInInfo() -> error: $error');
    });
  }

  /// Update AppInfo object
  void updateAppObject(Map<String, dynamic> appDoc) {
    appInfo = AppInfo.fromDocument(appDoc);
    notifyListeners();
  }

  /// Get Users from database => stream
  Stream<QuerySnapshot<Map<String, dynamic>>> getUsers() {
    return _firestore.collection(C_USERS).snapshots();
  }

  /// Get Flagged Users Alert from database => stream
  Stream<QuerySnapshot<Map<String, dynamic>>> getFlaggedUsersAlert() {
    return _firestore
        .collection(C_FLAGGED_USERS)
        .orderBy(TIMESTAMP, descending: true)
        .snapshots();
  }

  /// Update User list
  void updateUsers(List<DocumentSnapshot<Map<String, dynamic>>> docs) {
    users = docs;
    notifyListeners();
    debugPrint('Users -> updated!');
  }

  void getRestaurantByID({
    required Function(Map<String, dynamic>?) onSuccess,
  }) {
    _firestore.collection(C_RESTAURANTS).doc(globals.restaurantID).get().then(
      (docSnapshot) {
        Map<String, dynamic>? data = docSnapshot.data();
        onSuccess(data);
      },
      onError: (e) => debugPrint("Error completing: $e"),
    );
  }

  /// Get Restaurants from database => stream
  Stream<QuerySnapshot<Map<String, dynamic>>> getRestaurants() {
    return _firestore
        .collection(C_RESTAURANTS)
        .orderBy(RESTAURANT_BUSINESSNAME)
        .snapshots();
  }

  /// Update Restaurant list
  void updateRestaurants(List<DocumentSnapshot<Map<String, dynamic>>> docs) {
    restaurants = docs;
    notifyListeners();
    debugPrint('Restaurants -> updated!');
  }

  /// Get Categories
  void getCategories({
    // callback functions
    required Function(Map<String, dynamic>) onSuccess,
  }) async {
    final snapshots =
        await _firestore.collection(C_APP_INFO).doc('categories').get();
    final Map<String, dynamic>? data = snapshots.data();
    onSuccess(data!);
  }

  // Update Categories
  void updateCategories(
      {required String key,
      required bool value,
      // callback functions
      required VoidCallback onSuccess}) {
    _firestore
        .collection(C_APP_INFO)
        .doc("categories")
        .update({key: !value}).then((value) => onSuccess(),
            onError: (e) => debugPrint("Error updating document $e"));
  }

  // Update variables used on table
  void updateOnSort(int columnIndex, bool sortAsc) {
    sortColumnIndex = columnIndex;
    sortAscending = sortAsc;
    notifyListeners();
    debugPrint('sortColumnIndex: $columnIndex');
    debugPrint('sortAscending: $sortAsc');
  }

  /// Save/Update app settings in database
  /// it is called in AppSettings screen
  void saveAppSettings({
    required int androidAppCurrentVersion,
    required int iosAppCurrentVersion,
    required String androidPackageName,
    required String iOsAppId,
    required String appEmail,
    required String privacyPolicyUrl,
    required String termsOfServicesUrl,
    required String firebaseServerKey,
    required double? freeAccountMaxDistance,
    required double? vipAccountMaxDistance,
    // VoidCallback functions
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) {
    updateAppData(data: {
      ANDROID_APP_CURRENT_VERSION: androidAppCurrentVersion,
      IOS_APP_CURRENT_VERSION: iosAppCurrentVersion,
      ANDROID_PACKAGE_NAME: androidPackageName,
      IOS_APP_ID: iOsAppId,
      PRIVACY_POLICY_URL: privacyPolicyUrl,
      TERMS_OF_SERVICE_URL: termsOfServicesUrl,
      APP_EMAIL: appEmail,
      FIREBASE_SERVER_KEY: firebaseServerKey,
      FREE_ACCOUNT_MAX_DISTANCE: freeAccountMaxDistance ?? 100,
      VIP_ACCOUNT_MAX_DISTANCE: vipAccountMaxDistance ?? 200,
    }).then((_) {
      onSuccess();
      debugPrint('updateAppSettings() -> success');
    }).catchError((error) {
      onError();
      debugPrint('updateAppSettings() -> error:$error ');
    });
  }

  /// Format firestore server Timestamp
  String formatDate(DateTime timestamp) {
    // Format
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd h:m a');
    return dateFormat.format(timestamp);
  }

  /// Calculate user current age
  int calculateUserAge(int userBirthYear) {
    DateTime date = DateTime.now();
    int currentYear = date.year;
    return (currentYear - userBirthYear);
  }

  /// Send push notification method
  Future<void> sendPushNotification({
    required String nBody,
    // VoidCallback functions
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    await http
        .post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=',
        // 'Authorization': 'key=${AppModel().appInfo!.firebaseServerKey}',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': APP_NAME,
            'body': nBody,
            'color': '#F50057',
            'sound': "default"
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'n_type': 'alert',
            'n_message': nBody,
            'status': 'done'
          },
          'to': '/topics/$NOTIFY_USERS',
        },
      ),
    )
        .then((http.Response response) {
      if (response.statusCode == 200) {
        onSuccess();
        debugPrint('sendPushNotification() -> success');
      } else {
        onError();
      }
    }).catchError((error) {
      onError();
      debugPrint('sendPushNotification() -> error: $error');
    });
  }

  void importExcel({
    required String filepath,
    // VoidCallback functions
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    ByteData data = await rootBundle.load(filepath);
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);

    bool flag = true;
    for (var row in excel.tables[EXCEL_SHEET]!.rows) {
      if (flag) {
        flag = false;
      } else {
        var list = row.map((e) => e?.value).toList();
        final docRef = _firestore.collection(C_RESTAURANTS).doc();
        await docRef.set({
          RESTAURANT_ID: docRef.id,
          RESTAURANT_ADDRESS: list[3].toString(),
          RESTAURANT_BUSINESSNAME: list[2].toString(),
          RESTAURANT_CITY: list[4].toString(),
          RESTAURANT_EMAIL: list[16].toString(),
          RESTAURANT_PHONE: list[7].toString(),
          RESTAURANT_STATE: list[5].toString(),
          RESTAURANT_URL: list[8].toString(),
          RESTAURANT_ZIP: list[6].toString()
        });
      }
    }
    onSuccess();
  }

  void saveMenu({
    required String imageUrl,
    required String name,
    required String price,
    // VoidCallback functions
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    final docRef = _firestore
        .collection(C_RESTAURANTS)
        .doc(globals.restaurantID)
        .collection(C_C_MENU)
        .doc();
    await docRef.set({
      MENU_ID: docRef.id,
      MENU_PHOTO_LINK: imageUrl,
      MENU_NAME: name,
      MENU_PRICE: price,
    });
    onSuccess();
  }

  void updateRestaurantImage({
    required String imageUrl,
    // VoidCallback functions
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    final docRef =
        _firestore.collection(C_RESTAURANTS).doc(globals.restaurantID);
    await docRef.update({
      RESTAURANT_IMAGE: imageUrl,
    });
    onSuccess();
  }
}
