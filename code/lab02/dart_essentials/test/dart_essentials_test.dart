import 'package:dart_essentials/dart_essentials.dart';
import 'package:test/test.dart';

void main() {
  // Kiểm tra List, Set, Map và phép tính tổng của Exercise 2.
  test('collections add, remove, and map values', () {
    final summary = collectionsSummary();

    expect(summary['numbers'], [2, 3, 4]);
    expect(summary['uniqueNumbers'], {1, 2, 3});
    expect(summary['userName'], 'Nam');
    expect(summary['sum'], 9);
  });

  // Kiểm tra ElectricCar kế thừa và ghi đè method của Car ở Exercise 4.
  test('inheritance overrides the car behavior', () {
    expect(Car('Toyota').start(), 'Toyota started');
    expect(ElectricCar('Tesla').start(), 'Tesla started silently');
  });

  // Kiểm tra Future và Stream trả về đúng dữ liệu ở Exercise 5.
  test('async and stream exercises produce values', () async {
    expect(await loadStudents(), ['An', 'Binh']);
    expect(await numberStream().toList(), [1, 2, 3]);
  });
}
