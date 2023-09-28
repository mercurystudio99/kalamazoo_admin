import 'package:kalamazoo_app_dashboard/constants/constants.dart';

class Restaurant {
  final String id;
  final String address;
  final List<dynamic> amenities;
  final bool brand;
  final String businessName;
  final String city;
  final String email;
  final List<double> geolocation;
  final String phone;
  final String state;
  final String url;
  final String zip;

  // Constructor
  Restaurant({
    required this.id,
    required this.address,
    required this.amenities,
    required this.brand,
    required this.businessName,
    required this.city,
    required this.email,
    required this.geolocation,
    required this.phone,
    required this.state,
    required this.url,
    required this.zip,
  });

  /// factory user object
  factory Restaurant.fromDocument(Map<String, dynamic> doc) {
    return Restaurant(
        id: doc[RESTAURANT_ID],
        address: doc[RESTAURANT_ADDRESS],
        amenities: doc[RESTAURANT_AMENITIES] ?? [],
        brand: doc[RESTAURANT_BRAND] ?? false,
        businessName: doc[RESTAURANT_BUSINESSNAME],
        city: doc[RESTAURANT_CITY] ?? '',
        email: doc[RESTAURANT_EMAIL],
        geolocation: doc[RESTAURANT_GEOLOCATION] ?? [],
        phone: doc[RESTAURANT_PHONE],
        state: doc[RESTAURANT_STATE],
        url: doc[RESTAURANT_URL],
        zip: doc[RESTAURANT_ZIP]);
  }
}
