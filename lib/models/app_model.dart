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
    _firestore
        .collection(globals.restaurantType)
        .doc(globals.restaurantID)
        .get()
        .then(
      (docSnapshot) {
        Map<String, dynamic>? data = docSnapshot.data();
        onSuccess(data);
      },
      onError: (e) => debugPrint("Error completing: $e"),
    );
  }

  void setRestaurantByID(
      {required String id,
      required String name,
      required String address,
      required String city,
      required String email,
      required String phone,
      required String state,
      required String url,
      required String zip,
      required VoidCallback onSuccess}) async {
    final docRef = _firestore.collection(globals.restaurantType).doc(id);
    await docRef.update({
      RESTAURANT_BUSINESSNAME: name,
      RESTAURANT_ADDRESS: address,
      RESTAURANT_CITY: city,
      RESTAURANT_EMAIL: email,
      RESTAURANT_PHONE: phone,
      RESTAURANT_STATE: state,
      RESTAURANT_URL: url,
      RESTAURANT_ZIP: zip,
    });
    onSuccess();
  }

  /// Get Restaurants from database => stream
  Stream<QuerySnapshot<Map<String, dynamic>>> getRestaurants() {
    return _firestore
        .collection(globals.restaurantType)
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

  /// Get Food Categories
  void getFoodCategories({
    required Function(List<Map<String, dynamic>>) onSuccess,
    required VoidCallback onEmpty,
  }) async {
    final snapshots = await _firestore
        .collection(C_CATEGORIES)
        .orderBy(CATEGORY_NAME, descending: false)
        .get();
    if (snapshots.docs.isEmpty) {
      onEmpty();
    } else {
      List<Map<String, dynamic>> list = [];
      for (var element in snapshots.docs) {
        list.add(element.data());
      }
      onSuccess(list);
    }
  }

  void getFoodCategory({
    required String id,
    required Function(Map<String, dynamic>?) onSuccess,
    required VoidCallback onEmpty,
  }) async {
    if (id.isNotEmpty) {
      final snapshots = await _firestore.collection(C_CATEGORIES).doc(id).get();
      if (snapshots.data()!.isEmpty) {
        onEmpty();
      } else {
        onSuccess(snapshots.data());
      }
    } else {
      onEmpty();
    }
  }

  // Set Food Categories
  void setFoodCategories(
      {required String name, required VoidCallback onSuccess}) async {
    final docRef = _firestore.collection(C_CATEGORIES).doc();
    await docRef.set({
      CATEGORY_ID: docRef.id,
      CATEGORY_NAME: name,
    });
    onSuccess();
  }

  // Set Food Category
  void setFoodCategory(
      {required String id,
      required String name,
      required VoidCallback onSuccess}) async {
    final docRef = _firestore.collection(C_CATEGORIES).doc(id);
    await docRef.update({
      CATEGORY_NAME: name,
    });
    onSuccess();
  }

  void getAmenities({
    required Function(List<Map<String, dynamic>>) onSuccess,
    required VoidCallback onEmpty,
  }) async {
    final snapshots = await _firestore
        .collection(C_AMENITIES)
        .orderBy(AMENITY_NAME, descending: false)
        .get();
    if (snapshots.docs.isEmpty) {
      onEmpty();
    } else {
      List<Map<String, dynamic>> list = [];
      for (var element in snapshots.docs) {
        list.add(element.data());
      }
      onSuccess(list);
    }
  }

  void getAmenity({
    required String id,
    required Function(Map<String, dynamic>?) onSuccess,
    required VoidCallback onEmpty,
  }) async {
    if (id.isNotEmpty) {
      final snapshots = await _firestore.collection(C_AMENITIES).doc(id).get();
      if (snapshots.data()!.isEmpty) {
        onEmpty();
      } else {
        onSuccess(snapshots.data());
      }
    } else {
      onEmpty();
    }
  }

  void setAmenities(
      {required String name,
      required String logo,
      required VoidCallback onSuccess}) async {
    final docRef = _firestore.collection(C_AMENITIES).doc();
    await docRef.set({
      AMENITY_ID: docRef.id,
      AMENITY_NAME: name,
      AMENITY_LOGO: logo,
    });
    onSuccess();
  }

  void setAmenity(
      {required String id,
      required String name,
      required String logo,
      required VoidCallback onSuccess}) async {
    final docRef = _firestore.collection(C_AMENITIES).doc(id);
    await docRef.update({
      AMENITY_NAME: name,
      AMENITY_LOGO: logo,
    });
    onSuccess();
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
    for (var row in excel.tables['Sheet1']!.rows) {
      if (flag) {
        flag = false;
      } else {
        var list = row.map((e) => e?.value).toList();
        final docRef = _firestore.collection(C_WINERIES).doc();
        await docRef.set({
          RESTAURANT_ID: docRef.id,
          RESTAURANT_ADDRESS: list[1].toString(),
          RESTAURANT_BUSINESSNAME: list[0].toString(),
          RESTAURANT_CITY: list[2].toString(),
          RESTAURANT_EMAIL: list[6].toString(),
          RESTAURANT_PHONE: list[5].toString(),
          RESTAURANT_STATE: list[3].toString(),
          RESTAURANT_URL: list[8].toString(),
          RESTAURANT_ZIP: list[4].toString()
        });
      }
    }
    onSuccess();
  }
  // void importExcel({
  //   required String filepath,
  //   // VoidCallback functions
  //   required VoidCallback onSuccess,
  //   required VoidCallback onError,
  // }) async {
  //   ByteData data = await rootBundle.load(filepath);
  //   var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  //   var excel = Excel.decodeBytes(bytes);

  //   for (var row in excel.tables['Sheet1']!.rows) {
  //     var list = row.map((e) => e?.value).toList();
  //     if (list[0].toString().trim().isEmpty) continue;
  //     final docRef = _firestore
  //         .collection(globals.restaurantType)
  //         .doc(list[0].toString().trim())
  //         .collection(C_C_MENU)
  //         .doc();
  //     await docRef.set({
  //       MENU_ID: docRef.id,
  //       MENU_NAME: list[6].toString(),
  //       MENU_DESCRIPTION: list[7].toString(),
  //       MENU_PRICE: list[8].toString()
  //     });
  //   }
  //   onSuccess();
  // }

  void exportExcel({
    required String filepath,
    // VoidCallback functions
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    final snapshots = await _firestore.collection(globals.restaurantType).get();

    ByteData data = await rootBundle.load(filepath);
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);

    Sheet sheetObject = excel['Sheet1'];

    var count = 0;
    for (var snapshot in snapshots.docs) {
      List<String> dataList = [
        snapshot.data()[RESTAURANT_ID],
        snapshot.data()[RESTAURANT_BUSINESSNAME]
      ];
      sheetObject.insertRowIterables(dataList, ++count);
    }
    excel.save(fileName: 'result.xlsx');

    onSuccess();
  }

  void getMenu({
    required Function(List<QueryDocumentSnapshot<Map<String, dynamic>>>)
        onSuccess,
    required VoidCallback onEmpty,
  }) {
    _firestore
        .collection(globals.restaurantType)
        .doc(globals.restaurantID)
        .collection(C_C_MENU)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        onSuccess(querySnapshot.docs);
      } else {
        onEmpty();
      }
    });
  }

  void saveMenu({
    required String imageUrl,
    required String name,
    required String price,
    required String desc,
    required String category,
    // VoidCallback functions
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    final docRef = _firestore
        .collection(globals.restaurantType)
        .doc(globals.restaurantID)
        .collection(C_C_MENU)
        .doc();
    if (category.isEmpty) {
      await docRef.set({
        MENU_ID: docRef.id,
        MENU_PHOTO_LINK: imageUrl,
        MENU_NAME: name,
        MENU_PRICE: price,
        MENU_DESCRIPTION: desc,
      });
    } else {
      await docRef.set({
        MENU_ID: docRef.id,
        MENU_PHOTO_LINK: imageUrl,
        MENU_NAME: name,
        MENU_PRICE: price,
        MENU_DESCRIPTION: desc,
        MENU_CATEGORY: category,
      });
    }
    onSuccess();
  }

  void getFood({
    required String id,
    required Function(Map<String, dynamic>?) onSuccess,
  }) {
    _firestore
        .collection(globals.restaurantType)
        .doc(globals.restaurantID)
        .collection(C_C_MENU)
        .doc(id)
        .get()
        .then(
      (docSnapshot) {
        Map<String, dynamic>? data = docSnapshot.data();
        onSuccess(data);
      },
      onError: (e) => debugPrint("Error completing: $e"),
    );
  }

  void setFood(
      {required String id,
      required String name,
      required String price,
      required String desc,
      required String category,
      required VoidCallback onSuccess}) async {
    final docRef = _firestore
        .collection(globals.restaurantType)
        .doc(globals.restaurantID)
        .collection(C_C_MENU)
        .doc(id);
    await docRef.update({
      MENU_NAME: name,
      MENU_PRICE: price,
      MENU_DESCRIPTION: desc,
      MENU_CATEGORY: category,
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
        _firestore.collection(globals.restaurantType).doc(globals.restaurantID);
    await docRef.update({
      RESTAURANT_IMAGE: imageUrl,
    });
    onSuccess();
  }

  void updateRestaurantAmenities({
    required List<dynamic> list,
    // VoidCallback functions
    required VoidCallback onSuccess,
  }) async {
    final docRef =
        _firestore.collection(globals.restaurantType).doc(globals.restaurantID);
    await docRef.update({
      RESTAURANT_AMENITIES: list,
    });
    onSuccess();
  }

  void updateFoodImage({
    required String id,
    required String imageUrl,
    // VoidCallback functions
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    final docRef = _firestore
        .collection(globals.restaurantType)
        .doc(globals.restaurantID)
        .collection(C_C_MENU)
        .doc(id);
    await docRef.update({
      MENU_PHOTO_LINK: imageUrl,
    });
    onSuccess();
  }
}
