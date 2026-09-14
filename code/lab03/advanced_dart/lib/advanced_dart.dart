import 'dart:async';
import 'dart:convert';

// Product là model chứa dữ liệu của một sản phẩm.
class Product {
  final int id;
  final String name;
  final double price;

  // Constructor yêu cầu đủ id, tên và giá sản phẩm.
  Product({required this.id, required this.name, required this.price});

  // Chuyển Product thành chuỗi dễ đọc khi in ra Terminal.
  @override
  String toString() => '$name (\$${price.toStringAsFixed(2)})';
}

// ProductRepository quản lý danh sách sản phẩm và stream sản phẩm mới.
class ProductRepository {
  final List<Product> _products = [
    Product(id: 1, name: 'Keyboard', price: 25.0),
    Product(id: 2, name: 'Mouse', price: 15.5),
  ];
  final StreamController<Product> _addedController =
      StreamController<Product>.broadcast();

  // getAll giả lập thao tác lấy dữ liệu bất đồng bộ và trả về list chỉ đọc.
  Future<List<Product>> getAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return List.unmodifiable(_products);
  }

  // liveAdded cung cấp stream broadcast để nhiều listener nghe sản phẩm mới.
  Stream<Product> liveAdded() => _addedController.stream;

  // add lưu sản phẩm vào list rồi phát event cho các listener của stream.
  void add(Product product) {
    _products.add(product);
    _addedController.add(product);
  }

  // dispose đóng StreamController để giải phóng resource khi repository hết dùng.
  Future<void> dispose() => _addedController.close();
}

// User là model dùng để biểu diễn dữ liệu người dùng sau khi parse JSON.
class User {
  final String name;
  final String email;

  User({required this.name, required this.email});

  // Factory tạo User từ map JSON và ép kiểu các field cần thiết.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(name: json['name'] as String, email: json['email'] as String);
  }

  @override
  String toString() => '$name <$email>';
}

// Exercise 2: decode JSON giả lập rồi map từng object thành User model.
Future<List<User>> fetchUsersFromJson() async {
  const rawJson = '[{"name":"An","email":"an@example.com"},'
      '{"name":"Binh","email":"binh@example.com"}]';
  final decoded = jsonDecode(rawJson) as List<dynamic>;
  return decoded
      .map((item) => User.fromJson(item as Map<String, dynamic>))
      .toList();
}

// Exercise 3: ghi lại thứ tự synchronous code, microtask và event queue.
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

// Exercise 4: bình phương các số rồi lọc lại chỉ những kết quả chẵn.
Stream<int> evenSquares() => Stream.fromIterable([1, 2, 3, 4, 5])
    .map((number) => number * number)
    .where((number) => number.isEven);

// Settings minh họa factory singleton: mọi lần gọi Settings() dùng cùng instance.
class Settings {
  static final Settings _instance = Settings._();

  Settings._();

  // Factory trả về instance dùng chung thay vì tạo object mới.
  factory Settings() => _instance;

  String theme = 'light';
}
