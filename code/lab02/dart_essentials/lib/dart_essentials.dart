// Car là class cơ sở mô tả một chiếc xe bằng thương hiệu và hành vi khởi động.
class Car {
  final String brand;

  // Constructor nhận thương hiệu và gán vào property brand.
  Car(this.brand);

  // start trả về thông báo khi xe khởi động.
  String start() => '$brand started';
}

// ElectricCar kế thừa Car và thay đổi hành vi start cho xe điện.
class ElectricCar extends Car {
  // super.brand chuyển thương hiệu lên constructor của class cha Car.
  ElectricCar(super.brand);

  // Ghi đè start để mô tả xe điện khởi động yên lặng.
  @override
  String start() => '$brand started silently';
}

// Exercise 1: khai báo dữ liệu cơ bản và minh họa string interpolation.
String basicSyntaxSummary() {
  const age = 20;
  const gpa = 3.75;
  const campus = 'FPT HCM';
  const passed = true;
  return 'age=$age, gpa=$gpa, campus=$campus, passed=$passed';
}

// Exercise 2: thao tác List, Set và Map rồi trả về kết quả tổng hợp.
Map<String, dynamic> collectionsSummary() {
  final numbers = [1, 2, 3];
  final rawNumbers = <int>[1, 2, 2, 3];
  final uniqueNumbers = rawNumbers.toSet();
  final user = {'id': 1, 'name': 'Nam'};
  numbers.add(4);
  numbers.remove(1);
  return {
    'numbers': numbers,
    'uniqueNumbers': uniqueNumbers,
    'userName': user['name'],
    'sum': numbers.reduce((a, b) => a + b),
  };
}

// Exercise 3: dùng toán tử điều kiện và switch để phân loại điểm.
String controlFlowSummary(int score) {
  final result = score >= 50 ? 'Pass' : 'Fail';
  final day = switch (score % 2) {
    0 => 'Even score',
    _ => 'Odd score',
  };
  return '$result - $day';
}

// Exercise 5: giả lập tải dữ liệu bất đồng bộ bằng Future.delayed.
Future<List<String>> loadStudents() async {
  await Future<void>.delayed(const Duration(milliseconds: 10));
  return ['An', 'Binh'];
}

// Exercise 5: phát lần lượt các số bằng asynchronous generator và yield.
Stream<int> numberStream() async* {
  for (var number = 1; number <= 3; number++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    yield number;
  }
}
