// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:calm_mp3/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPass = TextEditingController();
  var prompt = '';
  Color bg = Color.fromARGB(255, 59, 0, 70);
  Color color = Colors.red;

  Future signUp() async{
    setState(() {
      color = Colors.green;
      prompt = 'loading';
    });
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      setState(() {
        color = Colors.green;
        prompt = 'Account created successfully please wait';
      });
      await Future.delayed(const Duration(seconds: 1),(){
        Navigator.pop(context);  
      });
    } on FirebaseAuthException catch (e){
      color = Colors.red;
      var a = e.toString();
      prompt = a;
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: bg,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget> [
                Text('Calm mp3',style: GoogleFonts.poppins(fontSize: 40),),
                Padding(padding: EdgeInsets.all(5)),
                Text(prompt, style: GoogleFonts.poppins(color: color ,fontSize: 15),),
                Padding(padding: EdgeInsets.all(5)),
                Text('Email',style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
                Text('Password',style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: 'Enter your password',
                      hintStyle: GoogleFonts.poppins(),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(5)),
                Text(' Confirm password',style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
                    controller: confirmPass,
                    cursorColor: Colors.white,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: 'Enter your password',
                      hintStyle: GoogleFonts.poppins(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    setState((){
                      if (passwordController.text == confirmPass.text) {
                        signUp();
                      }
                      else{
                        prompt = "Password not matched";
                      }
                    });
                  },
                  child: Text('Sign up',style: GoogleFonts.poppins(fontSize: 20),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}