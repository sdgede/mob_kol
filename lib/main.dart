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
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/foundation.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('Handling background message: ${message.messageId}');

    if (message.notification != null) {
      debugPrint('Background Notification: ${message.notification?.title}');
    }
  } catch (e, stackTrace) {
    // ✅ Capture error ke Sentry
    await Sentry.captureException(
      e,
      stackTrace: stackTrace,
      hint: Hint.withMap({
        'handler': 'firebaseMessagingBackgroundHandler',
        'messageId': message.messageId,
      }),
    );
    debugPrint('Background handler error: $e');
  }
}

// ✅ PERBAIKAN SENTRY 2: Setup Firebase Messaging dengan error handling lengkap
Future<void> setupFirebaseMessaging(BuildContext context) async {
  try {
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

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        try {
          debugPrint('Got a message whilst in the foreground!');
          debugPrint('Message data: ${message.data}');

          if (message.notification != null) {
            debugPrint(
                'Message contained notification: ${message.notification}');

            NotificationUtils.instance.showNotification(
              context,
              message.notification?.title ?? "",
              message.notification?.body ?? "",
            );
          }
        } catch (e, stackTrace) {
          // ✅ Capture error saat handle foreground message
          Sentry.captureException(
            e,
            stackTrace: stackTrace,
            hint: Hint.withMap({
              'handler': 'onMessage',
              'messageId': message.messageId,
            }),
          );
        }
      },
      onError: (error) {
        Sentry.captureException(
          error,
          hint: Hint.withMap({'handler': 'onMessage.stream'}),
        );
      },
    );

    // Handle notifikasi yang di-tap
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        try {
          debugPrint('A new onMessageOpenedApp event was published!');
          // Handle navigation atau action
        } catch (e, stackTrace) {
          Sentry.captureException(
            e,
            stackTrace: stackTrace,
            hint: Hint.withMap({
              'handler': 'onMessageOpenedApp',
              'messageId': message.messageId,
            }),
          );
        }
      },
      onError: (error) {
        Sentry.captureException(
          error,
          hint: Hint.withMap({'handler': 'onMessageOpenedApp.stream'}),
        );
      },
    );

    // Get FCM token
    try {
      String? token = await messaging.getToken();
      if (token != null) {
        debugPrint("FCM Token: $token");

        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? savedToken = prefs.getString("firebase_id");

        if (savedToken == null || savedToken.isEmpty || savedToken != token) {
          await prefs.setString('firebase_id', token);
          debugPrint("FCM Token saved to SharedPreferences");
        }

        config.firebaseId = token;
        config.platform = await PlatformUtils.distance.initPlatformState();
      } else {
        debugPrint("FCM Token: failed to get token");
        Sentry.captureMessage(
          'FCM Token is null',
          level: SentryLevel.warning,
        );
      }
    } catch (e, stackTrace) {
      debugPrint("FCM Token error: $e");
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        hint: Hint.withMap({'action': 'getToken'}),
      );
    }

    // Listen untuk token refresh
    messaging.onTokenRefresh.listen(
      (newToken) async {
        try {
          debugPrint("FCM Token refreshed: $newToken");
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('firebase_id', newToken);
          config.firebaseId = newToken;
        } catch (e, stackTrace) {
          Sentry.captureException(
            e,
            stackTrace: stackTrace,
            hint: Hint.withMap({'handler': 'onTokenRefresh'}),
          );
        }
      },
      onError: (error) {
        Sentry.captureException(
          error,
          hint: Hint.withMap({'handler': 'onTokenRefresh.stream'}),
        );
      },
    );
  } catch (e, stackTrace) {
    debugPrint("Firebase messaging setup error: $e");
    await Sentry.captureException(
      e,
      stackTrace: stackTrace,
      hint: Hint.withMap({'function': 'setupFirebaseMessaging'}),
    );
    rethrow; // Optional: lempar ulang jika perlu
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://f8c977317cc302845a146e3cd9985a08@o4510751443255296.ingest.de.sentry.io/4510751444566096';

      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;

      options.environment = kReleaseMode ? 'production' : 'development';

      options.release = 'sevanam_mobkol@1.0.0';
      options.beforeSend = (event, hint) {
        // Filter error spesifik jika perlu
        if (event.message?.formatted.contains('Some ignorable error') == true) {
          return null; // Tidak kirim ke Sentry
        }
        return event;
      };

      options.maxBreadcrumbs = 100;
    },
    appRunner: () async {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
          hint: Hint.withMap({'init': 'Firebase'}),
        );
      }

      try {
        await dotenv.load(fileName: ".env");
      } catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
          hint: Hint.withMap({'init': 'dotenv'}),
        );
      }

      try {
        setupApp();
      } catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
          hint: Hint.withMap({'init': 'setupApp'}),
        );
      }

      configLoading();
      runApp(SentryWidget(child: MyApp()));
    },
  );
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
    ..dismissOnTap = false;
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
      setState(() => _firebaseInitialized = true);
      debugPrint("Firebase messaging setup completed");
    } catch (e, stackTrace) {
      debugPrint("Firebase messaging setup error: $e");
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        hint: Hint.withMap({'function': '_initFirebase'}),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (mounted && navigatorKey.currentContext != null) {
          ConnectivityUtils.distance.onCheckConnectivity(
            navigatorKey.currentContext!,
          );
          await _initFirebase(navigatorKey.currentContext!);
        }
      } catch (e, stackTrace) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          hint: Hint.withMap({'callback': 'addPostFrameCallback'}),
        );
      }
    });
  }

  void _checkLocation() async {
    try {
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
            setState(() => _modalOpened = false);
          }
        });
      }
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        hint: Hint.withMap({'function': '_checkLocation'}),
      );
    }
  }

  @override
  void dispose() {
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
