// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

/// APP INFO CONSTANTS ///
///
const String APP_NAME = "Kalamazoo App Admin Panel";
const Color APP_PRIMARY_COLOR = Color.fromARGB(255, 65, 6, 96);
const Color APP_ACCENT_COLOR = Color.fromARGB(255, 176, 108, 212);

const String EXCEL_SHEET = "Sheet1";

/// FIREBASE MESSAGING TOPIC
const NOTIFY_USERS = "NOTIFY_USERS";

/// DATABASE FIELDS FOR AppInfo COLLECTION  ///
///
const String ANDROID_APP_CURRENT_VERSION = "android_app_current_version";
const String IOS_APP_CURRENT_VERSION = "ios_app_current_version";
const String ANDROID_PACKAGE_NAME = "android_package_name";
const String IOS_APP_ID = "ios_app_id";
const String APP_EMAIL = "app_email";
const String PRIVACY_POLICY_URL = "privacy_policy_url";
const String TERMS_OF_SERVICE_URL = "terms_of_service_url";
const String FIREBASE_SERVER_KEY = "firebase_server_key";
const String STORE_SUBSCRIPTION_IDS = "store_subscription_ids";
const String FREE_ACCOUNT_MAX_DISTANCE = "free_account_max_distance";
const String VIP_ACCOUNT_MAX_DISTANCE = "vip_account_max_distance";
// Admin variables
const String ADMIN_USERNAME = "admin_username";
const String ADMIN_PASSWORD = "admin_password";

/// DATABASE COLLECTION NAMES USED IN APP
///
const String C_APP_INFO = "AppInfo";
const String C_USERS = "Users";
const String C_CATEGORIES = "Categories";
const String C_AMENITIES = "Amenities";
const String C_RESTAURANTS = "Restaurants";
const String C_WINERIES = "Wineries";
const String C_BREWERIES = "Breweries";
const String C_TOPMENU = "TopMenus";
const String C_FLAGGED_USERS = "FlaggedUsers";
const String C_C_MENU = "Menu";

/// DATABASE FIELDS FOR USER COLLECTION  ///
///
const String USER_ID = "user_id";
const String USER_PROFILE_PHOTO = "user_photo_link";
const String USER_FULLNAME = "user_fullname";
const String USER_GENDER = "user_gender";
const String USER_BIRTH_DAY = "user_birth_day";
const String USER_BIRTH_MONTH = "user_birth_month";
const String USER_BIRTH_YEAR = "user_birth_year";
const String USER_SCHOOL = "user_school";
const String USER_JOB_TITLE = "user_job_title";
const String USER_BIO = "user_bio";
const String USER_PHONE_NUMBER = "user_phone_number";
const String USER_EMAIL = "user_email";
const String USER_GALLERY = "user_gallery";
const String USER_COUNTRY = "user_country";
const String USER_LOCALITY = "user_locality";
const String USER_GEO_POINT = "user_geo_point";
const String USER_SETTINGS = "user_settings";
const String USER_STATUS = "user_status";
const String USER_IS_VERIFIED = "user_is_verified";
const String USER_ROLE = "user_role";
const String USER_REG_DATE = "user_reg_date";
const String USER_LAST_LOGIN = "user_last_login";
const String USER_DEVICE_TOKEN = "user_device_token";
const String USER_TOTAL_LIKES = "user_total_likes";
const String USER_TOTAL_VISITS = "user_total_visits";
const String USER_TOTAL_DISLIKED = "user_total_disliked";
// User Setting map - fields
const String USER_MIN_AGE = "user_min_age";
const String USER_MAX_AGE = "user_max_age";
const String USER_MAX_DISTANCE = "user_max_distance";

/// DATABASE FIELDS FOR FlaggedUsers COLLECTION  ///
///
const String FLAGGED_USER_ID = "flagged_user_id";
const String FLAG_REASON = "flag_reason";
const String FLAGGED_BY_USER_ID = "flagged_by_user_id";
const String TIMESTAMP = "timestamp";

const String RESTAURANT_ID = "id";
const String RESTAURANT_ADDRESS = "address";
const String RESTAURANT_AMENITIES = "amenities";
const String RESTAURANT_BRAND = "brand";
const String RESTAURANT_BUSINESSNAME = "businessName";
const String RESTAURANT_CATEGORY = "category";
const String RESTAURANT_CITY = "city";
const String RESTAURANT_EMAIL = "email";
const String RESTAURANT_GEOLOCATION = "geolocation";
const String RESTAURANT_IMAGE = "imageLink";
const String RESTAURANT_PHONE = "phone";
const String RESTAURANT_STATE = "state";
const String RESTAURANT_URL = "url";
const String RESTAURANT_ZIP = "zip";

const String MENU_ID = "id";
const String MENU_NAME = "name";
const String MENU_PRICE = "price";
const String MENU_DESCRIPTION = "description";
const String MENU_CATEGORY = "category";
const String MENU_PHOTO_LINK = "photoLink";

const String CATEGORY_ID = "id";
const String CATEGORY_NAME = "name";

const String AMENITY_ID = "id";
const String AMENITY_NAME = "name";
const String AMENITY_LOGO = "logo";
const String AMENITY_TYPE = "type";

const String TOPMENU_ID = "id";
const String TOPMENU_NAME = "name";
const String TOPMENU_IMAGE = "imgName";
