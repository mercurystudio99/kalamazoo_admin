import 'package:kalamazoo_app_dashboard/constants/constants.dart';

class User {
  /// User info
  final String userId;
  final String userProfilePhoto;
  final String userFullname;
  final String userGender;
  final String userBirthDay;
  final String userBirthMonth;
  final String userBirthYear;
  // final String userSchool;
  // final String userJobTitle;
  // final String userBio;
  final String userPhoneNumber;
  final String userEmail;
  // final String userCountry;
  // final String userLocality;
  // final GeoPoint userGeoPoint;
  final String userStatus;
  final bool userIsVerified;
  final String userRole;
  // final DateTime userRegDate;
  // final DateTime userLastLogin;
  // final String userDeviceToken;
  // final int userTotalLikes;
  // final int userTotalVisits;
  // final int userTotalDisliked;
  // final Map<String, dynamic>? userGallery;
  // final Map<String, dynamic> userSettings;

  // Constructor
  User({
    required this.userId,
    required this.userProfilePhoto,
    required this.userFullname,
    required this.userGender,
    required this.userBirthDay,
    required this.userBirthMonth,
    required this.userBirthYear,
    // required this.userSchool,
    // required this.userJobTitle,
    // required this.userBio,
    required this.userPhoneNumber,
    required this.userEmail,
    // required this.userGallery,
    // required this.userCountry,
    // required this.userLocality,
    // required this.userGeoPoint,
    // required this.userSettings,
    required this.userStatus,
    required this.userIsVerified,
    required this.userRole,
    // required this.userRegDate,
    // required this.userLastLogin,
    // required this.userDeviceToken,
    // required this.userTotalLikes,
    // required this.userTotalVisits,
    // required this.userTotalDisliked,
  });

  /// factory user object
  factory User.fromDocument(Map<String, dynamic> doc) {
    return User(
      userId: doc[USER_ID],
      userProfilePhoto: doc[USER_PROFILE_PHOTO] ?? '',
      userFullname: doc[USER_FULLNAME] ?? '',
      userGender: doc[USER_GENDER] ?? '',
      userBirthDay: doc[USER_BIRTH_DAY] ?? '',
      userBirthMonth: doc[USER_BIRTH_MONTH] ?? '',
      userBirthYear: doc[USER_BIRTH_YEAR] ?? '',
      // userSchool: doc[USER_SCHOOL] ?? '',
      // userJobTitle: doc[USER_JOB_TITLE] ?? '',
      // userBio: doc[USER_BIO],
      userPhoneNumber: doc[USER_PHONE_NUMBER] ?? '',
      userEmail: doc[USER_EMAIL] ?? '',
      // userGallery: doc[USER_GALLERY],
      // userCountry: doc[USER_COUNTRY] ?? '',
      // userLocality: doc[USER_LOCALITY] ?? '',
      // userGeoPoint: doc[USER_GEO_POINT]['geopoint'],
      // userSettings: doc[USER_SETTINGS],
      userStatus: doc[USER_STATUS] ?? '',
      userIsVerified: doc[USER_IS_VERIFIED] ?? false,
      userRole: doc[USER_ROLE] ?? '',
      // userRegDate: doc[USER_REG_DATE].toDate(), // Firestore Timestamp
      // userLastLogin: doc[USER_LAST_LOGIN].toDate(), // Firestore Timestamp
      // userDeviceToken: doc[USER_DEVICE_TOKEN] ?? '',
      // userTotalLikes: doc[USER_TOTAL_LIKES] ?? 0,
      // userTotalVisits: doc[USER_TOTAL_VISITS] ?? 0,
      // userTotalDisliked: doc[USER_TOTAL_DISLIKED] ?? 0,
    );
  }
}
