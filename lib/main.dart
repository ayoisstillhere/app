import 'dart:io';

import 'package:app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:app/services/auth_manager.dart';
import 'package:app/splash_screen.dart';
import 'package:app/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:media_kit/media_kit.dart';
import 'features/chat/presentation/cubit/live_stream_comment_cubit.dart';
import 'features/chat/presentation/cubit/live_stream_reaction_cubit.dart';
import 'injection_container.dart' as di;
import 'services/deep_link_navigation_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await Firebase.initializeApp();
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
  if (Platform.isAndroid) await initFCM();
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
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // For iOS, explicitly get APNs token first
  if (Platform.isIOS) {
    String? apnsToken = await messaging.getAPNSToken();
    if (apnsToken != null) {
      debugPrint('🍎 APNs Token: $apnsToken');
    } else {
      // Wait a bit and try again
      debugPrint('⏳ APNs token not available, retrying...');
      await Future.delayed(Duration(seconds: 3));
      apnsToken = await messaging.getAPNSToken();
      if (apnsToken != null) {
        debugPrint('🍎 APNs Token (retry): $apnsToken');
      } else {
        debugPrint('⚠️ Failed to get APNs token after retry');
      }
    }
  }

  String? token = await messaging.getToken();

  if (token != null) {
    debugPrint('📱 FCM Token: $token');
    await AuthManager.setFCMToken(token);
  } else {
    debugPrint('⚠️ Failed to get FCM token');
  }
}

void listenForTokenRefresh() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    debugPrint('🔄 FCM token refreshed: $newToken');
    await AuthManager.setFCMToken(newToken);
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
    // Setup FCM for both platforms
    if (Platform.isAndroid) _setupFCM();
  }

  void _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions (works for both iOS and Android)
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

    // For iOS, ensure APNs token is available
    if (Platform.isIOS) {
      await _ensureAPNsToken();
    }

    // Get device token (for debugging or sending test messages)
    String? token = await messaging.getToken();
    debugPrint('📲 FCM Token: $token');

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;

      if (notification != null) {
        if (Platform.isAndroid) {
          AndroidNotification? android = message.notification?.android;
          if (android != null) {
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
        } else if (Platform.isIOS) {
          // For iOS, show local notification
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
          );
        }
      }
    });

    // When tapped from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🟡 Notification tapped: ${message.data}');
      // Navigate or handle the tap
    });
  }

  Future<void> _ensureAPNsToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Try to get APNs token with retries
    String? apnsToken;
    int maxRetries = 5;
    int retryCount = 0;

    while (apnsToken == null && retryCount < maxRetries) {
      apnsToken = await messaging.getAPNSToken();
      if (apnsToken == null) {
        debugPrint(
          '⏳ Waiting for APNs token... (attempt ${retryCount + 1}/$maxRetries)',
        );
        await Future.delayed(Duration(seconds: 2));
        retryCount++;
      }
    }

    if (apnsToken != null) {
      debugPrint('🍎 APNs Token obtained: $apnsToken');
    } else {
      debugPrint('⚠️ Failed to obtain APNs token after $maxRetries attempts');
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatCubit>(create: (_) => di.sl<ChatCubit>()),
        BlocProvider<LiveStreamCommentCubit>(
          create: (_) => di.sl<LiveStreamCommentCubit>(),
        ),
        BlocProvider<LiveStreamReactionCubit>(
          create: (_) => di.sl<LiveStreamReactionCubit>(),
        ),
      ],
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
