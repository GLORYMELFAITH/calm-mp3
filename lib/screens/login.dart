// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:calm_mp3/main.dart';
import 'package:calm_mp3/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key,}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String prompt = '';
  String name = '';
  Color bg = Color.fromARGB(255, 59, 0, 70);

  Future signIn() async{
    setState(() {
      prompt = 'loading';
    });
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      navigatorKey.currentState!.popUntil((route)=>route.isFirst);  
    } on FirebaseAuthException catch (e){
      setState(() {
        prompt = e.toString();
      });
    }
  }
  @override
  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget> [
                Text('Calm mp3',style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold, ),),
                Padding(padding: EdgeInsets.all(5)),
                Text('Welcome! Log in here',style: GoogleFonts.poppins(fontSize: 18,),),
                Padding(padding: EdgeInsets.all(20)),
                Text(prompt,style: GoogleFonts.poppins(fontSize: 15,color: Colors.red,),),
                Padding(padding: EdgeInsets.all(5)),
                Text(' Email',style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                Padding(padding: EdgeInsets.all(5)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  height: 50,
                  child: TextField(
                    onChanged: (String value) async {
                      setState(() {
                        prompt = '';
                      });
                    },
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    cursorColor: Colors.white,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: 'Enter your email',
                      hintStyle: GoogleFonts.poppins(),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(5)),
                Text(' Password',style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                Padding(padding: EdgeInsets.all(5)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  height: 50,
                  child: TextField(
                    onChanged: (String value) async {
                      setState(() {
                        prompt = '';
                      });
                    },
                    obscureText: true,
                    controller: passwordController,
                    cursorColor: Colors.white,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: GoogleFonts.poppins(),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(10)),
                GestureDetector(
                  onTap:  (){
                    setState(() {
                      if(emailController.text.isEmpty || passwordController.text.isEmpty){
                        prompt = 'Invalid email/password';
                        return;
                      }
                    signIn();
                    });
                  },
                  child: SizedBox(
                    child: Text('Log in',style: GoogleFonts.poppins(fontSize: 20)),
                  ),
                ),
                Padding(padding: EdgeInsets.all(5)),
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: Duration(milliseconds: 500),
                        transitionsBuilder: (BuildContext context,Animation<double> animation, Animation<double> secAnimation, Widget child){
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(2, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                        pageBuilder: (BuildContext context,Animation<double> animation, Animation<double> secAnimation){
                          return SignUpPage();
                        }
                      )
                    );
                  },
                  child: SizedBox(
                    child: Text('Sign up',style: GoogleFonts.poppins(fontSize: 20)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}