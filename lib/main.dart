import 'dart:io';
import 'package:animations/animations.dart';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sevanam_mobkol/firebase_options.dart';
import 'package:sevanam_mobkol/services/utils/location_utils.dart';
import 'package:sevanam_mobkol/services/utils/notification_utils.dart';
import 'package:sevanam_mobkol/ui/widgets/dialog/info_dialog.dart';
import 'package:sevanam_mobkol/services/config/config.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/config/config.dart' as config;
import 'services/config/router_generator.dart';
import 'services/viewmodel/produk_provider.dart';
import 'services/viewmodel/global_provider.dart';
import 'services/viewmodel/transaksi_provider.dart';
import 'services/utils/platform_utils.dart';
import 'services/utils/connectivity_utils.dart';
import 'setup.dart';
import 'ui/constant/constant.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// PERBAIKAN 1: Background handler harus di luar class dan tanpa BuildContext
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase jika belum
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('Handling background message: ${message.messageId}');

  // Handle notifikasi di background
  if (message.notification != null) {
    debugPrint('Background Notification: ${message.notification?.title}');
  }
}

Future<void> setupFirebaseMessaging(BuildContext context) async {
  // PERBAIKAN 2: Set background handler dengan benar
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  debugPrint('User granted permission: ${settings.authorizationStatus}');

  // PERBAIKAN 3: Foreground message handler
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint(
          'Message also contained a notification: ${message.notification}');

      // Tampilkan notifikasi
      NotificationUtils.instance.showNotification(
        context,
        message.notification?.title ?? "",
        message.notification?.body ?? "",
      );
    }
  });

  // PERBAIKAN 4: Handle notifikasi yang di-tap
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('A new onMessageOpenedApp event was published!');
    // Handle navigation atau action saat notifikasi di-tap
  });

  // Get FCM token
  try {
    String? token = await messaging.getToken();
    if (token != null) {
      debugPrint("FCM Token: $token");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedToken = prefs.getString("firebase_id");

      // PERBAIKAN 5: Logic yang benar untuk save token
      if (savedToken == null || savedToken.isEmpty || savedToken != token) {
        await prefs.setString('firebase_id', token);
        debugPrint("FCM Token saved to SharedPreferences");
      }

      config.firebaseId = token;
      config.platform = await PlatformUtils.distance.initPlatformState();
    } else {
      debugPrint("FCM Token: failed to get token");
    }
  } catch (e) {
    debugPrint("FCM Token error: $e");
  }

  // PERBAIKAN 6: Listen untuk token refresh
  messaging.onTokenRefresh.listen((newToken) async {
    debugPrint("FCM Token refreshed: $newToken");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firebase_id', newToken);
    config.firebaseId = newToken;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // PERBAIKAN 7: Initialize Firebase dengan error handling
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("Firebase initialized successfully");
    }
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  // PERBAIKAN 8: Load environment dengan error handling
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("Environment variables loaded");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
  }

  setupApp();
  configLoading();

  runApp(MyApp());
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.light
    ..maskType = EasyLoadingMaskType.black
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false; // PERBAIKAN 9: Tambahkan ini
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();
  final MethodChannel platform =
      MethodChannel('crossingthestreams.io/resourceResolver');
  bool _modalOpened = false;
  bool _firebaseInitialized = false;

  Future<void> _initFirebase(BuildContext context) async {
    if (_firebaseInitialized) return;

    try {
      await setupFirebaseMessaging(context);
      setState(() => _firebaseInitialized = true); // PERBAIKAN 10: Set state
      debugPrint("Firebase messaging setup completed");
    } catch (e) {
      debugPrint("Firebase messaging setup error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // _requestIOSPermissions();

    // PERBAIKAN 11: Better delayed initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && navigatorKey.currentContext != null) {
        ConnectivityUtils.distance.onCheckConnectivity(
          navigatorKey.currentContext!,
        );
        _initFirebase(navigatorKey.currentContext!);
      }
    });
  }

  // void _requestIOSPermissions() {
  //   // PERBAIKAN 12: Tambah platform check
  //   if (Platform.isIOS) {
  //     flutterLocalNotificationsPlugin
  //         .resolvePlatformSpecificImplementation
  //             IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
  //           alert: true,
  //           badge: true,
  //           sound: true,
  //         );
  //   }
  // }

  void _checkLocation() async {
    // PERBAIKAN 13: Better null check
    if (navigatorKey.currentContext == null) return;

    bool location = await LocationUtils.instance.getLocationOnly();

    if (!_modalOpened && !location && mounted) {
      _modalOpened = true;

      showModal(
        context: navigatorKey.currentContext!,
        configuration:
            FadeScaleTransitionConfiguration(barrierDismissible: false),
        builder: (context) {
          return InfoDialog(
            title: "Opps...",
            text:
                "Pastikan Anda mengizinkan $mobileName untuk mengakses lokasi Anda.",
            clickOKText: "OK",
            onClickOK: () async {
              Navigator.of(context, rootNavigator: true).pop();

              location = await LocationUtils.instance.getLocationOnly();
              if (!location) {
                AppSettings.openAppSettings();
              }
            },
            isCancel: false,
          );
        },
      ).then((value) {
        if (mounted) {
          setState(() => _modalOpened = false); // PERBAIKAN 14: Set state
        }
      });
    }
  }

  @override
  void dispose() {
    // PERBAIKAN 15: Bersihkan resources jika ada
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ProdukTabunganProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProdukCollectionProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => GlobalProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => TransaksiProvider(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: config.companyName,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
            accentColor: accentColor,
            backgroundColor: Colors.white,
            cardColor: Colors.white,
          ).copyWith(
            secondary: accentColor,
            surface: Colors.white,
            surfaceTint: Colors.white,
          ),
          primaryColor: primaryColor,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          scaffoldBackgroundColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: SharedAxisPageTransitionsBuilder(
                transitionType: SharedAxisTransitionType.horizontal,
              ),
              TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
                transitionType: SharedAxisTransitionType.horizontal,
              ),
            },
          ),
        ),
        builder: (BuildContext context, Widget? child) {
          return FlutterEasyLoading(
            child: GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              child: Listener(
                onPointerUp: (PointerEvent details) => _checkLocation(),
                child: child,
              ),
            ),
          );
        },
        initialRoute: RouterGenerator.pageSplash,
        onGenerateRoute: RouterGenerator.generateRoute,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('id', 'ID'),
        ],
      ),
    );
  }
}
