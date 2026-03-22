// main.dart

import 'package:assurappci/Repositories/Annonces.dart';
import 'package:assurappci/Repositories/AssuranceRepository.dart';
import 'package:assurappci/Repositories/AuthRepository.dart';
import 'package:assurappci/Repositories/NewsLetterRepository.dart';
import 'package:assurappci/Repositories/NotificationsRespository.dart';
import 'package:assurappci/Repositories/PharmacieRespository.dart';
import 'package:assurappci/Services/fcm_service.dart'; // ✅ Import FCMService
import 'package:assurappci/Services/notifications_service.dart';
import 'package:assurappci/Utils/SplashScreen.dart';
import 'package:assurappci/ViewModels/AnnoncesViewModel.dart';
import 'package:assurappci/ViewModels/AssuranceViewModel.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:assurappci/ViewModels/NewsletterViewModel.dart';
import 'package:assurappci/ViewModels/NotificationsViewModel.dart';
import 'package:assurappci/ViewModels/PharmacieViewModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// ✅ Handler background (DOIT être top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();

  print('📬 Message background');
  print('Titre: ${message.notification?.title}');

  if (message.notification != null) {
    await NotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: message.notification!.title ?? 'Notification',
      body: message.notification!.body ?? '',
      payload: message.data.toString(), // ✅ Passer les données
    );
  }
}

Future<void> setup() async {
  await dotenv.load(fileName: ".env");
  MapboxOptions.setAccessToken(dotenv.env["MAPBOX_ACCESS_TOKEN"]!);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setup();
  // ✅ 1. Initialiser Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ 2. Initialiser NotificationService
  await NotificationService.initialize();

  // ✅ 3. Enregistrer le handler background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ 4. Initialiser FCM
  await FCMService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: ScreenUtil.defaultSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => AuthViewModel(Authrepository()),
            ),
            ChangeNotifierProvider(
              create: (context) => AssuranceViewModel(AssuranceRepository()),
            ),
            ChangeNotifierProvider(
              create: (context) => PharmacieViewModel(Pharmacierespository()),
            ),
            ChangeNotifierProvider(
              create: (context) => Newsletterviewmodel(NewsletterRepository()),
            ),
            ChangeNotifierProvider(
              create: (context) =>
                  Notificationsviewmodel(NotificationsRepository()),
            ),
            ChangeNotifierProvider(
              create: (context) => Annoncesviewmodel(AnnoncesRepository()),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Splashscreen(),
          ),
        );
      },
    );
  }
}
