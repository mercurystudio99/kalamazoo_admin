import 'package:kalamazoo_app_dashboard/constants/constants.dart';
import 'package:kalamazoo_app_dashboard/models/app_model.dart';
import 'package:kalamazoo_app_dashboard/screens/sign_in_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'firebase_options.dart';

void main() async {
  // Initialized before calling runApp to init firebase app
  WidgetsFlutterBinding.ensureInitialized();

  /// ***  Initialize Firebase App *** ///
  /// 👉 Please check the [Documentation - README FIRST] instructions in the
  /// [Admin Panel Table of Contents] at section: [NEW - Firebase initialization for Admin Panel]
  /// in order to fix it and generate the required [firebase_options.dart] for your app.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  String? token = await messaging.getToken();
  debugPrint(token);
  FirebaseMessaging.onMessage.listen((remoteMessage) {
    debugPrint(" --- foreground message received ---");
    debugPrint(remoteMessage.notification!.title);
    debugPrint(remoteMessage.notification!.body);
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

/// Top level function to handle incoming messages when the app is in the background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(" --- background message received ---");
  debugPrint(message.notification!.title);
  debugPrint(message.notification!.body);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppModel>(
      model: AppModel(),
      child: MaterialApp(
          title: APP_NAME,
          debugShowCheckedModeBanner: false,
          home: const SignInScreen(),
          theme: ThemeData(
              primaryColor: APP_PRIMARY_COLOR,
              colorScheme: const ColorScheme.light().copyWith(
                  primary: APP_PRIMARY_COLOR,
                  secondary: APP_ACCENT_COLOR,
                  background: APP_PRIMARY_COLOR))),
    );
  }
}
