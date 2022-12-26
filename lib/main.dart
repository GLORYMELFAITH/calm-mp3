import 'package:calm_mp3/screens/first.dart';
import 'package:calm_mp3/screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


Future main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(
        useMaterial3: true, 
      ),
      home: MainPage(),
    );
  }
}
class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    	body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }
          else if(snapshot.hasError){
            return const Center(child: Text('something went wrong!'));
          }
          else if (snapshot.hasData) {
            return First();
          }else{
            return const LoginPage();
          }
        }
      ),
  );
}