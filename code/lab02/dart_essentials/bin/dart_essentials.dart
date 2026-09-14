import 'package:dart_essentials/dart_essentials.dart';

// main điều phối và in kết quả của cả năm exercise Lab 2 theo thứ tự.
Future<void> main() async {
  print('Exercise 1 - Basic syntax: ${basicSyntaxSummary()}');
  print('Exercise 2 - Collections: ${collectionsSummary()}');
  print('Exercise 3 - Control flow: ${controlFlowSummary(80)}');

  final car = Car('Toyota');
  final electricCar = ElectricCar('Tesla');
  print('Exercise 4 - OOP: ${car.start()}; ${electricCar.start()}');

  final students = await loadStudents();
  print('Exercise 5 - Async students: $students');
  final streamValues = await numberStream().toList();
  print('Exercise 5 - Stream values: $streamValues');
}
