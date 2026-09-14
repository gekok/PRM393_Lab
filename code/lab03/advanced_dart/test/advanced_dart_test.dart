import 'package:advanced_dart/advanced_dart.dart';
import 'package:test/test.dart';

void main() {
  // Kiểm tra repository trả dữ liệu và phát đúng sản phẩm mới qua stream.
  test('repository returns products and emits added products', () async {
    final repository = ProductRepository();
    final addedFuture = repository.liveAdded().first;
    final product = Product(id: 3, name: 'Monitor', price: 180);
    repository.add(product);

    expect((await repository.getAll()).last.name, 'Monitor');
    expect(await addedFuture, same(product));
    await repository.dispose();
  });

  // Kiểm tra JSON được chuyển thành các User model có kiểu rõ ràng.
  test('JSON users are converted into typed models', () async {
    final users = await fetchUsersFromJson();

    expect(users.map((user) => user.name), ['An', 'Binh']);
    expect(users.first.email, 'an@example.com');
  });

  // Kiểm tra microtask được xử lý trước event thông thường.
  test('microtasks run before regular events', () async {
    expect(await microtaskOrder(), ['A', 'B', 'microtask', 'event']);
  });

  // Kiểm tra map bình phương và where lọc số chẵn.
  test('stream transformation squares and filters numbers', () async {
    expect(await evenSquares().toList(), [4, 16]);
  });

  // Kiểm tra factory Settings luôn trả về cùng một instance.
  test('factory returns the singleton instance', () {
    expect(identical(Settings(), Settings()), isTrue);
  });
}
