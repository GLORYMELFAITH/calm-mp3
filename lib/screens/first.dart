import 'package:calm_mp3/screens/home.dart';
import "package:flutter/material.dart";
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class First extends StatefulWidget {
  
  @override
  State<First> createState() => _FirstState();
}

class _FirstState extends State<First> {
  Color colorA1 = Color.fromARGB(96, 104, 58, 183);
  Color colorA2 = Color.fromARGB(255, 59, 0, 70);
  Color colorB1 = Color.fromARGB(95, 58, 77, 183);
  Color colorB2 = Color.fromARGB(255, 0, 11, 70);
  Color colorC1 = Color.fromARGB(95, 58, 183, 183);
  Color colorC2 = Color.fromARGB(255, 0, 70, 70);
  Color colorD1 = Color.fromARGB(95, 98, 183, 58);
  Color colorD2 = Color.fromARGB(255, 0, 70, 4);
  Color colorE1 = Color.fromARGB(255, 33, 33, 33);
  Color colorE2 = Color.fromARGB(255, 19, 19, 19);
  late Color color1 = Color.fromARGB(96, 104, 58, 183);
  late Color color2 = Color.fromARGB(255, 59, 0, 70);
  bool isColorSet = false;
  void nextPage(context){
  
  Future.delayed(const Duration(seconds: 4),(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(color1, color2)),
    );
    });
  }

  void setColor(String color){
    if(color == 'a'){
      color1 = colorA1;
      color2 = colorA2; 
    }else if(color == 'b'){
      color1 = colorB1;
      color2 = colorB2; 
    }else if(color == 'c'){
      color1 = colorC1;
      color2 = colorC2; 
    }else if(color == 'd'){
      color1 = colorD1;
      color2 = colorD2;
    }else{
      color1 = colorE1;
      color2 = colorE2;
    }
    isColorSet =  true;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color2,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Visibility(
              visible: isColorSet,
              replacement: Container(
                height: 270,
                width: 300,
                decoration: BoxDecoration(
                  color: colorE1,
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Column(
                  children: [
                    Text('Select theme',style: GoogleFonts.poppins(fontSize: 20),),
                    Container(
                      child: TextButton.icon(
                        onPressed: (){
                          setColor('a');
                          nextPage(context);
                        },
                        icon: Icon(Icons.color_lens, color: colorA2,),
                        label: Text('Purple',style: GoogleFonts.poppins(color: Colors.white)),
                      ),
                    ),
                    Container(
                      child: TextButton.icon(
                        onPressed: (){
                          setColor('b');
                          nextPage(context);
                        },
                        icon: Icon(Icons.color_lens, color: colorB2,),
                        label: Text('Blue',style: GoogleFonts.poppins(color: Colors.white)),
                      ),
                    ),
                    Container(
                      child: TextButton.icon(
                        onPressed: (){
                          setColor('c');
                          nextPage(context);
                        },
                        icon: Icon(Icons.color_lens, color: colorC2,),
                        label: Text('Blue Green',style: GoogleFonts.poppins(color: Colors.white)),
                      ),
                    ),
                    Container(
                      child: TextButton.icon(
                        onPressed: (){
                          setColor('d');
                          nextPage(context);
                        },
                        icon: Icon(Icons.color_lens, color: colorD2,),
                        label: Text('Green',style: GoogleFonts.poppins(color: Colors.white)),
                      ),
                    ),
                    Container(
                      child: TextButton.icon(
                        onPressed: (){
                          setColor('asf');
                          nextPage(context);
                        },
                        icon: Icon(Icons.color_lens, color: colorE2,),
                        label: Text('Black',style: GoogleFonts.poppins(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              child: SizedBox(
                height: 270,
                child: SpinKitFadingCube(
                  size: 70,
                  color: Colors.white24,
                ),
              ),
            ),
            SizedBox(height: 50,),
            Text('Calm mp3', style: GoogleFonts.poppins(fontSize: 40)),
          ],
        ),
      )
    );
  }
}