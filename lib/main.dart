import 'package:assurappci/Repositories/AssuranceRepository.dart';
import 'package:assurappci/Repositories/AuthRepository.dart';
import 'package:assurappci/Repositories/NewsLetterRepository.dart';
import 'package:assurappci/Repositories/PharmacieRespository.dart';
import 'package:assurappci/Utils/SplashScreen.dart';
import 'package:assurappci/ViewModels/AssuranceViewModel.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:assurappci/ViewModels/NewsletterViewModel.dart';
import 'package:assurappci/ViewModels/PharmacieViewModel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 915),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child){
        return MultiProvider(providers: [
          ChangeNotifierProvider(create: (context)=>AuthViewModel(Authrepository())),
          ChangeNotifierProvider(create: (context)=>AssuranceViewModel(AssuranceRepository())),
          ChangeNotifierProvider(create: (context)=>PharmacieViewModel(Pharmacierespository())),
          ChangeNotifierProvider(create: (context) => Newsletterviewmodel(Newsletterrepository())), // ← ici
        ],child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Splashscreen(),
        ),);
      },
    );
  }
}
