import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/providers/AdvertismentProvider.dart';
import 'package:wise/providers/BankProvider.dart';
import 'package:wise/providers/FinancialAdvisorProvider.dart';
import 'package:wise/providers/GoalsProvider.dart';
import 'package:wise/providers/NotificationProvider.dart';
import 'package:wise/providers/SpendingCategoryProvider.dart';
import 'package:wise/providers/TermAndConditionProvider.dart';
import 'package:wise/providers/TransactionsProvider.dart';
import 'package:wise/providers/UserProvider.dart';
import 'package:wise/screens/splash_screen.dart'; // Import the SplashScreen here
import 'package:wise/screens/user/login/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Initialize Flutter Local Notifications
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and Firebase App Check
  try {
    await Firebase.initializeApp();
    await FirebaseAppCheck.instance
        .activate(androidProvider: AndroidProvider.debug);
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  // Initialize Local Notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(WiseApp());
}

class WiseApp extends StatefulWidget {
  @override
  _WiseAppState createState() => _WiseAppState();
}

class _WiseAppState extends State<WiseApp> {
  @override
  void initState() {
    super.initState();

    // Initialize Firebase Messaging
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Subscribe to the topic for daily notifications
    messaging.subscribeToTopic("daily-reminder");

    // Fetch and print the current FCM token
    _getToken();

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print("Token refreshed: $newToken");
      // You may want to save this new token to your backend server if needed
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(
          'Received a message while in the foreground: ${message.notification?.body}');

      if (message.notification != null) {
        // Display a local notification for foreground messages
        await flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title,
          message.notification!.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'your_channel_id',
              'your_channel_name',
              channelDescription: 'your_channel_description',
              importance: Importance.max,
              priority: Priority.high,
              icon:
                  '@mipmap/ic_launcher', // Ensure you have a valid icon in mipmap folders
            ),
          ),
        );
      }
    });

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked!');
      Navigator.pushNamed(context, '/login'); // Change to your target route
    });
  }

  // Method to get and print the current FCM token
  Future<void> _getToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print("Current FCM Token: $token"); // Print token in the console
      // You may also save the token to your backend server if needed
    } catch (e) {
      print("Error retrieving FCM token: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BankProvider()),
        ChangeNotifierProvider(create: (_) => FinancialAdvisorProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AdvertisementProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SpendingCategoryProvider()),
        ChangeNotifierProvider(create: (_) => TermAndConditionProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),
        ),
        routes: {
          '/': (context) => SplashScreen(),
          '/login': (context) => LoginPage(), // Define the route for LoginPage
          // Add other routes here as needed
        },
      ),
    );
  }
}
