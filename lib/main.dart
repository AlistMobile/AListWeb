import 'dart:io';

import 'package:alist_web/init.dart';
import 'package:alist_web/pages/homePage.dart';
import 'package:alist_web/pages/login.dart';
import 'package:alist_web/pages/web/web.dart';
import 'package:alist_web/pages/splash/splashImagePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/generated/alistweb_localizations.dart';
import 'model/custom_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  init();
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CustomTheme()),
      ],
      child: const MyApp()
  ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AListWeb',
      // themeMode: ThemeMode.system,
      theme: CustomThemes.light,
      darkTheme: CustomThemes.dark,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        AListWebLocalizations.delegate,
      ],
      supportedLocales: AListWebLocalizations.supportedLocales,
      localeListResolutionCallback: (locales, supportedLocales) {
        print("locales:$locales");
        return;
      },
      // home: const WebScreen(),
      // home: Platform.isMacOS?SplashImagePage():WebScreen(),
      // home: HomePage(),
      home: LoginPage(),
    );
  }
}
