class User {
  int id;
  String name;
  // TODO 1: email có thể null (nullable variable).
  // Dấu ? cho phép biến giữ null.
  String? email;

  // Constructor
  User({required this.id, required this.name, this.email});

  // TODO 2: factory chuyển JSON thành object.
  // Factory không tạo field mới.
  // Nó chỉ chọn cách gọi constructor có sẵn.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      // Nếu json['name'] là null thì dùng "Khách".
      name: json['name'] as String? ?? "Khách",
      email: json['email'] as String?,
    );
  }

  void showProfile() {
    // TODO 3: nếu email null thì in "Chưa cập nhật".
    print("ID: $id | Tên: $name | Email: ${email ?? "Chưa cập nhật"}");
  }
}

void main() {
  // Giả lập dữ liệu JSON trả về từ API
  Map<String, dynamic> rawData1 = {"id": 1, "name": "Nam", "email": "nam@fpt.edu.vn"};
  Map<String, dynamic> rawData2 = {"id": 2, "name": null, "email": null};

  // TODO 4: tạo object từ Map bằng factory.
  final user1 = User.fromJson(rawData1);
  final user2 = User.fromJson(rawData2);

  user1.showProfile();
  user2.showProfile();
}
