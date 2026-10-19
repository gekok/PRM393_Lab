import 'dart:async';
import 'dart:convert';

// Đáp án mẫu — bao phủ lab2, lab3, lab1.1, lab1.2, lab1.6.
// Chạy: dart run code/practice/practice_solution.dart

// ---------- Lab 2 Ex1: cú pháp lõi ----------
// WHAT: gom const + nội suy chuỗi thành một chuỗi tổng hợp.
// WHY: một chỗ duy nhất để đối chiếu output khi ôn.
String basicSyntaxSummary() {
  const age = 20;
  const gpa = 3.75;
  const campus = 'FPT HCM';
  const passed = true;
  return 'age=$age, gpa=$gpa, campus=$campus, passed=$passed';
}

// ---------- Lab 2 Ex2: List / Set / Map ----------
// WHAT: add rồi remove để thấy list đổi ra sao.
// WHY: thi hay hỏi đoán list cuối + tổng reduce.
Map<String, dynamic> collectionsSummary() {
  final numbers = [1, 2, 3];
  final rawNumbers = <int>[1, 2, 2, 3];
  final uniqueNumbers = rawNumbers.toSet(); // Set tự loại số 2 trùng.
  final user = {'id': 1, 'name': 'Nam'};
  numbers.add(4); // [1, 2, 3, 4]
  numbers.remove(1); // [2, 3, 4]
  return {
    'numbers': numbers,
    'uniqueNumbers': uniqueNumbers,
    'userName': user['name'],
    'sum': numbers.reduce((a, b) => a + b), // 2+3+4 = 9.
  };
}

// ---------- Lab 2 Ex3: ternary + switch biểu thức ----------
// WHAT: phân loại điểm bằng ?: và switch mới.
// WHY: cú pháp switch mới hay ra thi vì khác Dart cũ.
String controlFlowSummary(int score) {
  final result = score >= 50 ? 'Pass' : 'Fail';
  final day = switch (score % 2) {
    0 => 'Even score',
    _ => 'Odd score',
  };
  return '$result - $day';
}

// ---------- Lab 2 Ex4: kế thừa cơ bản ----------
// WHAT: lớp cha + lớp con ghi đè start().
// WHY: mẫu nhỏ nhất để nhớ extends + super + @override.
class BasicCar {
  final String brand;
  BasicCar(this.brand);
  String start() => '$brand started';
}

class BasicElectricCar extends BasicCar {
  BasicElectricCar(super.brand);
  @override
  String start() => '$brand started silently';
}

// ---------- Lab 1.1: Vehicle + named constructor ----------
// WHAT: Car xăng/điện + Car.tesla luôn là điện.
// WHY: nhớ cách super gửi brand/year lên cha.
class Vehicle {
  final String brand;
  final int year;
  Vehicle(this.brand, this.year);
  void startEngine() {
    print('Khởi động phương tiện...');
  }
}

class FuelCar extends Vehicle {
  final bool isElectric;
  FuelCar(String brand, int year, this.isElectric) : super(brand, year);

  // Named constructor: Tesla mặc định điện, chỉ cần truyền year.
  FuelCar.tesla(int year) : isElectric = true, super('Tesla', year);

  @override
  void startEngine() {
    if (isElectric) {
      print('$brand Khởi động bằng động cơ điện');
    } else {
      print('$brand khởi động bằng động cơ xăng');
    }
  }
}

// ---------- Lab 1.2: abstract + mixin + spread ----------
// WHAT: khả năng điểm danh gắn thêm cho Employee.
// WHY: phân biệt extends (cha con) với with (gắn khả năng).
abstract class Employee {
  String name;
  Employee(this.name);
  void work();
}

// on Employee: chỉ Employee mới được with mixin này.
mixin CheckInAbility on Employee {
  void checkIn() {
    print('$name đã điểm danh');
  }
}

class Developer extends Employee with CheckInAbility {
  Developer(String name) : super(name);
  @override
  void work() => print('$name đang viết code.');
}

// ---------- Lab 1.6: null safety + factory từ JSON ----------
// WHAT: email nullable, name fallback "Khách".
// WHY: JSON API thiếu field thì app vẫn sống, không crash.
class NullSafeUser {
  int id;
  String name;
  String? email; // Dấu ? cho phép giữ null.
  NullSafeUser({required this.id, required this.name, this.email});

  factory NullSafeUser.fromJson(Map<String, dynamic> json) {
    return NullSafeUser(
      id: json['id'] as int,
      // Ép mềm as String? rồi ?? để null thành "Khách".
      name: json['name'] as String? ?? 'Khách',
      email: json['email'] as String?,
    );
  }

  void showProfile() {
    print('ID: $id | Tên: $name | Email: ${email ?? 'Chưa cập nhật'}');
  }
}

// ---------- Lab 3: Product + broadcast stream ----------
// WHAT: repo giữ list + phát event sản phẩm mới.
// WHY: mẫu broadcast nhiều listener + nhớ dispose để khỏi rò.
class Product {
  final int id;
  final String name;
  final double price;
  Product({required this.id, required this.name, required this.price});
  @override
  String toString() => '$name (\$${price.toStringAsFixed(2)})';
}

