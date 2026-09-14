import 'package:flutter/material.dart';

// Hàm main là điểm bắt đầu của ứng dụng Flutter.
// Nó gọi runApp để gắn widget gốc MyApp vào Flutter framework.
void main() => runApp(const MyApp());

// MyApp là widget gốc, đại diện cho toàn bộ giao diện của ứng dụng Lab 1.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // build tạo cây widget gồm MaterialApp, Scaffold, AppBar, nội dung và FAB.
  // Flutter gọi lại hàm này khi cần dựng hoặc cập nhật giao diện.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Lab 1 Demo'),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flutter_dash, size: 80, color: Colors.deepPurple),
              SizedBox(height: 20),
              Text(
                'Welcome to Flutter!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Your first customized layout 😊',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: null,
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
