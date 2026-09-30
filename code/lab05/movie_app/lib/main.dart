import 'package:flutter/material.dart';
import 'home_screen.dart';

//của vào của mọi app
void main(){
  runApp(const MovieApp());
}

//Widget gốc của lab5
//dùng StatelessWidget vì gốc không cần nhớ thêm
class MovieApp extends StatelessWidget{
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prm393 lab 5 Movie App',
      //theme dùng màu gốc tím, bất Material3
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}