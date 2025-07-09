import 'dart:io';

import 'package:app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:app/splash_screen.dart';
import 'package:app/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  di.init();
  if (Platform.isAndroid) {
  await initFCM();
}
  runApp(const MyApp());
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
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
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
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();
    debugPrint('🔄 FCM token refreshed: $newToken');

    secureStorage.write(key: 'fcm_token', value: newToken);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<ChatCubit>(create: (_) => di.sl<ChatCubit>())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: theme(),
        darkTheme: darkTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}
