/*

MAIN

Why we don't use 'home' parameter inside of the MaterialApp?
Because after the deletion of the account, we want to navigate the app to its
initial route, which is the AuthGate(). If we are using 'home: AuthGate()', when
we delete the account, it will not going to revert back to the login page.

*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_app/services/auth/auth_gate.dart';
import 'package:twitter_clone_app/services/database/database_provider.dart';
import 'package:twitter_clone_app/themes/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // run app
  runApp(
    MultiProvider(
      providers: [
        // theme provider
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),

        // database provider
        ChangeNotifierProvider(
          create: (context) => DatabaseProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {'/': (context) => const AuthGate()},
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