class ProductRepository {
  final List<Product> _products = [
    Product(id: 1, name: 'Keyboard', price: 25.0),
    Product(id: 2, name: 'Mouse', price: 15.5),
  ];
  final StreamController<Product> _addedController =
      StreamController<Product>.broadcast();

  Future<List<Product>> getAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return List.unmodifiable(_products);
  }

  Stream<Product> liveAdded() => _addedController.stream;

  void add(Product product) {
    _products.add(product);
    _addedController.add(product);
  }

  Future<void> dispose() => _addedController.close();
}

// ---------- Lab 3 Ex2: parse JSON thành model ----------
// WHAT: decode chuỗi JSON rồi map từng item thành User.
// WHY: bản này dùng as String strict nên thiếu field là crash.
class JsonUser {
  final String name;
  final String email;
  JsonUser({required this.name, required this.email});
  factory JsonUser.fromJson(Map<String, dynamic> json) {
    return JsonUser(name: json['name'] as String, email: json['email'] as String);
  }
  @override
  String toString() => '$name <$email>';
}

Future<List<JsonUser>> fetchUsersFromJson() async {
  const rawJson = '[{"name":"An","email":"an@example.com"},'
      '{"name":"Binh","email":"binh@example.com"}]';
  final decoded = jsonDecode(rawJson) as List<dynamic>;
  return decoded
      .map((item) => JsonUser.fromJson(item as Map<String, dynamic>))
      .toList();
}

// ---------- Lab 3 Ex3: thứ tự microtask vs event ----------
// WHAT: ghi lại A, B, microtask, event chạy theo thứ tự nào.
// WHY: thi hay hỏi đoán output hàng đợi Dart.
Future<List<String>> microtaskOrder() async {
  final events = <String>[];
  final completer = Completer<List<String>>();
  events.add('A');
  scheduleMicrotask(() => events.add('microtask'));
  Future<void>(() {
    events.add('event');
    completer.complete(events);
  });
  events.add('B');
  return completer.future;
}

// ---------- Lab 2 Ex5 + Lab 3 Ex4: Future và Stream ----------
// WHAT: một Future trả list, một Stream phát từng số.
// WHY: nhớ Future = 1 giá trị sau này, Stream = nhiều giá trị.
Future<List<String>> loadStudents() async {
  await Future<void>.delayed(const Duration(milliseconds: 10));
  return ['An', 'Binh'];
}

Stream<int> numberStream() async* {
  for (var number = 1; number <= 3; number++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    yield number; // Phát từng số rồi nghỉ, không chặn.
  }
}

// Bình phương rồi chỉ giữ số chẵn: [1..5] -> [4, 16].
Stream<int> evenSquares() => Stream.fromIterable([1, 2, 3, 4, 5])
    .map((number) => number * number)
    .where((number) => number.isEven);

// ---------- Lab 3 Ex5: factory singleton ----------
// WHAT: mọi lần gọi Settings() đều cùng một instance.
// WHY: factory có thể trả instance cũ thay vì tạo mới.
class Settings {
  static final Settings _instance = Settings._();
  Settings._();
  factory Settings() => _instance;
  String theme = 'light';
}

Future<void> main() async {
  print('--- Lab2 Ex1 --- ${basicSyntaxSummary()}');
  print('--- Lab2 Ex2 --- ${collectionsSummary()}');
  print('--- Lab2 Ex3 (80) --- ${controlFlowSummary(80)}');
  print('--- Lab2 Ex4 --- ${BasicCar('Toyota').start()}; '
      '${BasicElectricCar('Tesla').start()}');

  print('--- Lab1.1 ---');
  FuelCar('Toyota', 2020, false).startEngine();
  FuelCar.tesla(2024).startEngine();

  print('--- Lab1.2 ---');
  final teamA = [Developer('An'), Developer('Bình')];
  final teamB = [Developer('Cường')];
  final allStaff = [...teamA, ...teamB]; // Spread gộp 2 team.
  for (final employee in allStaff) {
    employee.checkIn();
  }

  print('--- Lab1.6 ---');
  NullSafeUser.fromJson(
    {'id': 1, 'name': 'Nam', 'email': 'nam@fpt.edu.vn'},
  ).showProfile();
  NullSafeUser.fromJson({'id': 2, 'name': null, 'email': null}).showProfile();

  print('--- Lab3 Ex1 ---');
  final repository = ProductRepository();
  final added = repository.liveAdded().first;
  repository.add(Product(id: 3, name: 'Monitor', price: 180.0));
  print('Products: ${await repository.getAll()}');
  print('Live added: ${await added}');
  await repository.dispose(); // Đóng controller để khỏi rò tài nguyên.

  print('--- Lab3 Ex2 --- Users: ${await fetchUsersFromJson()}');
  print('--- Lab3 Ex3 --- Event order: ${await microtaskOrder()}');
  print('--- Lab2 Ex5 --- Students: ${await loadStudents()}');
  print('--- Lab2 Ex5 --- Stream: ${await numberStream().toList()}');
  print('--- Lab3 Ex4 --- Even squares: ${await evenSquares().toList()}');
  print('--- Lab3 Ex5 --- Singleton: ${identical(Settings(), Settings())}');
}
