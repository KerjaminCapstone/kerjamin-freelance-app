import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kerjamin_fr/screens/all_screens.dart';
import 'package:kerjamin_fr/screens/arrange_page.dart';
import 'package:kerjamin_fr/screens/ongoing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var pr = await SharedPreferences.getInstance();
  var tokenSp = pr.getString("token") ?? "";

  runApp(MyApp(
    token: tokenSp,
  ));
}

class MyApp extends StatelessWidget {
  final String? token;

  MyApp({this.token});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KerjaminFrApp',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.deepOrange,
          textTheme: GoogleFonts.latoTextTheme()),
      routes: {
        'login-page': (context) => LoginPage(),
        'ongoing-page': (context) => OngoingPage(),
        'arrangement-page': (context) => ArrangePage(),
      },
      initialRoute: token == "" ? 'login-page' : 'ongoing-page',
      debugShowCheckedModeBanner: false,
    );
  }
}
