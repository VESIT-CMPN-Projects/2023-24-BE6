import 'package:deliveryx/provider/senderProvider.dart';
import 'package:deliveryx/services/mongodb.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:deliveryx/themeProvider/theme_Provider.dart';
import 'package:get/get.dart';
import 'Users/Users_screen/eventlogger.dart';
import 'firebase_options.dart';
import 'dependency_injection.dart';
import 'Users/Splash_screen/splash_screen.dart';
import 'package:logger/logger.dart';
import 'package:mongo_dart/mongo_dart.dart';

final Logger logger = Logger(
  printer: PrettyPrinter(), // You can configure the output format here
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDatabase.connect();
  await EventLogger.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  DependencyInjection.init();

  runApp(
    ChangeNotifierProvider(
      create: (context) => SenderProvider(),
      child: const MyApp(),
    ),
  );
  DependencyInjection.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DeliveryX',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      home: const SplashScreen(),
    );
  }
}
