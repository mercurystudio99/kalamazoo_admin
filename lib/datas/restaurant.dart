import 'package:kalamazoo_app_dashboard/constants/constants.dart';

class Restaurant {
  final String address;
  final String businessName;
  final String city;
  final String email;
  final String phone;
  final String state;
  final String url;
  final String zip;

  // Constructor
  Restaurant({
    required this.address,
    required this.businessName,
    required this.city,
    required this.email,
    required this.phone,
    required this.state,
    required this.url,
    required this.zip,
  });

  /// factory user object
  factory Restaurant.fromDocument(Map<String, dynamic> doc) {
    return Restaurant(
        address: doc[RESTAURANT_ADDRESS],
        businessName: doc[RESTAURANT_BUSINESSNAME],
        city: doc[RESTAURANT_CITY] ?? '',
        email: doc[RESTAURANT_EMAIL],
        phone: doc[RESTAURANT_PHONE],
        state: doc[RESTAURANT_STATE],
        url: doc[RESTAURANT_URL],
        zip: doc[RESTAURANT_ZIP]);
  }
}
