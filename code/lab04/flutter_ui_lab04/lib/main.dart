import 'package:flutter/material.dart';
import 'core_widgets_demo.dart';
import 'input_controls_demo.dart';
import 'layout_basics_demo.dart';
import 'app_structure_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
  //công tắc Dark Mode của cả app
  // false là sáng, true là tối
  bool _isDark=false;

  //Hàm cho bài 4 mượn để gạt công tắc từ xa
  void _setDark(bool newValue){
    setState(() {
      _isDark=newValue;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //theme sáng dùng màu gốc tím
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      //công tắc chọn theme
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: AppStructureDemo(
        isDark: _isDark,
        onThemeChanged: _setDark,
      ),
    );
  }
}
