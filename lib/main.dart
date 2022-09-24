import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch_in/models/app_user.dart';
import 'package:punch_in/wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AppUser user = AppUser('', '', '', '', UserStatus.loggedOut);
    return MaterialApp(
        title: 'PunchIn',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            appBarTheme: const AppBarTheme(
              elevation: 0.0,
              titleTextStyle: TextStyle(color: Colors.black),
              iconTheme: IconThemeData(color: Color(0xff695cff),)
            ),
            primarySwatch: Colors.blue,
            primaryColorLight: Colors.lightBlue[100],
            primaryColor: Colors.lightBlue[400],
            primaryColorDark: Colors.lightBlue[900],
            backgroundColor: Colors.lightBlueAccent[50],
            progressIndicatorTheme: ProgressIndicatorThemeData(
              color: const Color(0xff695cff),
              circularTrackColor: const Color(0xff695cff).withOpacity(.1),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
                style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              backgroundColor: MaterialStateProperty.all(const Color(0xff695cff)),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
            )),
            inputDecorationTheme: InputDecorationTheme(
              prefixIconColor: const Color(0xff695cff),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Color(0xff695cff))),
              labelStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),
              floatingLabelStyle: const TextStyle(
                  color: Color(0xff695cff),
                  fontWeight: FontWeight.bold
              ),
            )
        ),
        home: ChangeNotifierProvider<AppUser>(
          create: (_) => user,
          builder: (__, _) => Wrapper(user: user),
        ));
  }
}
