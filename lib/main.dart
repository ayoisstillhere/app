import 'dart:io';

import 'package:app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:app/splash_screen.dart';
import 'package:app/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:media_kit/media_kit.dart';
import 'injection_container.dart' as di;
import 'services/deep_link_navigation_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  di.init();
  if (Platform.isAndroid) {
    await initFCM();
  }
  runApp(const MyApp());
  // Initialize deep link handling
  DeepLinkNavigationService.initialize();
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This runs when app is in background or terminated
  await Firebase.initializeApp();
  debugPrint("Handling background message: ${message.messageId}");

  final type = message.data['type'];

  // For call notifications, you might want to show a heads-up notification
  // or trigger a local notification that can wake the app
  if (type == 'CALL_NOTIFICATION') {
    // Handle call notification in background
    // You could show a local notification here if needed
    debugPrint('Call notification received in background');
  }

  // Other notifications are handled when the app opens
  debugPrint('Background notification type: $type');
}

Future<void> initFCM() async {
  await Firebase.initializeApp();
  await _requestNotificationPermission();
  await getFcmToken();
  listenForTokenRefresh();
}

Future<void> _requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    debugPrint('✅ Permission granted');
  } else {
    debugPrint('❌ Permission declined');
  }
}

Future<void> getFcmToken() async {
  const FlutterSecureStorage secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // This prevents data loss on app updates
      sharedPreferencesName: 'FlutterSecureStorage',
      preferencesKeyPrefix: 'flutter_secure_storage_',
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();

  if (token != null) {
    debugPrint('📱 FCM Token: $token');
    await secureStorage.write(key: 'fcm_token', value: token);
  } else {
    debugPrint('⚠️ Failed to get FCM token');
  }
}

void listenForTokenRefresh() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        // This prevents data loss on app updates
        sharedPreferencesName: 'FlutterSecureStorage',
        preferencesKeyPrefix: 'flutter_secure_storage_',
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
    debugPrint('🔄 FCM token refreshed: $newToken');

    secureStorage.write(key: 'fcm_token', value: newToken);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      _setupFCM();
    }
  }

  void _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ Push notification permission granted');
    } else {
      debugPrint('❌ Push notification permission denied');
      return;
    }

    // Get device token (for debugging or sending test messages)
    String? token = await messaging.getToken();
    debugPrint('📲 FCM Token: $token');

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Default',
              channelDescription: 'Default notification channel',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    // When tapped from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🟡 Notification tapped: ${message.data}');
      // Navigate or handle the tap
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<ChatCubit>(create: (_) => di.sl<ChatCubit>())],
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(platformBrightness: Brightness.dark),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: DeepLinkNavigationService.navigatorKey,
          title: 'Flutter Demo',
          theme: theme(),
          darkTheme: darkTheme(),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
