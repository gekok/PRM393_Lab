// Khung tự làm — chép đề từ DE_BAI.md rồi điền từng TODO.
// Chạy: dart run code/practice/practice_todo.dart
// Đáp án: code/practice/practice_solution.dart
import 'dart:async';

// Bài 1 — Lab 2: trả về 'age=20, gpa=3.75, campus=FPT HCM, passed=true'.
String basicSyntaxSummary() {
  const age=20;
  const gpa= 3.75;
  const campus= 'FPT HCM';
  const passed= true;
  return 'age=$age, gpa=$gpa, campus=$campus, passed=$passed';
}

// Bài 1 — Lab 2: [1,2,3] add(4) remove(1) -> [2,3,4]; set loại trùng; sum = 9.
Map<String, dynamic> collectionsSummary() {
  final arA=[1,2,3];
  final arB= <int>[1,2,2,3,4];
  arA.add(4);arA.remove(1);
  final setB= arB.toSet();
  final user= {'id':1,'name':'Phúc'};
  return{
    'array': arA,
    'set':arB,
    'username':user['name'],
    'sum': arA.reduce((a,b)=>a+b),
  };
}

// Bài 1 — Lab 2: 80 -> 'Pass - Even score'.
String controlFlowSummary(int score) {
  final result=score>=50?'Pass':'Fail';
  final day= switch (score%2){
    0=>'Even score',
    _=>'Odd score',
  };
  return '$result - $day';
}

// Bài 2 — Lab 1.1: Vehicle + Car xăng/điện + Car.tesla.
class Vehicle {
  // TODO: brand, year, startEngine().
  Vehicle(this.brand, this.year);
  final String brand;
  final int year;
  void startEngine() {
    print('Khởi động phương tiện...');
  }
}

class FuelCar extends Vehicle {
  // TODO: isElectric, super, Car.tesla, @override startEngine().
  final bool isElectric;
  FuelCar(String brand, int year, this.isElectric) : super(brand, year);
}

// Bài 3 — Lab 1.2: abstract + mixin + spread.
abstract class Employee {
  String name;
  Employee(this.name);
  void work();
}

// TODO: mixin CheckInAbility on Employee, class Developer with CheckInAbility.
// TODO: gộp [...teamA, ...teamB] rồi for gọi checkIn().

// Bài 4 — Lab 1.6: String? + as String? ?? + email ??.
class NullSafeUser {
  // TODO: id, name, String? email, factory fromJson, showProfile().
  NullSafeUser({required int id, required String name, String? email});
}

// Bài 5+6 — Lab 2 Ex5 + Lab 3: Future, Stream, repo, microtask, singleton.
// TODO: loadStudents, numberStream (async* + yield), evenSquares (map + where).
// TODO: ProductRepository (broadcast + dispose), microtaskOrder, Settings().

Future<void> main() async {
  // TODO: gọi từng hàm trên rồi in kết quả, so với practice_solution.dart.
  print('Điền từng TODO rồi chạy lại file này.');
}
